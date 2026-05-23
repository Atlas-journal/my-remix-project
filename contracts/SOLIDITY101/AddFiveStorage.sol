//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {SimpleStorage} from "./SimpleStorage.sol"; 

//inheritance, when another contract possesses all the functionality of the imported contract
contract AddFiveStorage is SimpleStorage { 

    //overrides the functionality of a function in the imported contract by using "override" in the child contract and "virtual" in the parent contract as keywords
    function store(uint256 _newNumber) public override {
        myFavouriteNumber = _newNumber + 5;
    }
}