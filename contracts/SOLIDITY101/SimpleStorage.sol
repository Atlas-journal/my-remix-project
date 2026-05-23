//SPDX-License-Identifier: MIT
pragma solidity 0.8.24; //solidity version

contract SimpleStorage {
    //contract that allows input of favourite number
    uint256 myFavouriteNumber; //equals 0 since it doen't have any value(state or storage variable i.e internal variable)

    //uint256 [] listOfFavouriteNumbers;array for others to input favorite numbers
    struct Person{
        uint256 favouriteNumber;
        string name;
    }
    //dynamic array because the size could increase and shrink at any time while static array has a fixed number of elements in the array
    Person[] public  listOfPeople;
    mapping (string => uint256) public nameToFavoriteNumber; //maps a name to the unique number with 0 default
    
    //uses parameter to update the variable favorite number
    function store(uint256 _favouriteNumber ) public virtual {  //local or storage variable,"virtual" allows for virtual override
        myFavouriteNumber = _favouriteNumber; //retuns the value passed in the function as the new value for favorite number whenever the function is called
    }   

    //view(not in storage) & pure(in storage) reads the state of blockchain, disallows any modification or updating of state
    function retrieve() public view returns(uint256) {
        return myFavouriteNumber;
    }
     
    //calldata & memory(temporary), storage(permanent)
    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        listOfPeople.push( Person(_favouriteNumber, _name));
        nameToFavoriteNumber[_name] = _favouriteNumber;
    }
}