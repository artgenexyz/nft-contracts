// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFT.sol";

// TODO: refactor to support different tiers
enum Tier {
    Standard, // default
    Elite,
    VIP,
    Prestige,
    President,
    Genesis
}

struct Range {
    uint128 start;
    uint128 end;
}

abstract contract TierNFT is AvatarNFT {
    mapping (Tier => uint256) internal _supplyByTier;

    // IMPORTANT: must be set in initTiers!
    mapping (Tier => Range) internal _tierRanges;
    mapping (Tier => uint256) internal _priceByTier;
    mapping (Tier => uint256) internal _reservedByTier;

    constructor () {
        initTiers();

        for (uint256 i = uint(Tier.Standard); i < uint(Tier.Genesis); i++) {
            Tier nextTier = Tier(i + 1);
            Tier tier = Tier(i);

            // check that the tier ranges are sorted
            // but keep in mind they go backwards
            require(_tierRanges[nextTier].start < _tierRanges[tier].start, "Tier ranges must be sorted");
            // check that the tier ranges are connected and not overlapping
            require(_tierRanges[nextTier].end + 1 == _tierRanges[tier].start, "Tier ranges must not overlap and should connect seamlessly");

            // check that the tier ranges are non-empty
            require(_tierRanges[tier].start < _tierRanges[tier].end, "Tier ranges must not be empty");

        }

        // check that prices aren't zero
        for (uint256 i = uint(Tier.Standard); i <= uint(Tier.Genesis); i++) {
            Tier tier = Tier(i);
            require(_priceByTier[tier] > 0, "Tier prices must be greater than zero");
        }

    }

    function initTiers() internal virtual;

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

    function getPrice() public view override virtual returns (uint256) {
        return getPrice(Tier.Standard);
    }

    function getPrice(Tier tier) public view returns (uint256) {
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
    function getRange(Tier tier) public view returns (uint256, uint256) {
        return (_tierRanges[tier].start, _tierRanges[tier].end);

        // if (tier == Tier.Genesis) return (0, 0);
        // if (tier == Tier.President) return (1, 10);
        // if (tier == Tier.Prestige) return (11, 110);
        // if (tier == Tier.VIP) return (111, 1110);
        // if (tier == Tier.Elite) return (1111, 3110);
        // return (3111, 9999);
    }

    function getSupply(Tier tier) public view returns(uint256) {
        return _supplyByTier[tier];
    }

    function getMaxSupply(Tier tier) public view returns(uint256) {
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

        for (uint256 i = uint(Tier.Standard); i <= uint(Tier.Genesis); i++) {
            total += _reservedByTier[Tier(i)];
        }

        // total += _reservedByTier[Tier.Standard];
        // total += _reservedByTier[Tier.Elite];
        // total += _reservedByTier[Tier.VIP];
        // total += _reservedByTier[Tier.Prestige];
        // total += _reservedByTier[Tier.President];
        // total += _reservedByTier[Tier.Genesis];

        return total;
    }

    function getReservedLeft(Tier tier) public view returns(uint256) {
        return _reservedByTier[tier];
    }

    // IMPORTANT to remove this functionality, otherwise it will mess up tier system
    function setStartingIndex() public override virtual {
        startingIndex = 0;
    }

    function claimReserved(uint256, address) public pure override virtual {
        require(false, "Not implemented");
    }

    function claimReserved(Tier tier, uint256 _number, address _receiver) public {
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

    function mint(Tier tier, uint256 nTokens) whenSaleStarted public payable virtual {
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
