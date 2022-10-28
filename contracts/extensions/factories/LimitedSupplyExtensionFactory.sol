// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "./LimitedSupplyExtension.sol";

// contract by buildship.xyz

contract LimitedSupplyExtensionFactory {

    event ContractDeployed(
        address indexed deployedAddress,
        address indexed nft,
        address indexed owner,
        string title
    );

    address public immutable implementation;

    constructor() {
        implementation = address(new LimitedSupplyExtension());
    }

    function createExtension(
        string memory title,
        address nft,
        uint256 price,
        uint256 maxPerMint,
        uint256 maxPerWallet,
        uint256 extensionSupply,
        bool startSale
    ) external returns (address) {

        address payable clone = payable(Clones.clone(implementation));

        LimitedSupplyExtension list = LimitedSupplyExtension(clone);

        list.initialize(title, nft, price, maxPerMint, maxPerWallet, extensionSupply);

        if (startSale) {
            list.startSale();
        }

        list.transferOwnership(msg.sender);

        emit ContractDeployed(clone, nft, msg.sender, title);

        return clone;

    }
}
