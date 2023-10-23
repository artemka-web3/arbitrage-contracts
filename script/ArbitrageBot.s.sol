// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ArbitrageBot.sol";

// forge script script/ArbitrageBot.s.sol:ArbitrageBotScript --rpc-url https://base-mainnet.g.alchemy.com/v2/00sZXJLaUPCy6ybR34fAvRrCDDNQ6Uf_ --broadcast --verify -vvvv


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

