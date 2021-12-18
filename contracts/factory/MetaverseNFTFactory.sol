// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "./MetaverseNFT.sol";


/**
* MetaverseNFT is a cloneable contract for your NFT collection.
* It's adapted from OpenZeppeling ERC721 implementation upgradeable versions.
* This is needed to make it possible to create clones that work via delegatecall
* ! The constructor is replaced with initializer, too
* This way, deployment costs about 350k gas instead of 4.5M.
* 1. https://forum.openzeppelin.com/t/how-to-set-implementation-contracts-for-clones/6085/4
* 2. https://github.com/OpenZeppelin/workshops/tree/master/02-contracts-clone/contracts/2-uniswap
* 3. https://docs.openzeppelin.com/contracts/4.x/api/proxy
*/

contract MetaverseNFTFactory {

    address public immutable proxyImplementation;

    event NFTCreated(address deployedAddress);

    constructor() {
        proxyImplementation = address(new MetaverseNFT());

        emit NFTCreated(proxyImplementation);
    }

    function createNFT(
        uint256 _startPrice,
        uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxTokensPerMint,
        uint256 _royaltyFee,
        string memory _uri,
        string memory _name, string memory _symbol
    ) external {

        address clone = Clones.clone(proxyImplementation);

        MetaverseNFT(clone).initialize(
            _startPrice,
            _maxSupply,
            _nReserved,
            _maxTokensPerMint,
            _royaltyFee,
            _uri,
            _name, _symbol
        );

        MetaverseNFT(clone).transferOwnership(msg.sender);

        emit NFTCreated(clone);

    }

}
