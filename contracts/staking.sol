// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/ABDKMath64x64.sol";

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
    mapping(address => uint256) public userReward;
    mapping(address => uint256) public userTier;

    mapping(address => uint256) public userAmount;

    constructor() {
        stakingToken = IERC20(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
        rewardToken = IERC20(0xf8e81D47203A594245E36C48e151709F0C19fBe8);
        startTime = block.timestamp;
        ownerWallet = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    }

    function stake(uint256 amount) internal {
        // require(stakingToken.balanceOf(msg.sender) > amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedToken[msg.sender] += amount;
    }

    function selectTier(uint256 _tier, uint256 amountToStake) public {
        userTier[msg.sender] = _tier;
        stake(amountToStake);
    }

    function Unstake1() public {
            uint256 monthsStaked = block.timestamp - startTime / 60; // Calculate months staked

        uint256 tierSelect = userTier[msg.sender];
        if (tierSelect == 1 ) {
            // require(block.timestamp > startTime + 3 minutes , "lock time not reached tier 1");
            if (block.timestamp < startTime + 3 minutes) {
            // If not reached the lock time, return only reward
            RewardTier1(monthsStaked);
        }
            withdrawTier1(monthsStaked);

        } else if (tierSelect == 2) {
            require(block.timestamp > startTime + 6 minutes , "lock time not reached tier 1");
               if (block.timestamp < startTime + 6 minutes) {
            // If not reached the lock time, return only reward
            RewardTier2(monthsStaked);
        }
            withdrawTier2(monthsStaked);

        } else if (tierSelect == 3) {
            require(block.timestamp > startTime + 6 minutes , "lock time not reached tier 1");
                if (block.timestamp < startTime + 9 minutes) {
            // If not reached the lock time, return only reward
            RewardTier3(monthsStaked);
        }
            withdrawTier3(monthsStaked);
        }
    }



function calculateReward(uint256 principal, uint256 ratio, uint256 months) internal pure returns (uint256) {
    uint256 interest = _compound(principal * 1e18, ratio, months);
    return interest;
}


    function withdrawTier1(uint256 month) public {
        require(stakedToken[msg.sender] >= 0);
        uint256 _ratio = 8333333333333333;
        uint256 interest = _compound(stakedToken[msg.sender] * 1e18, _ratio, month);
        uint256 totalAmount = stakedToken[msg.sender] * 1e18 + interest;
        rewardToken.transferFrom(ownerWallet, msg.sender, totalAmount);
        rewardedToken[msg.sender] += totalAmount;
        delete stakedToken[msg.sender];
    }

    function RewardTier1(uint256 month) public {
        require(stakedToken[msg.sender] >= 0);
        uint256 _ratio = 8333333333333333;
        uint256 interest = _compound(
            stakedToken[msg.sender] * 1e18,
            _ratio,
            month
        );
        rewardToken.transferFrom(ownerWallet, msg.sender, interest);
        rewardedToken[msg.sender] += interest;
    }


    function withdrawTier2(uint256 month) public {
        require(stakedToken[msg.sender] >= 0);
        uint256 _ratio = 16666666666666666;
        uint256 interest = _compound(stakedToken[msg.sender] * 1e18, _ratio, month);
        uint256 totalAmount = stakedToken[msg.sender] * 1e18 + interest;
        rewardToken.transferFrom(ownerWallet, msg.sender, totalAmount);
        rewardedToken[msg.sender] += totalAmount;
        delete stakedToken[msg.sender];
    }

    function RewardTier2(uint256 month) public {
        require(stakedToken[msg.sender] >= 0);
        uint256 _ratio = 16666666666666666;
        uint256 interest = _compound(
            stakedToken[msg.sender] * 1e18,
            _ratio,
            month
        );
        rewardToken.transferFrom(ownerWallet, msg.sender, interest);
        rewardedToken[msg.sender] += interest;
    }

    function withdrawTier3(uint256 month) public {
        require(stakedToken[msg.sender] >= 0);
        uint256 interest = _APY(month);
        uint256 totalAmount = stakedToken[msg.sender] * 1e18 + interest;
        rewardToken.transferFrom(ownerWallet, msg.sender, totalAmount);
        rewardedToken[msg.sender] += totalAmount;
        delete stakedToken[msg.sender];
    }
    function RewardTier3(uint256 month) public {
        require(stakedToken[msg.sender] >= 0);
        uint256 _ratio = FIND();
        uint256 interest = _APY(month);
        rewardToken.transferFrom(ownerWallet, msg.sender, interest);
        rewardedToken[msg.sender] += interest;
    }

    function getStakingToken() public view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }

    function getSTAKEToken(address _add) public view returns (uint256) {
        return stakingToken.balanceOf(_add);
    }

    function REWARDEDToken() public view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }

    function getREWARDToken(address _add) public view returns (uint256) {
        return rewardToken.balanceOf(_add);
    }

    function getRewardToken() public view returns (uint256) {
        return rewardToken.balanceOf(ownerWallet);
    }

    function rewardAllowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return rewardToken.allowance(owner, spender);
    }

    function _compound(
        uint256 _principal,
        uint256 _ratio,
        uint256 _exponent
    ) public pure returns (uint256) {
        if (_exponent == 0) {
            return 0;
        }
        uint256 accruedReward = ABDKMath64x64.mulu(
            ABDKMath64x64.pow(
                ABDKMath64x64.add(
                    ABDKMath64x64.fromUInt(1),
                    ABDKMath64x64.divu(_ratio, 10**18)
                ),
                _exponent
            ),
            _principal
        );
        return accruedReward - _principal;
    }

    function FIND() public pure returns (uint256) {
        return (33 * 1e18) / 100;
    }

    function _APY(uint256 _n) public pure returns (uint256) {
        uint256 n = _n;
        return ((FIND() / 12) * n) * 100;
    }
}
