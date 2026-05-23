// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract MatricNo {
    struct student{
        uint256 matricNumber;
        string fullName;
        string department;
        uint256 level;
    }

    student[] public arrayOfStudents;
    mapping (string => uint256) public fullNameToMatricNumber;

    function addNewStudent (uint256 _matricNumber, string memory _fullName, string memory _department, uint256 _level) public{
        arrayOfStudents.push( student(_level, _department, _fullName, _matricNumber));
        fullNameToMatricNumber[_fullName] = _matricNumber;
    }
}