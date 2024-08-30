// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IModule} from "./IModule.sol";
import {IProcessor} from "./IProcessor.sol";

contract Processor is IProcessor {
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public bondedBalanceOf;
    mapping(address => mapping(bytes32 => uint256)) public bonds;
    mapping(bytes32 => mapping(address => bool)) public allowedModule;
    mapping(bytes32 => uint256) public createdAt;
    mapping(bytes32 => bool) public processedRequest;
    mapping(bytes32 => bool) public finalizedRequest;

    uint256 public nonce;

    modifier onlyModule(address _module, bytes32 _requestId) {
        if (msg.sender != address(this) && !allowedModule[_requestId][msg.sender]) revert NotAnAllowedModule();
        _;
    }

    function createRequest(Request memory _request) external returns (Request memory) {
        _request.nonce = nonce++;
        bytes32 _requestId = getRequestId(_request);

        if (createdAt[_requestId] > 0) revert InvalidRequestId();

        createdAt[_requestId] = block.timestamp;
        allowedModule[_requestId][_request.requestModule] = true;
        allowedModule[_requestId][_request.callbackModule] = true;
        IModule(_request.requestModule).createRequest(_request, msg.sender);
        return _request;
    }

    function processRequest(Request memory _request) external {
        bytes32 _requestId = getRequestId(_request);

        if (createdAt[_requestId] == 0) revert InvalidRequestId();
        if (processedRequest[_requestId]) revert InvalidRequestId();

        processedRequest[_requestId] = true;

        IModule(_request.requestModule).processRequest(_request, msg.sender);
        IModule(_request.callbackModule).processRequest(_request, msg.sender);
    }

    function finalizeRequest(Request memory _request) external {
        bytes32 _requestId = getRequestId(_request);

        if (createdAt[_requestId] == 0) revert InvalidRequestId();
        if (!processedRequest[_requestId]) revert InvalidRequestId();
        if (finalizedRequest[_requestId]) revert InvalidRequestId();

        IModule(_request.requestModule).finalizeRequest(_request, msg.sender);
        IModule(_request.callbackModule).finalizeRequest(_request, msg.sender);
    }

    function bond(bytes32 _requestId, address _bonder, uint256 _amount) public onlyModule(msg.sender, _requestId) {
        balanceOf[_bonder] -= _amount;
        bondedBalanceOf[_bonder] += _amount;
        bonds[_bonder][_requestId] += _amount;
    }

    function release(bytes32 _requestId, address _bonder, uint256 _amount) public onlyModule(msg.sender, _requestId) {
        bonds[_bonder][_requestId] -= _amount;
    }

    function pay(bytes32 _requestId, address _payer, address _payee, uint256 _amount)
        public
        onlyModule(msg.sender, _requestId)
    {
        bondedBalanceOf[_payer] -= _amount;
        balanceOf[_payee] += _amount;
    }

    function topUp() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        if (balanceOf[msg.sender] - bondedBalanceOf[msg.sender] < _amount) revert InsufficientBalance();
        balanceOf[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function getRequestId(Request memory _request) public pure returns (bytes32 _requestId) {
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
