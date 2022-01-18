// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./ArtNFT.sol";

contract ArtNFTFactory is Ownable {

    address public immutable proxyImplementation;

    event NFTCreated(address deployedAddress);

    constructor() {
        proxyImplementation = address(new ArtNFT());
    }

    function createNFT(
        uint256 _maxSupply,
        uint256 _royaltyFee,
        string memory _uri,
        string memory _name, string memory _symbol
    ) external payable {
        require(msg.value >= cost(), "Not enough payment");

        address clone = Clones.clone(proxyImplementation);

        ArtNFT(payable(clone)).initialize(
            _maxSupply,
            _royaltyFee,
            _uri,
            _name, 
            _symbol
        );

        ArtNFT(payable(clone)).transferOwnership(msg.sender);

        emit NFTCreated(clone);

        Address.sendValue(payable(msg.sender), msg.value - cost());
    }

    function cost() public view returns (uint256) {

        // we aim to be 10 times cheaper than deploying your own smart-contract
        uint approxDeployCost = 5_000_000 * block.basefee;

        // we ignore priority_fee

        // uint gasCost = 334_044; // TODO: record estimation
        // uint gasCost = 314_132;

        // so we charge 500_000 gas on top of 330_000 gas you pay for the deploy

        return approxDeployCost / 10;
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;

        Address.sendValue(payable(msg.sender), balance);
    }

}
