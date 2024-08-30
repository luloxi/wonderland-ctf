// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IProcessor} from "./IProcessor.sol";

interface IModule {
    function createRequest(IProcessor.Request memory _request, address _caller) external;
    function processRequest(IProcessor.Request memory _request, address _caller) external;
    function finalizeRequest(IProcessor.Request memory _request, address _caller) external;
}
