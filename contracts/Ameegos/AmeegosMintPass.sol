// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "../MintPass.sol";

import "./AmeegosNFT.sol";


// - 6000 mint passes max
// - free to claim, up to 10 per address
// - each one allows to buy one Ameegos
// - mint pass opens today, claimable until 26 Oct (or 24 Oct?)
// - sale for mint pass users opens 24 Oct, and closes 26 Oct

// - To make this possible, we have a trick where old contract “whitelists” mintpass smart-contract, and he channels through the minting 

contract AmeegosMintPass is MintPass, ERC721Holder {
    AmeegosNFT immutable public originalContract;

    constructor (AmeegosNFT original) MintPass(6000, 10, "https://metadata.buildship.dev/api/token/ameegos-mint-pass/{id}") {
        originalContract = original;
    }

    function redeem(uint256 amount) public whenSaleStarted payable {
        require(originalContract.balanceOf(address(this)) == 0, "Broken state, minting paused");
        require(originalContract.isWhitelisted(address(this)), "Minting failed");
        require(originalContract.onlyWhitelisted(), "Public sale started");

        // No need to check, because _burn will fail anyway
        // require(amount <= balanceOf(msg.sender, MINT_PASS_ID), "Not enough mint pass");

        _burn(msg.sender, MINT_PASS_ID, amount);

        originalContract.mint{ value: msg.value }(amount);

        require(originalContract.balanceOf(address(this)) == amount, "Broken state, minted less than requested");

        // transfer all AmeegosNFT tokens to msg.sender
        flushTokens(msg.sender);

        // require(originalContract.balanceOf(address(this)) == 0, "Broken state, shouldn't have tokens");
    }

    // @notice Should never be called under normal circumstances!
    function emergencyWithdraw(address to) public onlyOwner {
        flushTokens(to);
    }

    function flushTokens(address receiver) private {
        uint256 nextTokenId;
        uint256 balance = originalContract.balanceOf(address(this));

        while (balance > 0) {
            nextTokenId = originalContract.tokenOfOwnerByIndex(address(this), 0);

            originalContract.safeTransferFrom(address(this), receiver, nextTokenId);

            balance -= 1;
        }
    }
}