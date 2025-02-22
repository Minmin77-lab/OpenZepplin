// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol"; 

contract MyToken is ERC20 {
    address private owner;

    constructor() ERC20("MyToken", "MTK", 1000000 * 10 ** 12, 1 ether) { //начальное количество токенов
        owner = msg.sender; // владелец контракта
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
    }
    
}
