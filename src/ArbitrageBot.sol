// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// https://basescan.org/address/0x4e8aea36a11b94058b8c6308472cba8c1d1baf1d

interface IPair {
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function burn(address to) external returns (uint amount0, uint amount1);
    function mint(address to) external returns (uint liquidity);
    function getReserves() external view returns (uint _reserve0, uint _reserve1, uint _blockTimestampLast);
    function getAmountOut(uint, address) external view returns (uint);
    function stable() external view returns (bool);
}

interface IERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint);
	function approve(address spender, uint amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}


interface IRouter {
    function pairFor(address tokenA, address tokenB, bool stable) external view returns (address pair);
    function swapExactTokensForTokensSimple(uint amountIn, uint amountOutMin, address tokenFrom, address tokenTo, bool stable, address to, uint deadline) external returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, address tokenIn, address tokenOut, bool stable) external view returns (uint amount);
	function getReserves(address tokenA, address tokenB, bool stable) external view returns (uint, uint);
    function addLiquidity( address tokenA, address tokenB, bool stable, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint, uint, uint);
}

interface IPantheon {
    function mint(address receiver) external payable;
    function redeem(uint256 pantheon) external;
    function getMintPantheon(uint256 amount) external view returns (uint256);
    function getRedeemPantheon(uint256 amount) external view returns (uint256);
    function getTotalEth() external view returns (uint256);
    function totalSupply() external view returns (uint256);
}



contract ArbitrageBot is Ownable {
    address public routerAddress = 0x2F87Bf58D5A9b2eFadE55Cdbd46153a0902be6FA;
    address public usdcAddress = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address public scaleAddress = 0x54016a4848a38f257B6E96331F7404073Fd9c32C;
    address public pantheonAddress = 0x993cd9c0512cfe335bc7eF0534236Ba760ea7526;
    address public _owner;
    // mapping (address => uint256) public tokens;

    constructor(address initialOwner) Ownable(initialOwner) {
        _owner = initialOwner;
    } 


    /*
    GET TOKEN BALANCES
    PANTHEON
    SCALE
    USDC
    ETH 
    */
    function getEthBalance() public view returns(uint256){
        uint256 balance = address(this).balance;
        return balance;
    }
    function getPantheonBalance() public view returns(uint256){
        uint256 balance = IERC20(pantheonAddress).balanceOf(address(this));
        return balance;
    }
    function getScaleBalance() public view returns(uint256){
        uint256 balance = IERC20(scaleAddress).balanceOf(address(this));
        return balance;
    }
    function getUsdcBalance() public view returns(uint256){
        uint256 balance = IERC20(usdcAddress).balanceOf(address(this));
        return balance;
    }

    /* 
    SWAP FUNCTIONALITY
    get amount of different tokens
    swap
    */
    function getUsdcWithPantheon(uint256 _pantheonAmount) public view returns (uint256) {
        uint256  amountUsdcOut =  IRouter(routerAddress).getAmountOut(_pantheonAmount, pantheonAddress, usdcAddress, false);
        return amountUsdcOut;
    }
    function getPantheonWithUsdc(uint256 _usdcAmount) public view returns(uint256) {
        uint256 amountPantheonOut =  IRouter(routerAddress).getAmountOut(_usdcAmount, usdcAddress, pantheonAddress, false);
        return amountPantheonOut;
    }

    function getPantheonWithScale(uint256 _scaleAmount) public view returns(uint256){
        uint256 amountPantheonOut =  IRouter(routerAddress).getAmountOut(_scaleAmount, scaleAddress, pantheonAddress, false);
        return amountPantheonOut;
    }

    function getScaleWithPantheon(uint256 _pantheonAmount) public view returns(uint256){
        uint256 amountPantheonOut =  IRouter(routerAddress).getAmountOut(_pantheonAmount, pantheonAddress, scaleAddress, false);
        return amountPantheonOut;
    }

    function swap(address _tokenIn,  address _tokenOut, uint256 _amount, uint256 _amountOutMin) private {
		IERC20(_tokenIn).approve(routerAddress, _amount);
		uint deadline = block.timestamp + 300;
		IRouter(routerAddress).swapExactTokensForTokensSimple(_amount, _amountOutMin, _tokenIn, _tokenOut, false, address(this), deadline);
    }
    
    function ScaleToPantheonToUsdc(uint256 _amount18, uint256 _amountOutMinDec18, uint256 _amountOutMinDec6) public {
        uint256 pantheonInitialBalance = IERC20(pantheonAddress).balanceOf(address(this));
        swap(scaleAddress, pantheonAddress, _amount18, _amountOutMinDec18);
        uint256 pantheonBalance = IERC20(pantheonAddress).balanceOf(address(this));
        uint256 pantheonTradeableAmount = pantheonBalance - pantheonInitialBalance;
        swap(pantheonAddress, usdcAddress, pantheonTradeableAmount, _amountOutMinDec6);
    }

    function UsdcToPantheonToScale(uint256 _amount6, uint256 _amountOutMinDec18) public {
        uint256 pantheonInitialBalance = IERC20(pantheonAddress).balanceOf(address(this));
        swap(usdcAddress, pantheonAddress, _amount6, _amountOutMinDec18);
        uint256 pantheonBalance = IERC20(pantheonAddress).balanceOf(address(this));
        uint256 pantheonTradeableAmount = pantheonBalance - pantheonInitialBalance;
        swap(pantheonAddress, scaleAddress, pantheonTradeableAmount, _amountOutMinDec18);
    }

    // Arbitrage the Pantheon - USDC pool with the Pantheon contract (mint and redeem),
    // example: 
    // if the Pantheon price in the USDC liquidity pool goes above mint price, 
    // the Bot should Mint Pantheon and sell It in the Liquidity Pool until it reaches the Mint price.

    function ProfitFromMint(uint256 ethers_amount, uint256 pantheonAmount) public {
        // 1% from ETH balance
        IPantheon(pantheonAddress).mint{value: ethers_amount}(address(this));
        swap(pantheonAddress, usdcAddress, pantheonAmount, 0);
    }

    function ProfitFromRedeem(uint256 usdcAmount, uint256 pantheonAmount) public {
        swap(usdcAddress, pantheonAddress, usdcAmount, 0);
        IPantheon(pantheonAddress).redeem(pantheonAmount);
    }



    /*
    MANAGE BALANCES
    OF DIFFERENT TOKENS
    */

    receive() external payable {}

    function depositTokens(address token, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than zero");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function withdrawTokens(address token, uint256 amount) external onlyOwner{
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than zero");
        require(IERC20(token).balanceOf(address(this)) > amount, "Not enough funds to withdraw");
        IERC20(pantheonAddress).approve(address(this), amount);
        IERC20(token).transferFrom(address(this), msg.sender, amount);
    }

    function withdrawEth(uint256 amount) external onlyOwner(){
        uint256 balance = address(this).balance;
        require(balance > amount, "No Ether to withdraw");
        (bool success, ) = payable(_owner).call{value: amount}("");
        require(success, "Withdrawal failed");
    }
   
}