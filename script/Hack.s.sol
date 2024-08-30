// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Processor} from "src/Processor.sol";
import {CallbackModule} from "src/CallbackModule.sol";
import {RequestModule} from "src/RequestModule.sol";

struct Request {
    uint256 nonce;
    address requestModule;
    bytes requestData;
    address callbackModule;
    bytes callbackData;
}

contract Hack is Script {
    Processor public processor;
    RequestModule public requestModule;
    CallbackModule public callbackModule;

    function setUp() public {
        processor = Processor(0x1c8439cF1501978E9eeeb9d15342C05Dde949722);
        requestModule = RequestModule(0xb2287F97eCa395587EE344590ACBCc2BfA15d5Ff);
        callbackModule = CallbackModule(0x43941b3CF410Ec0EF5daa4EC61CB9fBB515803d9);
    }

    function run() public {
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
