// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { Ownable } from "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import { MyERC20 } from "./MyERC20.sol";
/*
"TokenShop" is a smart contract that enables users to purchase tokens. 
It will use the ETH/USD price feed to calculate how many tokens to issue to a purchaser, based on the amount of ETH they pay.
It will: Query the current ETH/USD exchange rate.
Calculate the USD value of the sent ETH.
Determine the appropriate amount of tokens to mint based on our fixed USD token price.
Mint and transfer the calculated tokens directly to the buyer.
*/
contract TokenShop is Ownable {
    AggregatorV3Interface internal immutable i_priceFeed;
    MyERC20 public immutable i_token;
    
    uint256 public constant TOKEN_DECIMALS = 18;
    uint256 public constant TOKEN_USD_PRICE = 2 * 10 ** TOKEN_DECIMALS; // 2 USD with 18 decimals
    
    event BalanceWithdrawn();
    error TokenShop__ZeroETHSent();
    error TokenShop__CouldNotWithdraw();
    
    constructor(address tokenAddress) Ownable() {
        i_token = MyERC20(tokenAddress);
        /*
        Network: Sepolia
        Aggregator: ETH/USD
        Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        i_priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
    /* we have set the msg.sender to be the contract owner Ownable(msg.sender)
    This will be the address deploying the contract since the constructor is invoked by the deployer automatically when the contract is deployed.
    We need our contract to have an owner. 
    To do this, we will inherit a smart contract from OpenZeppelin that sets the address passed to the Ownable constructor to an internal state variable called _owner. 
    This owner address is accessible using the external owner function.
    This allows us to use the onlyOwner modifier from the Owner contract to prevent anyone but the contract owner from calling functions with this modifier.
    */

    receive() external payable {
        /*
        When a user sends ETH to our contract, the receive function will capture that ETH, calculate how many tokens they should get based on the current exchange rate, and then mint those tokens to the sender's address. 
        This creates a simple way for users to swap their ETH for our custom token without needing to call a specific function.
        They can send ETH directly to the contract address using a standard transaction.
        */
        if (msg.value == 0) {
            /*We have also added a check that the user hasn't called the contract and sent 0 ETH. 
            If they have, we have reverted with a custom error.
            */
            revert TokenShop__ZeroETHSent();
        }
        // convert the ETH sent to the contract to a token amount to mint and then mint the tokens
        i_token.mint(msg.sender, amountToMint(msg.value));
    }

    function amountToMint(uint256 amountInETH) public view returns (uint256) {
        // Sent amountETH, convert to USD amount
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer()) * 10 ** 10; // ETH/USD price with 8 decimal places -> 18 decimals
        uint256 ethAmountInUSD = amountInETH * ethUsd / 10 ** 18; // ETH = 18 decimals
        return (ethAmountInUSD * 10 ** TOKEN_DECIMALS) / TOKEN_USD_PRICE; // * 10 ** TOKEN_DECIMALS since tokenAmount needs to be in TOKEN_DECIMALS
    }
    /*
    Returns the latest answer, called the latestRountData function on the specific price feed address we set in the constructor. 
    Since we only need the price, the other return values have been commented out.
    */
    
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = i_priceFeed.latestRoundData();
        return price;
    }

    function withdraw() external onlyOwner {
        // low level calls can be done on payable addresses
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        if (!success) {
            revert TokenShop__CouldNotWithdraw();
        }
        emit BalanceWithdrawn();
    }
} 
