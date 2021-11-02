// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "../MintPass.sol";

import "./AmeegosNFTv2.sol";

// - 6000 mint passes max
// - free to claim, up to 10 per address
// - each one allows to buy one Ameegos
// - mint pass opens today, claimable until 26 Oct (or 24 Oct?)
// - sale for mint pass users opens 24 Oct, and closes 26 Oct

// - To make this possible, we have a trick where old contract “whitelists” mintpass smart-contract, and he channels through the minting 

contract AmeegosMintPassv2 is MintPass {
    AmeegosNFTv2 immutable public originalContract;

    constructor (AmeegosNFTv2 original) MintPass(6000, 10, "https://metadata.buildship.dev/api/token/ameegos-mint-pass/{id}") {
        originalContract = original;
    }

    // Free issue to airdrop mint passes to old holders
    function issue(uint256 amount, address to) public onlyOwner {
        require(amount > 0, "Too few tokens");
        require(mintedSupply + amount <= maxSupply, "Already minted too much tokens");
        require(mintedPerAddress[to] + amount <= maxPerAddress, "Too many tokens per address");

        mintedSupply += amount;
        mintedPerAddress[to] += amount;

        _mint(to, MINT_PASS_ID, amount, "");
    }

    function redeem(uint256 amount) public whenSaleStarted payable {
        // No need to check, because _burn will fail anyway
        // require(amount <= balanceOf(msg.sender, MINT_PASS_ID), "Not enough mint pass");

        _burn(msg.sender, MINT_PASS_ID, amount);

        originalContract.mintRestricted{ value: msg.value }(amount, msg.sender);
    }

}