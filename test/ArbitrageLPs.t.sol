// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/Vm.sol";
import "../src/ArbitrageBot.sol";


// USDC - 0x833589fcd6edb6e08f4c7c32d4f71b54bda02913
// SCALE - 0x54016a4848a38f257b6e96331f7404073fd9c32c
// PANTHEON - 0x993cd9c0512cfe335bc7eF0534236Ba760ea7526
// PANTHEON/USDC - 0x36e05b7ad2f93816068c831415560ae872024f27
// PANTHEON/SCALE - 0x1948bd09a8777023d4f15e29880930ed5ba0daf2
// ScaleRouter contract address - 0x2f87bf58d5a9b2efade55cdbd46153a0902be6fa






contract ArbitrageLPs is Test {
    // ArbitrageBot bot;
    address public constant routerAddress = 0x2F87Bf58D5A9b2eFadE55Cdbd46153a0902be6FA;
    address public constant usdcAddress = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address public constant scaleAddress = 0x54016a4848a38f257B6E96331F7404073Fd9c32C;
    address public constant scalePairAddress = 0x1948Bd09a8777023d4F15E29880930eD5bA0Daf2;
    address public constant usdcPairAddress = 0x36E05b7AD2F93816068C831415560AE872024F27;
    address public constant pantheonAddress = 0x993cd9c0512cfe335bc7eF0534236Ba760ea7526;





    // IRouter public router; 
    IERC20 usdcToken;
    IERC20 scaleToken;
    IERC20 pantheon;
    ArbitrageBot bot;

    function setUp() public {
        // router = IRouter(routerAddress); // get ScaleRouter Instance
        bot = new ArbitrageBot(address(1));
        usdcToken = IERC20(usdcAddress);
        scaleToken = IERC20(scaleAddress);
        pantheon = IERC20(pantheonAddress);

    }


    // function xtestGetAmountFromUSDCPair() public view {
    //     IPair pairUSDC = IPair(usdcPairAddress);  // usdc
    //     uint amount_usdc = pairUSDC.getAmountOut(10, usdcAddress);
    //     console.log("amount usdc: ", amount_usdc);
    // }
    // function xtestGetAmountFromSCALEPair() public view {
    //     IPair pairSCALE = IPair(scalePairAddress); // scale
    //     uint amount_scale = pairSCALE.getAmountOut(10, scaleAddress);
    //     console.log("amount scale: ", amount_scale);
    // }

    // function xtestScaleWithRouter() public view {
    //     uint amountPantheon = router.getAmountOut(10, pantheonAddress, scaleAddress, false);
    //     console.log("amount scale: ", amountPantheon);
    // } 

    // function xtestUsdcWithRouter() public view {
    //     uint amountPantheon = router.getAmountOut(10, pantheonAddress, usdcAddress, false);
    //     console.log("amount usdc: ", amountPantheon);
    // } 
    
    // function xtestDepositScale() public {
    //     console.log("SCALE balance before: ", scaleToken.balanceOf(address(this)));
    //     deal(address(scaleToken), address(this), 100e18, true);
    //     console.log("SCALE balance after: ", scaleToken.balanceOf(address(this))/ 1e188);
    // }

    // function xtestDepositUsdc() public {
    //     console.log("USDC balance before: ", usdcToken.balanceOf(address(this)));
    //     deal(address(usdcToken), address(this), 100e6, true);
    //     console.log("USDC balance after: ", usdcToken.balanceOf(address(this)) / 1e6);
    // }

    // function xtestTrade() public {
    //     vm.prank(address(1));
    //     bot.dualPoolTradeIfScalePoolCheaper(_router, _amount);
    // }

    function xtestSwap() public {
        deal(address(scaleToken), address(this), 100e18, true);
        IRouter(routerAddress).swapExactTokensForTokensSimple(10, 1, scaleAddress, pantheonAddress, false, address(this), block.timestamp + 300);
        deal(address(scaleToken), address(this), 100e18, true);


    }
    function testTradeScale() public {
        address eq = 0x7bE024bbD16E3E0ab6839cb94D0dc25B7A101eAb; 

        // пополнить баланс роутера эфиром, панфеоном, scale
        deal(eq, 100); // ETH
        deal(address(pantheon), eq, 100 * 1e18); // PANTHEON
        deal(address(scaleToken), eq, 100 * 1e18); // SCALE

        // пополнить баланс роутера эфиром, панфеоном, scale
        deal(routerAddress, 100); // ETH
        deal(address(pantheon), routerAddress, 100 * 1e18); // PANTHEON
        deal(address(scaleToken), routerAddress, 100 * 1e18); // SCALE

        // пополнить баланс контракта эфиров панфеоном скейлом
        deal(address(this), 100); // ETH
        deal(address(pantheon), address(this), 100); // PANTHEON
        deal(address(scaleToken), address(this), 100); // SCALE

        // пополнить баланс пары панфеоном  эфироми скейлом
        deal(scalePairAddress, 100); // ETH
        deal(address(pantheon), scalePairAddress, 1000000 * 1e18); // PANTHEON
        deal(address(scaleToken), scalePairAddress, 1000000 * 1e18); // SCALE

        // пополнить баланс рандомного человека эфиром панфеоном и скейлом
        deal(address(1), 100); // ETH
        deal(address(pantheon), address(1), 100 * 1e18); // PANTHEON
        deal(address(scaleToken), address(1), 100 * 1e18); // SCALE


        // апрувнуть все и всем
        pantheon.approve(routerAddress, 100 * 1e18);
        scaleToken.approve(routerAddress,  100 * 1e18);
    
        pantheon.approve(address(this), 100 * 1e18);
        scaleToken.approve(address(this),  100 * 1e18);

        pantheon.approve(scalePairAddress, 1000000 * 1e18);
        scaleToken.approve(scalePairAddress,  1000000 * 1e18);

        pantheon.approve(address(1), 100 * 1e18);
        scaleToken.approve(address(1),  100 * 1e18);

        pantheon.approve(eq, 100 * 1e18);
        scaleToken.approve(eq,  100 * 1e18);

        console.log('EQ PANTHEON before:  ', pantheon.balanceOf(address(this)));
        console.log('EQ SCALE before:  ', scaleToken.balanceOf(address(this)));
        console.log('EQ ETH before:  ', address(this).balance);

        console.log('Contract PANTHEON before:  ', pantheon.balanceOf(address(this)));
        console.log('Contract SCALE before:  ', scaleToken.balanceOf(address(this)));
        console.log('Contract ETH before:  ', address(this).balance);

        console.log('Router PANTHEON before:  ', pantheon.balanceOf(routerAddress));
        console.log('Router SCALE before:  ', scaleToken.balanceOf(routerAddress));
        console.log('Router ETH before:  ', routerAddress.balance);

        console.log('Pair PANTHEON before:  ', pantheon.balanceOf(scalePairAddress));
        console.log('Pair SCALE before:  ', scaleToken.balanceOf(scalePairAddress));
        console.log('Pair ETH before:  ', scalePairAddress.balance);

        console.log('User PANTHEON before:  ', pantheon.balanceOf(address(1)));
        console.log('User SCALE before:  ', scaleToken.balanceOf(address(1)));
        console.log('user ETH before:  ', address(1).balance);

        IRouter(routerAddress).swapExactTokensForTokensSimple(7, uint8(uint(1)), scaleAddress, pantheonAddress, false, address(this), block.timestamp + 300);

        console.log('Contract PANTHEON after:  ', pantheon.balanceOf(address(this)));
        console.log('Contract SCALE after:  ', scaleToken.balanceOf(address(this)));
        console.log('Contract ETH after:  ', address(this).balance);

        console.log('Router PANTHEON after:  ', pantheon.balanceOf(routerAddress));
        console.log('Router SCALE after:  ', scaleToken.balanceOf(routerAddress));
        console.log('Router ETH after:  ', routerAddress.balance);

        console.log('Pair PANTHEON after:  ', pantheon.balanceOf(scalePairAddress) );
        console.log('Pair SCALE after:  ', scaleToken.balanceOf(scalePairAddress));
        console.log('Pair ETH after:  ', scalePairAddress.balance);

        console.log('User PANTHEON after:  ', pantheon.balanceOf(address(1)));
        console.log('User SCALE after:  ', scaleToken.balanceOf(address(1)));
        console.log('user ETH after:  ', address(1).balance);

    }






    

}