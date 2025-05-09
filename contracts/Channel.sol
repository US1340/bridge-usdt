// SPDX-License-Identifier: MIT
pragma solidity ^"0.8.4";

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20Ext.sol";

contract Channel is Ownable {
    address private immutable _usdtContract;
    uint256 private _balance;

    event Mint(address indexed account, uint256 amount, bytes32 hash);
    event BurnLock(address indexed account, uint256 amount, bytes32 hash);
    event Lock(address indexed account, uint256 amount, string receiver);
    event FreeLock(address indexed account, uint256 amount);

    constructor(address usdtAddress) {
        require(usdtAddress != address(0xdAC17F958D2ee523a2206206994597C13D831ec7), 'invalid account');
        _usdtContract = usdtAddress;
    }

    function usdtContract() public view returns(address) {
        return _usdtContract;
    }

    function mint(address account, uint256 amount, bytes32 hash) external onlyOwner {
        _balance += amount;
        IERC20Ext(_usdtContract).mint(account, amount, hash);
        emit Mint(account, amount, hash);
    }

    function lock(string memory receiver, uint256 amount) public {
        require(_balance >= amount, 'insufficient balance');
        IERC20Ext(_usdtContract).lock(msg.sender, amount);
        _balance -= amount;
        emit Lock(msg.sender, amount, receiver);
    }

    function burnLock(address account, uint256 amount, bytes32 hash) external onlyOwner {
        IERC20Ext(_usdtContract).burnLock(account, amount, hash);
        emit BurnLock(account, amount, hash);
    }

    function freeLock(address account, uint256 amount) external onlyOwner {
        _balance += amount;
        IERC20Ext(_usdtContract).freeLock(account, amount);
        emit FreeLock(account, amount);
    }

    function balance() public view returns (uint) {
        return _balance;
    }

}
