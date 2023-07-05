// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./AllowlistBase.sol";

contract AllowlistBaseFactory {
    event ContractDeployed(
        address indexed deployedAddress,
        address indexed nft,
        address indexed owner,
        string title
    );

    constructor() {}

    function createAllowlist(
        string memory title,
        address nft,
        bytes32 root,
        uint256 price,
        bool startSale
    ) external returns (address) {
        AllowlistBase list = new AllowlistBase(title, nft, root, price);

        if (startSale) {
            list.startSale();
        }

        list.transferOwnership(msg.sender);

        emit ContractDeployed(address(list), nft, msg.sender, title);

        return address(list);
    }
}
