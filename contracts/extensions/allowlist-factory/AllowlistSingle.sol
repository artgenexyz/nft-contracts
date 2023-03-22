// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

import "./base/SaleControlUpgradeable.sol";

import "./base/NFTExtensionUpgradeable.sol";

contract AllowlistSingle is NFTExtensionUpgradeable, SaleControlUpgradeable {
    uint256 public price;
    uint256 public maxPerAddress;

    bytes32 public whitelistRoot;

    string public title;

    mapping(address => uint256) public claimedByAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        string memory _title,
        address _nft,
        bytes32 _whitelistRoot,
        uint256 _price,
        uint256 _maxPerAddress
    ) initializer public {
        NFTExtensionUpgradeable.initialize(_nft);
        SaleControlUpgradeable.initialize();

        title = _title;
        price = _price;
        maxPerAddress = _maxPerAddress;
        whitelistRoot = _whitelistRoot;
    }

    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function updateMaxPerAddress(uint256 _maxPerAddress) public onlyOwner {
        maxPerAddress = _maxPerAddress;
    }

    function updateWhitelistRoot(bytes32 _whitelistRoot) public onlyOwner {
        whitelistRoot = _whitelistRoot;
    }

    function mint(uint256 nTokens, bytes32[] memory proof)
        external
        payable
        whenSaleStarted
    {
        require(
            isWhitelisted(whitelistRoot, msg.sender, proof),
            "Not whitelisted"
        );

        require(
            claimedByAddress[msg.sender] + nTokens <= maxPerAddress,
            "Cannot claim more per address"
        );

        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        claimedByAddress[msg.sender] += nTokens;

        nft.mintExternal{value: msg.value}(nTokens, msg.sender, bytes32(0x0));
    }

    function isWhitelisted(
        bytes32 root,
        address receiver,
        bytes32[] memory proof
    ) public pure returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(receiver));

        return MerkleProofUpgradeable.verify(proof, root, leaf);
    }
}
