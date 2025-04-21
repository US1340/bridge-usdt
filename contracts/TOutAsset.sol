// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TOutAsset is Ownable {
    uint256 private _outAmount;
    address private immutable _usdtContract;
    address private _outAccount;
    mapping(bytes32 => bool) private _hashUsed;

    constructor('0xdAC17F958D2ee523a2206206994597C13D831ec7') {
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

const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Déploiement avec le compte :", deployer.address);

  const TOutAsset = await hre.ethers.getContractFactory("TOutAsset");
  const tOutAsset = await TOutAsset.deploy("0xAdresseDuContratUSDT");

  await tOutAsset.deployed();

  console.log("TOutAsset déployé à :", tOutAsset.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
