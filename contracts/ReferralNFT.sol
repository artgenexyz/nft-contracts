// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFT.sol";

contract ReferralNFT is AvatarNFT {

    // Bonus system
    uint public immutable REFERRAL_PERCENT; // of 10000, = 10%
    mapping (address => uint) public userTotalReferrals;
    mapping (address => uint) public pendingWithdrawals;

    constructor(
        uint256 _startPrice, uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxTokensPerMint,
        uint256 _referralPercent,
        string memory _uri,
        string memory _name, string memory _symbol
    ) AvatarNFT(_startPrice, _maxSupply, _nReserved, _maxTokensPerMint, _uri, _name, _symbol) {
        REFERRAL_PERCENT = _referralPercent;
    }

    /**
     * Mint tokens with referral info
     */
    function mintReferral(uint256 nTokens, address payable referral) whenSaleStarted external payable virtual {
        uint256 supply = totalSupply();

        require(nTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + nTokens <= MAX_SUPPLY - _reserved, "Not enough Tokens left.");
        require(nTokens * _price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < nTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }

        // _updateReferral(referral, nTokens);

        // Verify its correct referral
        if (referral != msg.sender && referral != owner()) {
            userTotalReferrals[referral] += nTokens;
        }

        // Send referral amount
        // TODO: check reentrancy

        // require(referral.send(msg.value * REFERRAL_PERCENT / 10000));
        // referral.transfer(msg.value * REFERRAL_PERCENT / 10000);

        pendingWithdrawals[referral] += msg.value * REFERRAL_PERCENT / 10000;
    }

    function _updateReferral(address payable referral, uint256 nTokens) public {

        // Verify its correct referral
        if (referral != msg.sender && referral != owner()) {
            userTotalReferrals[referral] += nTokens;
        }

        // Send referral amount
        // TODO: check reentrancy

        pendingWithdrawals[referral] += getPrice() * nTokens * REFERRAL_PERCENT / 10000;
    }

    function claimReferralRewards() public {
        uint amount = pendingWithdrawals[msg.sender];

        // Remember to zero the pending withdrawal before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

}
