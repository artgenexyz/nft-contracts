// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ReferralNFT.sol";
import "./TierNFT.sol";

enum Tier {
    Standard, // default
    Elite,
    VIP,
    Prestige,
    President,
    Genesis
}

contract MoonNFT is ReferralNFT, TierNFT {

    constructor()
        AvatarNFT(
            0.08 ether, // starting price
            10000, // total
            0, // reserved
            20, // max tokens per mint
            "https://buildship-metadata-caffeinum-buildship.vercel.app/api/token/moon/",
            "NFT Moon Metaverse", "MOON"
        )
        ReferralNFT(3000 /* referral fee in 0.01% */)
        TierNFT(6)
        {}

    function initTiers(uint8) internal override {
        // data from OpenSea minted tokens
        _reservedByTier[TierId.wrap(uint8(Tier.Standard))] = 50; // 50 or 67
        _reservedByTier[TierId.wrap(uint8(Tier.Elite))] = 15;
        _reservedByTier[TierId.wrap(uint8(Tier.VIP))] = 9;
        _reservedByTier[TierId.wrap(uint8(Tier.Prestige))] = 6;
        _reservedByTier[TierId.wrap(uint8(Tier.President))] = 3;
        _reservedByTier[TierId.wrap(uint8(Tier.Genesis))] = 1;

        _priceByTier[TierId.wrap(uint8(Tier.Standard))] = 0.08 ether;
        _priceByTier[TierId.wrap(uint8(Tier.Elite))] = 0.2 ether;
        _priceByTier[TierId.wrap(uint8(Tier.VIP))] = 0.3 ether;
        _priceByTier[TierId.wrap(uint8(Tier.Prestige))] = 0.7 ether;
        _priceByTier[TierId.wrap(uint8(Tier.President))] = 1.2 ether;
        _priceByTier[TierId.wrap(uint8(Tier.Genesis))] = 100 ether; // isn't used, because only 1 and it's reserved

        // inverted!
        _tierRanges[TierId.wrap(uint8(Tier.Genesis))] = Range(0, 0);
        _tierRanges[TierId.wrap(uint8(Tier.President))] = Range(1, 10);
        _tierRanges[TierId.wrap(uint8(Tier.Prestige))] = Range(11, 110);
        _tierRanges[TierId.wrap(uint8(Tier.VIP))] = Range(111, 1110);
        _tierRanges[TierId.wrap(uint8(Tier.Elite))] = Range(1111, 3110);
        _tierRanges[TierId.wrap(uint8(Tier.Standard))] = Range(3111, 9999);
    }

    function mint(uint256, address payable) public payable override {
        require(false, "Not implemented");
    }

    function mint(TierId, uint256) public payable override {
        require(false, "Not implemented");
    }

    function mint(TierId tier, uint256 nTokens, address payable referral) whenSaleStarted public payable {
        super.mint(tier, nTokens);

        _updateReferral(nTokens, referral);

        // Balance is transferred right away at purchase
        require(payable(beneficiary).send(msg.value));
    }

    // ------ Overrides FOR TierNFT

    // Override works right-to-left, https://solidity-by-example.org/inheritance/
    function getReservedLeft() public view override(AvatarNFT, TierNFT) returns(uint256) {
        return super.getReservedLeft();
    }

    function getPrice() public view override(AvatarNFT, TierNFT) returns(uint256 price) {
        return super.getPrice();
    }

    function claimReserved(uint256 nTokens, address receiver) public pure override(AvatarNFT, TierNFT) {
        // require(false, "Not implemented");
        super.claimReserved(nTokens, receiver);
    }

    function setStartingIndex() public override(AvatarNFT, TierNFT) {
        super.setStartingIndex();
    }

    function mint(uint256 nTokens) public payable override(AvatarNFT, TierNFT) {
        super.mint(nTokens);
    }

}
