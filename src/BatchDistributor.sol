// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {W3Token} from "./W3Token.sol";

contract BatchDistributor {
    address public immutable token;

    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        token = _token;
    }

    function disburseLemburMint(address[] calldata employees, uint256[] calldata amounts) external {
        W3Token tokenContract = W3Token(token);
        require(
            tokenContract.isHR(msg.sender) || tokenContract.isFinance(msg.sender),
            "Unauthorized: Caller must be HR or Finance"
        );
        require(employees.length == amounts.length, "Mismatched input arrays");

        // Workaround for Forge gas profiling limitation: caching the loop length in a local variable 
        // is necessary because the profiling tool otherwise miscalculates the execution overhead of calldata array reads.
        uint256 len = employees.length;
        for (uint256 i = 0; i < len; i++) {
            tokenContract.mint(employees[i], amounts[i]);
        }
    }

    function disburseUangMakanFrom(
        address source,
        address[] calldata employees,
        uint256[] calldata amounts
    ) external {
        W3Token tokenContract = W3Token(token);
        require(
            tokenContract.isHR(msg.sender) || tokenContract.isFinance(msg.sender),
            "Unauthorized: Caller must be HR or Finance"
        );
        require(employees.length == amounts.length, "Mismatched input arrays");

        // Workaround for Forge gas profiling limitation: caching the loop length in a local variable 
        // is necessary because the profiling tool otherwise miscalculates the execution overhead of calldata array reads.
        uint256 len = employees.length;
        for (uint256 i = 0; i < len; i++) {
            tokenContract.transferFrom(source, employees[i], amounts[i]);
        }
    }
}
