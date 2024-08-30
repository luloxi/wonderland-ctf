// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IModule} from "./IModule.sol";
import {IProcessor} from "./IProcessor.sol";

contract CallbackModule is IModule {
    IProcessor public processor;

    struct RequestParameters {
        address target;
        bytes data;
    }

    error OnlyProcessor();
    error InvalidCallbackModule();
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

    function createRequest(IProcessor.Request memory _request, address _caller) external onlyProcessor(msg.sender) {
        // No-op
    }

    function processRequest(IProcessor.Request memory _request, address _caller) external onlyProcessor(msg.sender) {
        // No-op
    }

    function finalizeRequest(IProcessor.Request memory _request, address /* _caller */ )
        external
        onlyProcessor(msg.sender)
    {
        if (_request.callbackModule != address(this)) revert InvalidCallbackModule();

        RequestParameters memory _params = decodeRequestData(_request.callbackData);
        (bool _success,) = _params.target.call(_params.data);
        if (!_success) revert CallFailed();
    }
}
