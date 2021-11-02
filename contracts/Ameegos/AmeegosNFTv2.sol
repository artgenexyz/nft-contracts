// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "../AvatarNFT.sol";
import "../utils/MinterAccess.sol";

contract AmeegosNFTv2 is AvatarNFT, MinterAccess {

    constructor () AvatarNFT(
        115 ether, // matic
        7500, // max supply
        1356, // reserved, mint them before sale starts
        20, // max per transaction
        "ipfs://QmXE9FZkbaXSKcigDdx5d6uZu84xKQwamdjh8mxZLzKpp6/",
        "AmeegosOfficialNFT", "AGOS"
    ) {}

    function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
        uri = string(abi.encodePacked(
            super.tokenURI(tokenId), ".json"
        ));
    }

    function mint(uint256 _number) whenSaleStarted public payable override {
        uint256 supply = totalSupply();
        require(_number <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + _number <= MAX_SUPPLY - _reserved, "Not enough Tokens left.");
        require(_number * _price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < _number; i++) {
            _safeMint(msg.sender, supply + i + 1); // +1 because we start at 1
        }
    }

    function mintRestricted(uint256 _number, address _receiver) public payable onlyMinter {
        uint256 supply = totalSupply();
        require(_number <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + _number <= MAX_SUPPLY - _reserved, "Not enough Tokens left.");
        require(_number * _price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < _number; i++) {
            _safeMint(_receiver, supply + i + 1); // +1 because we start at 1
        }
    }

    function claimReserved(uint256 _number, address _receiver) public onlyOwner override {
        require(_number <= _reserved, "That would exceed the max reserved.");

        uint256 supply = totalSupply();
        for (uint256 i; i < _number; i++) {
            _safeMint(_receiver, supply + i + 1); // +1 because we start at 1
        }

        _reserved = _reserved - _number;
    }


    // --- Admin functions ---

    // Update beneficiary, override to make updateable
    function setBeneficiary(address payable _beneficiary) public override onlyOwner {
        beneficiary = _beneficiary;
    }

    // Withdraw sale money
    function withdraw() public override onlyOwner {
        uint256 _balance = address(this).balance;

        uint256 _amount = _balance * 91 / 100; // 91% : 9%

        require(payable(msg.sender).send(_amount));

        (, address _dev) = DEVELOPER();
        (bool success,) = _dev.call{value: _balance - _amount}("");
        require(success);
    }
}