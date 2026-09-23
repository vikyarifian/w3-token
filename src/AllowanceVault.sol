// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {W3Token} from "./W3Token.sol";

contract AllowanceVault {
    address public immutable token;

    // Track quarterly (triwulan) allowance allocations for each employee
    mapping(address => uint256) public triwulanAllocation;

    event AllocationUpdated(address indexed employee, uint256 amount);
    event AllocationClaimed(address indexed employee, uint256 amount);

    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        token = _token;
    }

    function setTriwulanAllocation(address employee, uint256 amount) external {
        W3Token tokenContract = W3Token(token);
        require(
            tokenContract.isFinance(msg.sender) || msg.sender == tokenContract.owner(),
            "Unauthorized: Only Finance or Owner can set allocations"
        );
        triwulanAllocation[employee] = amount;
        emit AllocationUpdated(employee, amount);
    }

    function claimTriwulan() external {
        uint256 amount = triwulanAllocation[msg.sender];
        require(amount > 0, "No triwulan allowance allocated");

        triwulanAllocation[msg.sender] = 0;
        W3Token(token).mint(msg.sender, amount);
        emit AllocationClaimed(msg.sender, amount);
    }
}
