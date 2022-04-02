// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress)  {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 1 ether;

  bool public openForWithdraw = false;

  // uint256 public deadline = block.timestamp + 10 minutes;
  uint256 public deadline = block.timestamp + 72 hours;

  event Stake(address indexed addr, uint256 amnt); // event for staking

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
      function stake() public payable {
        // Require amount greater than 0
        require(msg.value > 0, "amount cannot be 0");

        // Update staking balance
        balances[msg.sender] = balances[msg.sender] + msg.value;

        emit Stake(msg.sender, msg.value);
    }

    function execute() public notCompleted{
      if(address(this).balance >= threshold){
        // exampleExternalContract.complete();
        exampleExternalContract.complete{value: address(this).balance}();
      }else{
        openForWithdraw = true;
      }
    }

    function withdraw() public notCompleted{
      uint256 userBalance = balances[msg.sender]; 
      require(userBalance > 0, "You haven't staked anything yet");
 
      balances[msg.sender] = 0; 
      (bool withdrawn,) = msg.sender.call{value: userBalance}("");
      require(withdrawn, "Withdrawal failed");
    }

    function timeLeft() public view returns (uint256) {
      if (block.timestamp >= deadline){
        return 0;
      }else{
        return deadline - block.timestamp;
      }
    }

    receive() external payable{
        return stake();
    }

    modifier notCompleted() {
      bool completed = exampleExternalContract.completed();
      require(!completed, "staking process already accomplished");
      _;
    }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}
