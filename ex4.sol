// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";
import "./ERC20.sol";

contract Staking {
    IERC20 public lpToken;
    IERC20 public rewardToken;
    uint256 public rewardPerSecond = 13;
    uint256 public allAmount = 0;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastRewardTime;

    constructor(address _lpToken, address _rewardToken) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 amount) external {
        lpToken.transferFrom(msg.sender, address(this), amount);

        stakedAmount[msg.sender] += amount;
        allAmount += amount;
    }

    function withdraw(uint256 amount) external {
        lpToken.transfer(msg.sender, amount);

        stakedAmount[msg.sender] -= amount;
        allAmount -= amount;
    }

    function claimReward() external {
       uint256 timeDiff = block.timestamp - lastRewardTime[msg.sender];
       uint256 lpAmount = stakedAmount[msg.sender];
       uint256 rewardMultiplier = (timeDiff / 30 days) * 5 / 100 + 1; // Исправлено
       uint256 reward = lpAmount * timeDiff * rewardPerSecond * (lpAmount / allAmount + 1) * rewardMultiplier;
       rewardToken.transfer(msg.sender, reward);
       lastRewardTime[msg.sender] = block.timestamp;
    }
}
