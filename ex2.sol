// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LiquidityPool.sol";

contract PoolFactory {
    mapping(address => mapping(address => address)) public getPool; // Хранит адреса пулов
    address[] public allPools; // Массив всех пулов

    event PoolCreated(address indexed tokenA, address indexed tokenB, address pool);

    function createPool(address tokenA, address tokenB, address lpToken) external returns (address pool) {
        require(tokenA != tokenB, "Identical token addresses");
        require(tokenA != address(0) && tokenB != address(0), "Zero address");
        require(getPool[tokenA][tokenB] == address(0), "Pool already exists");

        // Создаем новый пул
        LiquidityPool newPool = new LiquidityPool(tokenA, tokenB, lpToken);
        pool = address(newPool); // Исправлено: убрано повторное объявление переменной

        // Записываем в mapping (в обе стороны)
        getPool[tokenA][tokenB] = pool;
        getPool[tokenB][tokenA] = pool;
        allPools.push(pool);

        emit PoolCreated(tokenA, tokenB, pool);
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
}
