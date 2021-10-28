// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFT.sol";

// THIS IS UNUSED VERSION, LEFT FOR REFERENCE
contract ReferralOnchainNFT is AvatarNFT {

    // Bonus system
    uint256 public immutable REFERRAL_PERCENT; // of 10000, = 10%
    mapping (address => uint256) public userTotalReferrals;
    mapping (address => uint256) public pendingWithdrawals;

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

    function mint(uint256 nTokens) whenSaleStarted public payable override virtual {
        super.mint(nTokens);

        // Need to keep track of all beneficiary sales
        pendingWithdrawals[beneficiary] += msg.value;
    }

    /**
     * Mint tokens with referral info
     */
    function mint(uint256 nTokens, address payable referral) whenSaleStarted external payable virtual {
        require(beneficiary != address(0), "Beneficiary is not set");

        uint256 supply = totalSupply();

        require(nTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + nTokens <= MAX_SUPPLY - _reserved, "Not enough Tokens left.");
        require(nTokens * _price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < nTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }

        _updateReferral(nTokens, referral);
    }

    function _updateReferral(uint256 nTokens, address payable referral) internal {

        // Verify its correct referral
        // Save referral amount for later use
        if (referral != address(0) && referral != msg.sender && referral != owner() && referral != beneficiary) {
            userTotalReferrals[referral] += nTokens;

            // so that total of pendingWithdrawals is always the same as the contract, we add money to both
            pendingWithdrawals[referral] += msg.value * REFERRAL_PERCENT / 10000;
            pendingWithdrawals[beneficiary] += msg.value * (10000 - REFERRAL_PERCENT) / 10000;
        } else {
            // to make sure admin cannot withdraw referrals money
            pendingWithdrawals[beneficiary] += msg.value;
        }

    }

    function withdrawReferral(address payable referral) public onlyOwner {
        uint amount = pendingWithdrawals[referral];

        // Remember to zero the pending withdrawal before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[referral] = 0;
        referral.transfer(amount);
    }

    function claimReferralRewards() public {
        uint amount = pendingWithdrawals[msg.sender];

        // Remember to zero the pending withdrawal before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    /*
     * Usual withdraw only allows to withdraw owner's share
     */
    function withdraw() public override onlyOwner {
        require(beneficiary != address(0), "Beneficiary not set");

        uint256 amount = pendingWithdrawals[beneficiary];

        beneficiary.transfer(amount);
    }

    /*
     * Used in critical situation if math is incorrect and owner needs to rescue funds.
     * BUT, needs to STOP SALE FIRST!
     */
    function emergencyWithdraw() public onlyOwner {
        require(beneficiary != address(0), "Beneficiary not set");
        require(!saleStarted(), "Emergency withdraw is not allowed when sale is not stopped!");

        uint256 amount = address(this).balance;

        beneficiary.transfer(amount);
    }

}
