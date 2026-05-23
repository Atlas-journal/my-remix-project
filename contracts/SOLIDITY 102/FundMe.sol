//SPDX-License-Identifier: MIT

//Get funds from users, set a minimum fund value to 5 USD, withdraw funds from contract
pragma solidity 0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

//error NotOwner(); used to make contracts gas efficient by using if statement to revert the function call instead of calling a string which is more costly because all the characters are stored individually

contract FundMe{ 
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18; //the constant keyword is used in variable that are declared once to save gas cost, it is uppercase sensitive
    //347 * 308000000 constant = 106,876,000,000 wei = 0.000000106876 ETH = $0.00017
    //2446 * 308000000 non-constant = 753,368,000,000 wei = 0.000000753368 ETH = $0.00121

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address public immutable i_owner; //the immutable keyword is used in variables that exists once inside the constructor to save gas cost, it adds i_ to the variable name

    /*constant and immutable keyword saves gas cost because it stores variables in the bytecode of a contract instead of in a storage slot
    It's used in variables that can only be declared and updated once*/

    constructor () {
        i_owner = msg.sender; //msg.sender is the owner of the contract i.e. the constructor function makes sure the contract is only deployed by the owner address
    }

    //payable keyword allows the function to accept native blockchain token and act as a wallet address
    function fund() public payable { 
        //1e18 = 1 ETH = 10^18 wei
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH"); //"require" statement instructs the contract on what to do, reverts actions previously done and return gas used if failed
       //global message value assigns value to the statement
       funders.push(msg.sender);
       addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        //use of for loop with [1, 2, 3, 4] elements, 0, 1, 2, 3 index and (starting index; ending index; step amount)
        for(uint56 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //using the new keyword to reset the funders array to a brand new blank array
        funders = new address[](0);   
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Failed");

    /*
    using transfer, call or send keyword we can withdraw(recieve)/send funds(native blockchain currency/ ethereum currency) to owner/other contracts by calling the withdraw function
    payable(msg.sender).transfer(address(this).balance), transfer keyword revets if failed
    bool sendSuccess = payable(msg.sender).send(address(this).balance);
    require(sendSuccess, "Failed:); , send keyword returns a boolean if failed, therefore the require keyword is used to revert the keyword
    (bool callSuccess, ) = payable(msg.sender).call{address(this).balance}("");
    require(CallSuccess, "Failed"); , call keyword returns two variable
    */
    } 

    //the modifier keyword is used to add the same functionality to a number of functions  in a code
    modifier onlyOwner () {
        require(msg.sender == i_owner, "Must be owner"); // makes sure the withdraw function is only called by the contract owner and reverted if failed
        _;
        //if(msg.sender != i_owner) {revert NotOwner(); }
    }
    //recieve, fallback and constructor are special functions that don't require calling the function keyword
    /* the receive and fallback functions allows to fund (send native blockchain token) contract without calling the fund function
    The receive function is specifically designed to handle Ether transfers without data and is automatically invoked when Ether. 
    The fallback function is used for handling calls with data or when the receive function is not defined. 
    The fallback function can also handle Ether transfers with data.

    Is msg.data(call data) empty
           /    \
          yes    no
          /      \
      receive()  fallback()
    */
    receive() external payable {
        fund();
    }
   fallback() external payable {
    fund();
   }
}