// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IModule} from "./IModule.sol";
import {IProcessor} from "./IProcessor.sol";

contract RequestModule is IModule {
    IProcessor public processor;

    struct RequestParameters {
        address payer;
        address target;
        uint256 bondAmount;
        bytes data;
    }

    error InvalidRequestModule();
    error InvalidPayer();
    error OnlyProcessor();
    error CallFailed();

    constructor(IProcessor _processor) {
        processor = _processor;
    }

    modifier onlyProcessor(address _caller) {
        if (_caller != address(processor)) revert OnlyProcessor();
        _;
    }

    function decodeRequestData(bytes memory _data) public pure returns (RequestParameters memory _params) {
        _params = abi.decode(_data, (RequestParameters));
    }

    function createRequest(IProcessor.Request memory _request, address _caller) public onlyProcessor(msg.sender) {
        RequestParameters memory _params = decodeRequestData(_request.requestData);

        if (_params.payer != _caller) revert InvalidPayer();

        processor.bond(_getRequestId(_request), _params.payer, _params.bondAmount);
    }

    function processRequest(IProcessor.Request memory _request, address _caller) external onlyProcessor(msg.sender) {
        if (_request.requestModule != address(this)) revert InvalidRequestModule();

        RequestParameters memory _params = decodeRequestData(_request.requestData);
        processor.bond(_getRequestId(_request), _caller, _params.bondAmount);
        (bool _success,) = _params.target.call(_params.data);
        if (!_success) revert CallFailed();
    }

    function finalizeRequest(IProcessor.Request memory _request, address _caller) external onlyProcessor(msg.sender) {
        bytes32 _requestId = _getRequestId(_request);

        RequestParameters memory _params = decodeRequestData(_request.requestData);
        processor.release(_requestId, _caller, _params.bondAmount);

        processor.pay(_requestId, _params.payer, _caller, _params.bondAmount);
    }

    function _getRequestId(IProcessor.Request memory _request) internal pure returns (bytes32 _requestId) {
        _requestId = keccak256(
            abi.encodePacked(
                _request.nonce,
                _request.requestModule,
                _request.requestData,
                _request.callbackModule,
                _request.callbackData
            )
        );
    }
}
