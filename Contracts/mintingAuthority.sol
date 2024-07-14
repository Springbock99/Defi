// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MintingAuthority
 * @dev A contract that facilitates the minting of NFTs with a specified payment token.
 */
contract MintingAuthority is Ownable {
    address private _nftContractAddress;
    IERC20 private _paymentToken;
    uint256 public constant PRICE = 10 * 1e18;
    uint256 public totalsupply = 0;

    /**
     * @dev Constructor that initializes the MintingAuthority contract.
     * @param erc20 The address of the ERC20 payment token.
     * @param nftContractAddress The address of the NFT contract.
     */
    constructor(address erc20, address nftContractAddress) Ownable() {
        _paymentToken = IERC20(erc20);
        _nftContractAddress = nftContractAddress;
    }

    /**
     * @dev Mint an NFT with payment using the specified payment token.
     * @param to The address to mint the NFT to.
     */
    function mintWithPayment(address to) external payable {
        _paymentToken.transferFrom(msg.sender, address(this), PRICE);
        MyNFT(_nftContractAddress).mint(to);
        totalsupply++;
    }

    /**
     * @dev Withdraw ERC20 tokens from the contract, restricted to the owner.
     * @param to The address to withdraw tokens to.
     * @param amount The amount of ERC20 tokens to withdraw.
     */
    function withdrawERC20(address to, uint256 amount) external onlyOwner {
        require(_paymentToken.transfer(to, amount), "Token transfer failed");
    }
}