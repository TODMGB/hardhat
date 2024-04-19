// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MyContract {
    uint A;
    uint B;
    uint C;
    
    function setA(uint _A) external {
        A = _A;
    } 

    function setB(uint _B) external {
        B = _B;
    } 

    function setC(uint _C) external {
        C = _C;
    } 

    function getD() external view returns (uint) {
        return A + B - C;
    }

    function getE() external view returns (uint) {
        return A * B - C;
    }
}
