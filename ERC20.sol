// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol"; 

contract ERC20 is IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _decimals = 18; 
    address private owner;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private price; 

    constructor(string memory name_, string memory symbol_, uint256 initialSupply, uint256 initialPrice) {
      _name = name_;
      _symbol = symbol_;
      owner = msg.sender;
      _mint(msg.sender, initialSupply);
      _balances[msg.sender] = _totalSupply; // Исправленная строка
      price = initialPrice; // Устанавливаем цену 
    }

    modifier onlyOwner() virtual {
      require(msg.sender == owner, "Caller is not the owner");
      _;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
      price = newPrice;
    }


    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount * (10 ** uint256(_decimals)); 
        _balances[account] += amount * (10 ** uint256(_decimals)); 
        emit Transfer(address(0), account, amount * (10 ** uint256(_decimals))); 
    }

    function burn(uint256 amount) public virtual{
        require(_balances[msg.sender] >= amount, "ERC20: burn amount exceeds balance");
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply -= amount * (10 ** uint256(_decimals)); 
        _balances[account] -= amount * (10 ** uint256(_decimals)); 
        emit Transfer(account, address(0), amount * (10 ** uint256(_decimals))); 
    }

    function transferFromOwner(address recipient, uint256 amount) public {
        require(msg.sender == owner, "Only owner can call this function");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[owner] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[owner] -= amount;
        _balances[recipient] += amount;
        emit Transfer(owner, recipient, amount);
    }
}

