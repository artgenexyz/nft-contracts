// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./AvatarNFT.sol";

type TierId is uint8;

// TODO: remove or store for reference in contract
// struct TierInfo {
//     string name;
// }

struct Range {
    uint128 start;
    uint128 end;
}

abstract contract TierNFT is AvatarNFT {
    mapping (TierId => uint256) internal _supplyByTier;

    // IMPORTANT: must be set in initTiers!
    mapping (TierId => Range) internal _tierRanges;
    mapping (TierId => uint256) internal _priceByTier;
    mapping (TierId => uint256) internal _reservedByTier;

    TierId immutable FIRST_TIER;
    TierId immutable LAST_TIER;

    constructor (uint8 tierLength) {
        initTiers(tierLength);

        // TODO: check arrays have same length
        // TODO: TEST the tiers you can create this way

        FIRST_TIER = TierId.wrap(0);
        LAST_TIER = TierId.wrap(tierLength - 1);

        for (uint8 i = TierId.unwrap(FIRST_TIER); i < TierId.unwrap(LAST_TIER); i++) {
            TierId nextTier = TierId.wrap(i + 1);
            TierId tier = TierId.wrap(i);

            // check that the tier ranges are sorted
            // but keep in mind they go backwards
            require(_tierRanges[nextTier].start < _tierRanges[tier].start, "Tier ranges must be sorted");
            // check that the tier ranges are connected and not overlapping
            require(_tierRanges[nextTier].end + 1 == _tierRanges[tier].start, "Tier ranges must not overlap and should connect seamlessly");

            // check that the tier ranges are non-empty
            require(_tierRanges[tier].start < _tierRanges[tier].end, "Tier ranges must not be empty");

        }

        // check that prices aren't zero

        for (uint8 i = TierId.unwrap(FIRST_TIER); i <= TierId.unwrap(LAST_TIER); i++) {
            TierId tier = TierId.wrap(i);
            require(_priceByTier[tier] > 0, "Tier prices must be greater than zero");
        }

    }

    function initTiers(uint8 tierLength) internal virtual;

    // function getPrice(Tier tier) public view returns (uint256) {
    //     if (tier == Tier.Genesis) return 100 ether; // isn't used, because only 1 and it's reserved
    //     if (tier == Tier.President) return 1.2 ether;
    //     if (tier == Tier.Prestige) return 0.7 ether;
    //     if (tier == Tier.VIP) return 0.3 ether;
    //     if (tier == Tier.Elite) return 0.2 ether;

    //     return getPrice(); // 0.08 ether
    // }

    // Ranges for the tokens:
    // Only 10 tokens are President, tokenId = 0-9
    // Only 100 tokens are Prestige, tokenId = 10-109
    // Only 1000 tokens are VIP, tokenId = 110-1109
    // Only 3000 tokens are Elite, tokenId = 1110-3109
    // Other tokens are Standard, up to tokenId = 9999
    // function getRange(Tier tier) public pure returns (uint256, uint256) {
    //     if (tier == Tier.Genesis) return (0, 1);
    //     if (tier == Tier.President) return (1, 10);
    //     if (tier == Tier.Prestige) return (11, 110);
    //     if (tier == Tier.VIP) return (111, 1110);
    //     if (tier == Tier.Elite) return (1111, 3110);
    //     return (3111, 9999);
    // }

    // function getSupply(Tier tier) public view returns(uint256) {
    //     return _supplyByTier[tier];
    // }

    // function getMaxSupply(Tier tier) public pure returns(uint256) {
    //     if (tier == Tier.Genesis) return 1;
    //     if (tier == Tier.President) return 10;
    //     if (tier == Tier.Prestige) return 100;
    //     if (tier == Tier.VIP) return 1000;
    //     if (tier == Tier.Elite) return 3000;
    //     return 5889;
    // }

    //     // total of reserved left
    //     uint256 total = 0;

    //     total += _reservedByTier[Tier.Standard];
    //     total += _reservedByTier[Tier.Elite];
    //     total += _reservedByTier[Tier.VIP];
    //     total += _reservedByTier[Tier.Prestige];
    //     total += _reservedByTier[Tier.President];
    //     total += _reservedByTier[Tier.Genesis];

    //     return total;
    // }



    // function claimReserved(Tier tier, uint256 _number, address _receiver) public {
    //     require(_number <= _reservedByTier[tier], "That would exceed the max reserved.");

    //     uint256 start;
    //     (start, ) = getRange(tier);
    //     uint256 supply = getSupply(tier);

    //     for (uint256 i; i < _number; i++) {
    //         // Be careful! Should always update _supplyByTier when minting!
    //         _supplyByTier[tier] += 1;
    //         _safeMint(_receiver, start + supply + i);
    //     }
    //     _reservedByTier[tier] -= _number;
    // }

    function getTier(uint256 tokenId) public view returns (TierId) {
        for (uint8 i = TierId.unwrap(FIRST_TIER); i < TierId.unwrap(LAST_TIER); i++) {
            TierId tier = TierId.wrap(i);

            if (tokenId >= _tierRanges[tier].start && tokenId < _tierRanges[tier].end) {
                return tier;
            }
        }

        require(false, "TokenId not found in any tier");

        return TierId.wrap(0);
    }

    function getPrice() public view override virtual returns (uint256) {
        return getPrice(FIRST_TIER);
    }

    function getPrice(TierId tier) public view returns (uint256) {
        require(TierId.unwrap(tier) >= TierId.unwrap(FIRST_TIER) && TierId.unwrap(tier) <= TierId.unwrap(LAST_TIER), "Invalid tier.");

        return _priceByTier[tier];

        // if (tier == Tier.Genesis) return 100 ether; // isn't used, because only 1 and it's reserved
        // if (tier == Tier.President) return 1.2 ether;
        // if (tier == Tier.Prestige) return 0.7 ether;
        // if (tier == Tier.VIP) return 0.3 ether;
        // if (tier == Tier.Elite) return 0.2 ether;

        // return getPrice(); // 0.08 ether
    }

    // Ranges for the tokens:
    // Only 10 tokens are President, tokenId = 0-9
    // Only 100 tokens are Prestige, tokenId = 10-109
    // Only 1000 tokens are VIP, tokenId = 110-1109
    // Only 3000 tokens are Elite, tokenId = 1110-3109
    // Other tokens are Standard, up to tokenId = 9999
    function getRange(TierId tier) public view returns (uint256, uint256) {
        return (_tierRanges[tier].start, _tierRanges[tier].end);

        // if (tier == Tier.Genesis) return (0, 0);
        // if (tier == Tier.President) return (1, 10);
        // if (tier == Tier.Prestige) return (11, 110);
        // if (tier == Tier.VIP) return (111, 1110);
        // if (tier == Tier.Elite) return (1111, 3110);
        // return (3111, 9999);
    }

    function getSupply(TierId tier) public view returns(uint256) {
        return _supplyByTier[tier];
    }

    function getMaxSupply(TierId tier) public view returns(uint256) {
        (uint256 start, uint256 end) = getRange(tier);

        return end - start + 1; // to include range start

        // if (tier == Tier.Genesis) return 1;
        // if (tier == Tier.President) return 10;
        // if (tier == Tier.Prestige) return 100;
        // if (tier == Tier.VIP) return 1000;
        // if (tier == Tier.Elite) return 3000;
        // return 5889;
    }

    function getReservedLeft() public view override virtual returns(uint256) {
        // total of reserved left
        uint256 total = 0;

        for (uint8 i = TierId.unwrap(FIRST_TIER); i <= TierId.unwrap(LAST_TIER); i++) {
            total += _reservedByTier[ TierId.wrap(i) ];
        }

        // total += _reservedByTier[Tier.Standard];
        // total += _reservedByTier[Tier.Elite];
        // total += _reservedByTier[Tier.VIP];
        // total += _reservedByTier[Tier.Prestige];
        // total += _reservedByTier[Tier.President];
        // total += _reservedByTier[Tier.Genesis];

        return total;
    }

    function getReservedLeft(TierId tier) public view returns(uint256) {
        return _reservedByTier[tier];
    }

    // IMPORTANT to remove this functionality, otherwise it will mess up tier system
    function setStartingIndex() public override virtual {
        startingIndex = 0;
    }

    function claimReserved(uint256, address) public pure override virtual {
        require(false, "Not implemented");
    }

    function claimReserved(TierId tier, uint256 _number, address _receiver) public {
        require(TierId.unwrap(tier) >= TierId.unwrap(FIRST_TIER) && TierId.unwrap(tier) <= TierId.unwrap(LAST_TIER), "Invalid tier.");

        require(_number <= _reservedByTier[tier], "That would exceed the max reserved.");

        uint256 start;
        (start, ) = getRange(tier);
        uint256 supply = getSupply(tier);

        for (uint256 i; i < _number; i++) {
            // Be careful! Should always update _supplyByTier when minting!
            _supplyByTier[tier] += 1;
            _safeMint(_receiver, start + supply + i);
        }

        _reservedByTier[tier] -= _number;
    }

    function mint(uint256) public payable override virtual {
        require(false, "Not implemented");
    }

    function mint(TierId tier, uint256 nTokens) whenSaleStarted public payable virtual {
        require(TierId.unwrap(tier) >= TierId.unwrap(FIRST_TIER) && TierId.unwrap(tier) <= TierId.unwrap(LAST_TIER), "Invalid tier.");

        uint256 supply = getSupply(tier);
        uint256 price = getPrice(tier);
        uint256 start;
        (start, ) = getRange(tier);

        require(nTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + nTokens <= getMaxSupply(tier) - getReservedLeft(tier), "Not enough Tokens left.");
        require(nTokens * price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < nTokens; i++) {
            // Be careful! Should always update _supplyByTier when minting!
            _supplyByTier[tier] += 1;
            _safeMint(msg.sender, start + supply + i);
        }

    }


}
