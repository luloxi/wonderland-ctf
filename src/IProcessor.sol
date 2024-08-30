// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IProcessor {
    struct Request {
        uint256 nonce;
        address requestModule;
        bytes requestData;
        address callbackModule;
        bytes callbackData;
    }

    error InvalidRequestId();
    error InsufficientBalance();
    error NotAnAllowedModule();

    function bond(bytes32 _requestId, address _bonder, uint256 _amount) external;
    function release(bytes32 _requestId, address _bonder, uint256 _amount) external;
    function pay(bytes32 _requestId, address _payer, address _payee, uint256 _amount) external;
}
