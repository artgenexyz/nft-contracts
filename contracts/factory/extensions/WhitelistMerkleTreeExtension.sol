// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./NFTExtension.sol";
import "./SaleControl.sol";

contract WhitelistMerkleTreeExtension is NFTExtension, Ownable, SaleControl {

    uint256 public price;
    uint256 public maxPerAddress;

    bytes32 public whitelistRoot;

    mapping (address => uint256) public claimedByAddress;

    constructor(address _nft, bytes32 _whitelistRoot, uint256 _price, uint256 _maxPerAddress) NFTExtension(_nft) SaleControl() {
        stopSale();

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

    function mint(uint256 nTokens, bytes32[] memory proof) external whenSaleStarted payable {
        super.beforeMint();

        require(isWhitelisted(whitelistRoot, msg.sender, proof), "Not whitelisted");

        require(claimedByAddress[msg.sender] + nTokens <= maxPerAddress, "Cannot claim more per address");

        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        claimedByAddress[msg.sender] += nTokens;

        nft.mintExternal{ value: msg.value }(nTokens, msg.sender, bytes32(0x0));

    }

    function isWhitelisted(bytes32 root, address receiver, bytes32[] memory proof) public pure returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(receiver));

        return MerkleProof.verify(proof, root, leaf);
    }

}
