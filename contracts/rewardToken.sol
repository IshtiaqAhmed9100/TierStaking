// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is Ownable, ERC20 {


  constructor() Ownable(msg.sender) ERC20("RewardToken","RT"){}

  function mint() public {
    _mint(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1000 * (10 **18));
  }
    
  }  