// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./SharedImplementationNFT.sol";

contract NFTFactory is Ownable {

    address public immutable proxyImplementation;

    event NFTCreated(address deployedAddress);

    constructor() {
        proxyImplementation = address(new SharedImplementationNFT());
    }

    function createNFT(
        uint256 _startPrice, uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxTokensPerMint,
        string memory _projectName,
        string memory _name, string memory _symbol
    ) external payable {
        require(msg.value >= cost(), "Not enough payment");

        address clone = Clones.clone(proxyImplementation);

        SharedImplementationNFT(clone).initialize(
            _startPrice, _maxSupply,
            _nReserved,
            _maxTokensPerMint,
            _projectName,
            _name, _symbol
        );

        SharedImplementationNFT(clone).transferOwnership(msg.sender);

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
