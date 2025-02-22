// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PoolFactory.sol";
import "./LiquidityPool.sol";
import "./IERC20.sol";

contract Router {
    PoolFactory public factory;

    event SwapCompleted(address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address _factory) {
        factory = PoolFactory(_factory);
    }

    // Функция для обмена через один пул
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 minAmountOut,
        address[] memory path
    ) external {
        require(path.length >= 2, "Invalid path length");

        address tokenIn = path[0];
        address tokenOut = path[path.length - 1];

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        uint256 amountOut = _swap(amountIn, path);

        require(amountOut >= minAmountOut, "Slippage exceeded");

        IERC20(tokenOut).transfer(msg.sender, amountOut);

        emit SwapCompleted(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

// Внутренняя функция, которая выполняет обмен через один или несколько пулов
    function _swap(uint256 amountIn, address[] memory path) internal returns (uint256) {
        uint256 amountOut = amountIn;
        for (uint256 i = 0; i < path.length - 1; i++) {
        address tokenA = path[i];
        address tokenB = path[i + 1];
        address poolAddress = factory.getPool(tokenA, tokenB);
        require(poolAddress != address(0), "Pool does not exist");
        LiquidityPool pool = LiquidityPool(poolAddress);
        IERC20(tokenA).approve(poolAddress, amountOut);

        pool.swap(tokenA, tokenB, amountOut);
    }
    return amountOut; 
    }

}
