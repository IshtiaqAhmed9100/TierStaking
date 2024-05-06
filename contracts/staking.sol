// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ABDKMath64x64.sol";

contract Staking {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public startTime;

    address ownerWallet;
    
    mapping(address => uint256) public stakedToken;
    mapping(address => uint256) public rewardedToken;
    mapping(address => uint256) public userTier;

    constructor() {
        stakingToken = IERC20(0x0813d4a158d06784FDB48323344896B2B1aa0F85);
        rewardToken = IERC20(0xE5f2A565Ee0Aa9836B4c80a07C8b32aAd7978e22);
        startTime = block.timestamp;
        ownerWallet = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    }

    function stake(uint256 _tier, uint256 amount) public {
        require(stakedToken[msg.sender] == 0, "User already staked");

        userTier[msg.sender]= _tier;
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedToken[msg.sender] += amount;
    }
                                          

    function Unstake() public {
        uint256 monthsStaked = getMONTH(); // Calculate months staked
    
        uint256 tierSelect = userTier[msg.sender];
        if (tierSelect == 1) {
            // If not reached the lock time, return only reward
            (block.timestamp < startTime + 3 minutes) ? RewardTier(monthsStaked) : withdrawTier(3);
        } else if (tierSelect == 2) {
            // If not reached the lock time, return only reward
            (block.timestamp < startTime + 6 minutes) ? RewardTier(monthsStaked) : withdrawTier(6);
        } else if (tierSelect == 3) {
            // If not reached the lock time, return only reward
            (block.timestamp < startTime + 9 minutes) ? RewardTier3(monthsStaked) : withdrawTier3();
        }
    }

       function withdrawTier(uint256 month) private {
        uint256 tier = userTier[msg.sender];
        require(stakedToken[msg.sender] >= 0);
         uint256 _ratio;
        (tier ==1)? _ratio = 8333333333333333 : _ratio = 16666666666666666 ;
        uint256 interest = _compound(
            stakedToken[msg.sender] * 1e18,
            _ratio,
            month
        );
        uint256 totalAmount =  interest;
        uint256 finalAmount = totalAmount - rewardedToken[msg.sender];
        rewardToken.transferFrom(ownerWallet, msg.sender, finalAmount);
        rewardedToken[msg.sender] += finalAmount;
        stakingToken.transfer(msg.sender , stakedToken[msg.sender]);
        delete stakedToken[msg.sender];
    }

      function RewardTier(uint256 month) private {
        uint256 tier = userTier[msg.sender];
        require(stakedToken[msg.sender] >= 0);
        uint256 _ratio;
        (tier ==1)? _ratio = 8333333333333333 : _ratio = 16666666666666666;
        uint256 interest = _compound(
            stakedToken[msg.sender] * 1e18,
            _ratio,
            month
        );
        uint256 finalAmount= interest - rewardedToken[msg.sender];
        rewardToken.transferFrom(ownerWallet, msg.sender, finalAmount);
        rewardedToken[msg.sender] += finalAmount;
    }

    function withdrawTier3() private {
        require(stakedToken[msg.sender] >= 0);
        uint256 interest = _APY(9);
        uint256 totalAmount = (stakedToken[msg.sender] *  interest) / 1e18;
        uint256 finalAmount = totalAmount - rewardedToken[msg.sender];
        rewardToken.transferFrom(ownerWallet, msg.sender, finalAmount);
        stakingToken.transfer(msg.sender, stakedToken[msg.sender]);
        rewardedToken[msg.sender] += finalAmount;
        delete stakedToken[msg.sender];
    }

    function RewardTier3(uint256 month) private {
        require(stakedToken[msg.sender] >= 0);
        uint256 interest = _APY(month) * stakedToken[msg.sender];
        uint256 finalAmount= interest - rewardedToken[msg.sender];
        rewardToken.transferFrom(ownerWallet, msg.sender, finalAmount);
        rewardedToken[msg.sender] += finalAmount;
    }

    function getMONTH() private view returns (uint256){
           uint256 a= block.timestamp - startTime; // Calculate months staked
           return a/60;
    }

    function _compound(
        uint256 _principal,
        uint256 _ratio,
        uint256 _exponent
    ) private pure returns (uint256) {
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

    function FIND() private pure returns (uint256) {
        return (33 * 1e18) / 100;
    }

    function _APY(uint256 _n) public pure returns (uint256) {
        uint256 n = _n;
        return ((FIND() / 12) * n) ;
    }

}
