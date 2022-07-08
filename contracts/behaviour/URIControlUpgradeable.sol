// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/INFTExtension.sol";
import "../interfaces/IMetaverseNFT.sol";

abstract contract URIControlUpgradeable is OwnableUpgradeable {

    string public PROVENANCE_HASH;
    string internal CONTRACT_URI;
    string internal BASE_URI;
    string internal URI_POSTFIX;

    function contractURI() public view returns (string memory uri) {
        uri = bytes(CONTRACT_URI).length > 0 ? CONTRACT_URI : BASE_URI;
    }
    // ----- Admin functions -----

    function setBaseURI(string calldata uri) public onlyOwner {
        BASE_URI = uri;
    }

    // Contract-level metadata for Opensea
    function setContractURI(string calldata uri) public onlyOwner {
        CONTRACT_URI = uri;
    }

    function setPostfixURI(string calldata postfix) public onlyOwner {
        URI_POSTFIX = postfix;
    }

    // This should be set before sales open.
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE_HASH = provenanceHash;
    }

    function withPostfix(string memory uri) public view returns (string memory) {
        if (bytes(URI_POSTFIX).length > 0) {
            return string(abi.encodePacked(uri, URI_POSTFIX));
        } else {
            return uri;
        }
    }

}
