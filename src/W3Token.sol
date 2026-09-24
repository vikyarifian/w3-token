// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract W3Token {
    string public constant name = "W3 Allowance Token";
    string public constant symbol = "W3AT";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    mapping(address => bool) public isHR;
    mapping(address => bool) public isFinance;
    bool public paused;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event HRStatusChanged(address indexed account, bool status);
    event FinanceStatusChanged(address indexed account, bool status);
    event PauseStatusChanged(bool paused);

    constructor() {
        owner = msg.sender;
    }

    function setHR(address account, bool status) external {
        // Workaround for Forge coverage limitation: coverage tool fails to track branch coverage
        // accurately when using modifiers, so we use explicit inline require statements here.
        require(msg.sender == owner, "Unauthorized: Only owner");
        isHR[account] = status;
        emit HRStatusChanged(account, status);
    }

    function setFinance(address account, bool status) external {
        require(msg.sender == owner, "Unauthorized: Only owner");
        isFinance[account] = status;
        emit FinanceStatusChanged(account, status);
    }

    function setPaused(bool _paused) external {
        require(msg.sender == owner || isHR[msg.sender] || isFinance[msg.sender], "Unauthorized");
        paused = _paused;
        emit PauseStatusChanged(_paused);
    }

    function mint(address to, uint256 amount) external {
        require(isHR[msg.sender] || isFinance[msg.sender], "Unauthorized: Not HR or Finance");
        require(to != address(0), "Cannot mint to zero address");
        
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(isHR[msg.sender] || isFinance[msg.sender], "Unauthorized: Not HR or Finance");
        require(from != address(0), "Cannot burn from zero address");
        require(balanceOf[from] >= amount, "Burn amount exceeds balance");

        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(!paused, "Transfers are temporarily paused for reconciliation");
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Approve to zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(!paused, "Transfers are temporarily paused for reconciliation");
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[from] >= amount, "Insufficient balance");
        
        uint256 currentAllowance = allowance[from][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            allowance[from][msg.sender] = currentAllowance - amount;
        }

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}
