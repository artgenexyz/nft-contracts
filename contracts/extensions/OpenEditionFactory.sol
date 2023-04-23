// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "./OpenEditionExtensionUpgradeable.sol";

contract OpenEditionFactory {
    event ContractDeployed(
        address indexed deployedAddress,
        address indexed nft,
        address indexed owner,
        string title
    );

    address public immutable implementation;

    constructor() {
        implementation = address(new OpenEditionExtensionUpgradeable());
    }

    function createOpenEdition(
        string memory title,
        address nft,
        uint256 _price,
        uint256 _maxPerMint,
        uint256 _maxPerWallet,
        uint256 _mintStart,
        uint256 _mintEnd
    ) external returns (OpenEditionExtensionUpgradeable) {
        address payable clone = payable(Clones.clone(implementation));

        OpenEditionExtensionUpgradeable ext = OpenEditionExtensionUpgradeable(
            clone
        );

        ext.initialize(nft, _price, _maxPerMint, _maxPerWallet, _mintStart, _mintEnd);

        ext.transferOwnership(msg.sender);

        emit ContractDeployed(clone, nft, msg.sender, title);

        return OpenEditionExtensionUpgradeable(clone);
    }
}
