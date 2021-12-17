// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./MetaverseNFT.sol";

contract MetaverseNFTFactory is Ownable {

    address public immutable proxyImplementation;

    event NFTCreated(address deployedAddress);

    constructor() {
        proxyImplementation = address(new MetaverseNFT());
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
