// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline;
    bool public openForWithdraw;

    event Staked(address indexed staker, uint256 amount);
    event Withdrawn(address indexed withdrawer, uint256 amount);
    event StakingCompleted(uint256 totalStaked);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 72 hours;
  }

  function stake() public payable{
    require(block.timestamp < deadline, "Staking period has ended");
    balances[msg.sender] += msg.value;
    emit Staked(msg.sender, msg.value);
  }

  function withdraw() public{
    require(openForWithdraw, "Withdrawal is not available yet");
    require(balances[msg.sender] > 0, "No balances to withdraw");

    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Withdrawal fail");
    emit Withdrawn(msg.sender, amount);
  }

  function executeStaking() public {
    require(block.timestamp >= deadline, "Staking has not ended");
    require(!openForWithdraw, "Staking has already been executed");

    if(address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
            emit StakingCompleted(address(this).balance);
        } else {
            openForWithdraw = true;
        }
    }
  
   function getBalance() public view returns(uint256){
    return balances[msg.sender];
   }

   function timeLeft() public view returns(uint256){
     if (block.timestamp >= deadline) {
      return 0;
     }
     return deadline - block.timestamp;
   }

   receive() external payable{
    stake();
   }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
