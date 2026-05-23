//SPDX-License-Identifier: MIT

pragma solidity  0.8.24;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    //getting the price equivalent of USD to ETH by getting information from chainlink datafeeds
    function getPrice() internal  view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        //price of USD to ETH with 8 decimal places
        (,int256 price,,,) = priceFeed.latestRoundData();
        //8 decimal places converted to 18 decimal place
        return uint256(price * 1e10);
    }
    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256){
        //defines a set of functions that must be implemented by another contract, it interacts with the contract at the given address by providing a common interface
        return AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF).version();
    }
}