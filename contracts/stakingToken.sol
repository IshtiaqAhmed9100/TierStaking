// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is Ownable, ERC20 {


  constructor() Ownable(msg.sender) ERC20("StakingToken","ST"){}

  function mint() public {
    _mint(msg.sender, 1000 * (10 **18));
  }

  function checkBalance() public view returns (uint256){

    return balanceOf(msg.sender);
  }
    
  }  