// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import Clones
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./SharedImplementationNFT.sol";

contract NFTFactory {

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
    ) external {
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
    }

}
