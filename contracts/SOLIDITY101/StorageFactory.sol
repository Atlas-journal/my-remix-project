// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {SimpleStorage} from "./SimpleStorage.sol"; //named imports

contract StorageFactory {

    SimpleStorage[] public listOfSimpleStorageContracts; //the contract creates an internal variable

    //creates new versions of the imported contract from another contract
    function createSimpleStorage() public{
        //the "new" keyword helps to deploy contract from other contracts
        SimpleStorage newSimpleStorageContract = new SimpleStorage(); //the variable assigns the contract as the value so whenever the function is called the contract is deployed
        listOfSimpleStorageContracts.push(newSimpleStorageContract);// this adds the contract to the internal list of contracts
    }

    //use of ABI Application Binary Interface, which tells the code how it can interact with imported contracts
    function sfStore(uint256 _simpleStorageIndex, uint256 _newSimpleStorageNumber) public { //stores a number of the imported contracts using index key (address & ABI)
        listOfSimpleStorageContracts[_simpleStorageIndex].store(_newSimpleStorageNumber);
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) { //retrieves the number stored by inputting the index key
        return listOfSimpleStorageContracts[_simpleStorageIndex].retrieve();
    }
}