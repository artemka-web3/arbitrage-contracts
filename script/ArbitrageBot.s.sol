// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ArbitrageBot.sol";


contract ArbitrageBotScript is Script{
    function setUp() public {

    }

    function run() public {
        uint256 privateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(privateKey);
        ArbitrageBot bot = new ArbitrageBot(0xe8dE7E6b50290d398716BF9fBCFc8B50E0Da2cAd);
        vm.stopBroadcast();

    }
}