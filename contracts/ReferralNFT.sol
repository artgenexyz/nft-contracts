// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFT.sol";

abstract contract ReferralNFT is AvatarNFT {

    // Bonus system
    uint256 public immutable REFERRAL_PERCENT; // of 10000, = 10%
    mapping (address => uint256) public userTotalReferrals;
    mapping (address => uint256) public pendingWithdrawals;

    event ReferralMinted (
        address indexed referral,
        address buyer,
        uint256 timestamp,
        uint256 nTokens,
        uint256 referralFee,
        bytes data
    );

    constructor(
        uint256 _referralPercent
    ) {
        REFERRAL_PERCENT = _referralPercent;
    }

    /**
     * Mint tokens with referral info
     */
    function mint(uint256 nTokens, address payable referral) whenSaleStarted external payable virtual {
        super.mint(nTokens);

        _updateReferral(nTokens, referral);
    }

    function _updateReferral(uint256 nTokens, address payable referral) internal {
        // Verify its correct referral
        // Save referral amount for later use
        if (referral != address(0) && referral != msg.sender && referral != owner() && referral != beneficiary) {
            userTotalReferrals[referral] += nTokens;
            pendingWithdrawals[referral] += msg.value * REFERRAL_PERCENT / 10000;

            emit ReferralMinted(
                referral,
                msg.sender,
                block.timestamp,
                nTokens,
                msg.value * REFERRAL_PERCENT / 10000,
                msg.data
            );
        }
    }

}
