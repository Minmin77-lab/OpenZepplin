// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol"; 

contract YourToken is ERC20 {
    address private owner;

    constructor() ERC20("YourToken", "YTK", 1000000 * 10 ** 18, 1 ether) { //начальное количество токенов
        owner = msg.sender; // владелец контракта
    }

    modifier onlyOwner() override {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function price() external view returns (uint256) {
        return 3 ether / 10**decimals();
    }

    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
    }
    
}
