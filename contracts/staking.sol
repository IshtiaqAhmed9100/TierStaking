// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public startTime;
    uint256 public lockTime;

    uint256 public APY;
    uint256 public perMonthReward;
    
    address ownerWallet;

    // uint256 private tier2_APY;
    // uint256 private tier3_APY;

    mapping(address => uint256) public stakedToken;
    mapping(address => uint256) public rewardedToken;

    mapping(address => uint256) public userTier;

    constructor() {
        stakingToken = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
        rewardToken = IERC20(0xf8e81D47203A594245E36C48e151709F0C19fBe8);
        startTime = block.timestamp;
        ownerWallet = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    }

    function stake(uint256 amount) public {
        // require(stakingToken.balanceOf(msg.sender) > amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedToken[msg.sender] += amount;
    }

    function selectTier(uint256 _tier, uint256 amountToStake) public {
        userTier[msg.sender] = _tier;
        stake(amountToStake);
    }

    function Unstake() public {
        
        uint256 tierSelect = userTier[msg.sender];

        if (tierSelect == 1 ) {
        require(block.timestamp > startTime + 2 minutes , "lock time not reaccheer tier 1 "); 
            withdrawTier1();
        }
        
         else if (tierSelect == 2) {
        require(block.timestamp > startTime + 4 minutes , "lock time not reaccheer tier 2");
            withdrawTier2();
        } 
        
        else if (tierSelect == 3) {
        // require(block.timestamp > startTime + 6 minutes , "lock time not reaccheer tier 3");
            withdrawTier3();
        }
    }

    function withdrawTier1() public {
        require(stakedToken[msg.sender] >= 0);
        uint256 am = stakedToken[msg.sender] * 1e18;
        uint256 finalAmount = (am * APY_tier1());
        uint256 finalAPY = finalAmount / 1e20;
        uint256 reward = stakedToken[msg.sender] * 1e18 + finalAPY;
        rewardToken.transferFrom(ownerWallet, msg.sender, reward);

        rewardedToken[msg.sender] += reward;
        delete stakedToken[msg.sender];
    }

    function withdrawTier2() public {
        require(stakedToken[msg.sender] >= 0);
        uint256 am = stakedToken[msg.sender] * 1e18;
        uint256 finalAmount = (am * APY_tier2());
        uint256 finalAPY = finalAmount / 1e20;
        uint256 reward = stakedToken[msg.sender] * 1e18 + finalAPY;
        rewardToken.transferFrom(ownerWallet, msg.sender, reward);

        rewardedToken[msg.sender] += reward;
        delete stakedToken[msg.sender];
    }

    function withdrawTier3() public {
        require(stakedToken[msg.sender] >= 0);
        uint256 am = stakedToken[msg.sender] * 1e18;
        uint256 finalAmount = (am * APY_tier3());
        uint256 finalAPY = finalAmount / 1e20;
        uint256 reward = stakedToken[msg.sender]  + 1;
        rewardToken.transferFrom(ownerWallet, msg.sender, reward);

        rewardedToken[msg.sender] += reward;
        delete stakedToken[msg.sender];
    }


    function APY_tier1() public pure returns (uint256) {
        uint256 apy = 252;
        uint256 r = (apy * 1e18) / 100;
        return r;
    }

    function APY_tier2() public pure returns (uint256) {
        uint256 apy = 1042;
        uint256 r = (apy * 1e18) / 100;
        return r;
    }

    function APY_tier3() public pure returns (uint256) {
        uint256 apy = 2475;
        uint256 r = (apy * 1e18) / 100;
        return r;
    }
    

    function getStakingToken() public view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }

    function getSTAKEToken(address _add) public view returns (uint256) {
        return stakingToken.balanceOf(_add);
    }

    function REWARDEDToken(address _add) public view returns (uint256) {
        return rewardedToken[_add];
    }

    function getREWARDToken(address _add) public view returns (uint256) {
        return rewardToken.balanceOf(_add);
    }

    function rewardAllowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return rewardToken.allowance(owner, spender);
    }

   
}
