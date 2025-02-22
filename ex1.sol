// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";
import "./LP.sol"; 

contract LiquidityPool {
    IERC20 public tokenA;
    IERC20 public tokenB;
    LP public lpToken; 

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public totalLiquidity; 

    constructor(address _tokenA, address _tokenB, address _lpToken) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        lpToken = LP(_lpToken); 
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Invalid amounts"); 
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalLiquidity == 0) {
            liquidity = amountA + amountB; 
        } else {
            liquidity = min((amountA * totalLiquidity) / reserveA, (amountB * totalLiquidity) / reserveB);
        }

        reserveA += amountA;
        reserveB += amountB;
        totalLiquidity += liquidity;

        lpToken.mint(msg.sender, liquidity);
    }

     function removeLiquidity(uint256 lpAmount) external {
        require(lpAmount > 0, "Invalid LP amount");
        require(lpToken.balanceOf(msg.sender) >= lpAmount, "Not enough LP tokens");    
        uint256 amountA = (lpAmount * reserveA) / totalLiquidity;
        uint256 amountB = (lpAmount * reserveB) / totalLiquidity;
        lpToken.burn(lpAmount); 
        totalLiquidity -= lpAmount;
        reserveA -= amountA;
        reserveB -= amountB;

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);
    }

    function swap(address tokenFrom, address tokenTo, uint256 amountIn) external {
        require(tokenFrom != address(0), "Invalid from address");
        require(tokenTo != address(0), "Invalid to address");
        require(amountIn > 0, "Invalid amount");

        bool isA = tokenFrom == address(tokenA);
        require(isA || tokenFrom == address(tokenB), "Invalid token");

        IERC20 tokenIn = isA ? tokenA : tokenB;
        IERC20 tokenOut = isA ? tokenB : tokenA;
        uint256 reserveIn = isA ? reserveA : reserveB;
        uint256 reserveOut = isA ? reserveB : reserveA;

        // Расчет количества выходного токена (с учетом автоматического баланса)
        uint256 amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
        require(amountOut > 0, "Insufficient output amount"); // Проверка на достаточное количество выходного токена

        // Совершаем обмен
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(msg.sender, amountOut);

        // Обновляем резервы
        if (isA) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }
    }

    // Функция для нахождения минимума
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
