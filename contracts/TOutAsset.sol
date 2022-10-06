// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/IERC20.sol";
import "./OpenZeppelin/SafeERC20.sol";

contract TOutAsset is Ownable {
    uint256 private _outAmount;
    address private immutable _usdtContract;
    address private _outAccount;
    mapping(bytes32 => bool) private _hashUsed;

    constructor(address usdtAddress) {
        require(usdtAddress != address(0), 'invalid account');
        _usdtContract = usdtAddress;
    }

    function usdtContract() public view returns(address) {
        return _usdtContract;
    }

    function outAccount() public view returns(address) {
        return _outAccount;
    }
    
    function transfer(address to, uint256 amount, bytes32 hash) external onlyOwner{
        require(!_hashUsed[hash], "hash used");
        _hashUsed[hash] = true;
        _outAmount += amount;
        SafeERC20.safeTransferFrom(IERC20(_usdtContract), _outAccount, to, amount);
    }

    // set account for transfer out
    function setAccount(address account) external onlyOwner {
        require(account != address(0), 'invalid account');
        _outAccount = account;
    }

    // total amount token across this contract
    function outAmt() public onlyOwner view returns(uint256){
        return _outAmount;
    }

    // withdraw token in this contract
    function withdraw(address contractAddr, address to) external onlyOwner {
        // balance
        uint a = IERC20(contractAddr).balanceOf(address(this));
        if (a > 0) {
            SafeERC20.safeTransfer(IERC20(contractAddr), to, a);
        }
    }

    // available balance of bind account
    function balance() public view returns(uint256)
    {
        uint a = IERC20(_usdtContract).balanceOf(address(_outAccount));
        uint b = IERC20(_usdtContract).allowance(_outAccount, address(this));
        return a > b ? b : a;
    }
}