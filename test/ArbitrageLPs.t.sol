// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../src/ArbitrageBot.sol";


// USDC - 0x833589fcd6edb6e08f4c7c32d4f71b54bda02913
// SCALE - 0x54016a4848a38f257b6e96331f7404073fd9c32c
// PANTHEON - 0x993cd9c0512cfe335bc7eF0534236Ba760ea7526
// PANTHEON/USDC - 0x36e05b7ad2f93816068c831415560ae872024f27
// PANTHEON/SCALE - 0x1948bd09a8777023d4f15e29880930ed5ba0daf2
// ScaleRouter contract address - 0x2f87bf58d5a9b2efade55cdbd46153a0902be6fa






contract ArbitrageLPs is Test {
    ArbitrageBot bot;
    address public usdcAddress = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address public scaleAddress = 0x54016a4848a38f257B6E96331F7404073Fd9c32C;
    address public pantheonAddress = 0x993cd9c0512cfe335bc7eF0534236Ba760ea7526;

    function setUp() public {
        bot = new ArbitrageBot(address(2));
    }
    
    function testGetUsdcWithPantheon() public view {
        uint256 amountUsdcOut = bot.getUsdcWithPantheon(10 * 1e18);
        console.log("amountUsdcOut With PANTHEON: ", amountUsdcOut);
    }

    function testGetPantheonWithUsdc() public view {
        uint256 amountPantheonOut = bot.getPantheonWithUsdc(10 * 1e6);
        console.log("amountPantheonOut With USDC: ", amountPantheonOut);
    }

    function testGetPantheonWithScale() public view {
        uint256 amountPantheonOut = bot.getPantheonWithScale(10 * 1e18);
        console.log("amountPantheonOut With Scale: ",  amountPantheonOut);
    }

    function testGetScaleWithPantheon() public view {
        uint256 amountScaleOut = bot.getScaleWithPantheon(10 * 1e18);
        console.log("amountScaleOut with PANTHEON: ", amountScaleOut);
    }
    // 914252 gas
    function testScaleToPantheonToUsdc() public {
        deal(pantheonAddress, address(bot), 1000e18);
        deal(scaleAddress, address(bot), 1000e18);
        deal(usdcAddress, address(bot), 1000e6);
        console.log("Pantheon before swap 10 SCALE: ", IERC20(pantheonAddress).balanceOf(address(bot)));
        console.log("SCALE before swap 10 SCALE: ", IERC20(scaleAddress).balanceOf(address(bot)));
        console.log("USDC before swap 10 SCALE: ", IERC20(usdcAddress).balanceOf(address(bot)));
        bot.ScaleToPantheonToUsdc(10*1e18, 0, 0);
        console.log("Pantheon after swap 10 SCALE: ", IERC20(pantheonAddress).balanceOf(address(bot)));
        console.log("SCALE after swap 10 SCALE: ", IERC20(scaleAddress).balanceOf(address(bot)));
        console.log("USDC after swap 10 SCALE: ", IERC20(usdcAddress).balanceOf(address(bot)));
    }

    // 918562 gas
    function testUsdcToPantheonToScale() public {
        deal(pantheonAddress, address(bot), 1000e18);
        deal(scaleAddress, address(bot), 1000e18);
        deal(usdcAddress, address(bot), 1000e6);
        console.log("Pantheon before swap 10 USDC: ", IERC20(pantheonAddress).balanceOf(address(bot)));
        console.log("SCALE before swap 10 USDC: ", IERC20(scaleAddress).balanceOf(address(bot)));
        console.log("USDC before swap 10 USDC: ", IERC20(usdcAddress).balanceOf(address(bot)));
        bot.UsdcToPantheonToScale(10*1e6, 0);

        console.log("Pantheon after swap 10 USDC: ", IERC20(pantheonAddress).balanceOf(address(bot)));
        console.log("SCALE after swap 10 USDC: ", IERC20(scaleAddress).balanceOf(address(bot)));
        console.log("USDC after swap 10 USDC: ", IERC20(usdcAddress).balanceOf(address(bot)));
    }

    // 743688 gas
    function testProfitFromMint() public {
        deal(pantheonAddress, address(bot), 1000e18);
        deal(scaleAddress, address(bot), 1000e18);
        deal(usdcAddress, address(bot), 1000e6);
        deal(address(bot), 2000e18);
        console.log("pantheonToken: ", IERC20(pantheonAddress).balanceOf(address(bot))/ 1e18);
        console.log("usdc: ", IERC20(usdcAddress).balanceOf(address(bot))/ 1e6);
        console.log("Eth: ", address(bot).balance / 1e18);
        vm.prank(address(bot));
        bot.ProfitFromMint(1e18, 1000e18);
        //IPantheon(pantheonAddress).mint{value: 1e18}(address(bot));
        console.log("pantheonToken after minting 1000 pantheon and swap it: ", IERC20(pantheonAddress).balanceOf(address(bot))/ 1e18);
        console.log("usdc after minting 1000 pantheon and swap it: ", IERC20(usdcAddress).balanceOf(address(bot))/ 1e6);
        console.log("Eth after minting 1000 pantheon and swap it: ", address(bot).balance / 1e18);
    }

    // 746748
    function testProfitFromRedeem() public {
        deal(pantheonAddress, address(bot), 10000e18);
        deal(scaleAddress, address(bot), 1000e18);
        deal(usdcAddress, address(bot), 10000000e6);
        deal(address(bot), 20000e18);
        console.log("pantheonToken: ", IERC20(pantheonAddress).balanceOf(address(bot))/ 1e18);
        console.log("usdc: ", IERC20(usdcAddress).balanceOf(address(bot))/ 1e6);
        console.log("Eth: ", address(bot).balance / 1e18);
        vm.prank(address(bot));
        bot.ProfitFromRedeem(10e6, 7e18);
        console.log("pantheonToken after swapping 10 usdc and swap 7 pantheon: ", IERC20(pantheonAddress).balanceOf(address(bot))/1e18);
        console.log("usdc after swapping 10 usdc and swap 7 pantheon: ", IERC20(usdcAddress).balanceOf(address(bot))/1e6);
        console.log("Eth after swapping 10 usdc and swap 7 pantheon: ", address(bot).balance/1e18);
    }

    function testDeposit() public {
        deal(pantheonAddress, address(2), 10000e18);
        vm.startPrank(address(2));
        IERC20(pantheonAddress).approve(address(bot), 10*1e18);
        console.log('bot pantheon before: ', IERC20(pantheonAddress).balanceOf(address(bot)) / 1e18);
        console.log('user pantheon before: ', IERC20(pantheonAddress).balanceOf(address(2)) / 1e18);
        bot.depositTokens(pantheonAddress, 5*1e18);
        console.log('bot pantheon after depositing 5 pantheons: ', IERC20(pantheonAddress).balanceOf(address(bot)) / 1e18);
        console.log('user pantheon after depositing 5 pantheons: ', IERC20(pantheonAddress).balanceOf(address(2)) / 1e18);
        vm.stopPrank();
    }


    function testWithdrawTokens() public {
        deal(pantheonAddress, address(bot), 10000e18);

        vm.startPrank(address(2));
        console.log('bot pantheon before: ', IERC20(pantheonAddress).balanceOf(address(bot)) / 1e18);
        console.log('user pantheon before: ', IERC20(pantheonAddress).balanceOf(address(2)) / 1e18);
        bot.withdrawTokens(pantheonAddress, 5*1e18);
        console.log('bot pantheon after withdraw 5 pantheons: ', IERC20(pantheonAddress).balanceOf(address(bot)) / 1e18);
        console.log('user pantheon after withdraw 5 pantheons: ', IERC20(pantheonAddress).balanceOf(address(2)) / 1e18);
        vm.stopPrank();

    }
    function testWithdrawEth() public {
        deal(address(bot), 10e18);

        vm.prank(address(2));
        bot.withdrawEth(1e18);

        console.log("balance  after  withdrawing 1 ETH:", address(2).balance / 1e18);
    }
   

    
}