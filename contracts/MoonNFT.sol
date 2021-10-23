// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ReferralNFT.sol";

enum Tier {
    Standard, // default
    Elite,
    VIP,
    Prestige,
    President
}

contract MoonNFT is ReferralNFT {
    mapping (Tier => uint256) tierSupply;

    constructor() ReferralNFT(
        0.05 ether, // starting price
        10000, // total
        0, // reserved
        20, // max tokens per mint
        200, // referral fee in 0.01%
        "https://metadata.buildship.dev/api/token/moon", "NFT Moon Metaverse", "MOON"
    ) {}

    function getPrice(Tier tier) public view returns (uint256) {
        if (tier == Tier.President) return 5 ether;
        if (tier == Tier.Prestige) return 1 ether;
        if (tier == Tier.VIP) return 0.5 ether;
        if (tier == Tier.Elite) return 0.2 ether;

        return getPrice();
    }

    // Ranges for the tokens:
    // Only 10 tokens are President, tokenId = 0-9
    // Only 100 tokens are Prestige, tokenId = 10-109
    // Only 1000 tokens are VIP, tokenId = 110-1109
    // Only 3000 tokens are Elite, tokenId = 1110-3109
    // Other tokens are Standard, up to tokenId = 9999
    function getRange(Tier tier) public pure returns (uint256, uint256) {
        if (tier == Tier.President) return (1, 10);
        if (tier == Tier.Prestige) return (11, 110);
        if (tier == Tier.VIP) return (111, 1110);
        if (tier == Tier.Elite) return (1111, 3110);
        return (3111, 9999);
    }

    function getSupply(Tier tier) public view returns(uint256) {
        return tierSupply[tier];
    }

    function getMaxSupply(Tier tier) public pure returns(uint256) {
        if (tier == Tier.President) return 10;
        if (tier == Tier.Prestige) return 100;
        if (tier == Tier.VIP) return 1000;
        if (tier == Tier.Elite) return 3000;
        return 5889;
    }

    // function getNextTokenId(Tier tier) public view returns(uint256) {
    //     uint256 start;
    //     (start, ) = getRange(tier);

    //     require(start + getSupply(tier) < getMaxSupply(tier), "Tier supply is full");
    //     return start + getSupply(tier);
    // }

    function setStartingIndex() public override {
        startingIndex = 0;
    }

    function mint(uint256) public payable override {
        require(false, "Not implemented");
    }

    function mintReferral(uint256, address payable
    ) public payable override {
        require(false, "Not implemented");
    }

    function mintTierReferral(Tier tier, uint256 nTokens, address payable referral) whenSaleStarted public payable {
        uint256 supply = getSupply(tier);
        uint256 price = getPrice(tier);
        uint256 start;
        (start, ) = getRange(tier);

        require(nTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + nTokens <= getMaxSupply(tier), "Not enough Tokens left.");
        require(nTokens * price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < nTokens; i++) {
            // Be careful! Should always update tierSupply when minting!
            tierSupply[tier] += 1;
            _safeMint(msg.sender, start + supply + i);
        }

        // Verify its correct referral
        // Send referral amount
        // TODO: check reentrancy
        if (referral != msg.sender && referral != owner()) {
            userTotalReferrals[referral] += nTokens;
            pendingWithdrawals[referral] += msg.value * REFERRAL_PERCENT / 10000;
        }

    }


}
