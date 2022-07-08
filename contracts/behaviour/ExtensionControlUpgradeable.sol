// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/INFTExtension.sol";
import "../interfaces/IMetaverseNFT.sol";

abstract contract ExtensionControlUpgradeable is OwnableUpgradeable {

    /**
     * @dev List of connected extensions
     */
    INFTExtension[] public extensions;

    address public uriExtension;

    modifier onlyExtension() {
        require(
            isExtensionAdded(msg.sender),
            "Extension should be added to contract before minting"
        );
        _;
    }

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);
    event ExtensionURIAdded(address indexed extensionAddress);

    function isExtensionAdded(address _extension) public view returns (bool) {
        for (uint256 index = 0; index < extensions.length; index++) {
            if (address(extensions[index]) == _extension) {
                return true;
            }
        }

        return false;
    }

    function extensionsLength() public view returns (uint256) {
        return extensions.length;
    }

    // Extensions are allowed to mint
    function addExtension(address _extension) public onlyOwner {
        require(_extension != address(this), "Cannot add self as extension");

        require(!isExtensionAdded(_extension), "Extension already added");

        extensions.push(INFTExtension(_extension));

        emit ExtensionAdded(_extension);
    }

    function revokeExtension(address _extension) public onlyOwner {
        uint256 index = 0;

        for (; index < extensions.length; index++) {
            if (extensions[index] == INFTExtension(_extension)) {
                break;
            }
        }

        extensions[index] = extensions[extensions.length - 1];
        extensions.pop();

        emit ExtensionRevoked(_extension);
    }

    function setExtensionTokenURI(address extension) public onlyOwner {
        require(extension != address(this), "Cannot add self as extension");

        require(
            extension == address(0x0) ||
                ERC165Checker.supportsInterface(
                    extension,
                    type(INFTURIExtension).interfaceId
                ),
            "Not conforms to extension"
        );

        uriExtension = extension;

        emit ExtensionURIAdded(extension);
    }

    function extensionTokenURI(uint256 tokenId) public view returns (string memory) {

        // if (uriExtension != address(0)) {
        //     string memory uri = INFTURIExtension(uriExtension).tokenURI(
        //         tokenId
        //     );

        //     if (bytes(uri).length > 0) {
        //         return uri;
        //     }
        // }

        if (uriExtension != address(0x0)) {
            return INFTURIExtension(uriExtension).tokenURI(tokenId);
        }
        return "";
    }

}
