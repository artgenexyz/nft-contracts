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
import "../utils/OpenseaProxy.sol";

abstract contract OpenseaControlUpgradeable is OwnableUpgradeable {

    bool private isOpenSeaProxyActive;

    function __OpenseaControlUpgradeable_init() internal onlyInitializing {
        isOpenSeaProxyActive = false;
    }

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    // from CryptoCoven https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive)
        public
        onlyOwner
    {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }


    function isApprovedForOpensea(address owner, address operator) public view returns (bool) {
        // Get a reference to OpenSea's proxy registry contract by instantiating
        // the contract using the already existing address.
        ProxyRegistry proxyRegistry = ProxyRegistry(
            0xa5409ec958C83C3f309868babACA7c86DCB077c1
        );

        if (
            isOpenSeaProxyActive &&
            address(proxyRegistry.proxies(owner)) == operator
        ) {
            return true;
        }

        return false;
    }

}
