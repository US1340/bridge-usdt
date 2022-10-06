// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function mint(address account, uint256 amount, bytes32 hash) external;
    function lock(address account, uint256 amount) external;
    function burnLock(address account, uint256 amount, bytes32 hash) external;
    function freeLock(address account, uint256 amount) external;
}