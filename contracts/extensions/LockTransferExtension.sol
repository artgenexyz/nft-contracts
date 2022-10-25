// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IERC721Community.sol";
import "../interfaces/INFTExtension.sol";
import "./base/NFTExtension.sol";

contract LockTransfer is IERC721CommunityBeforeTransferExtension {
    constructor() {}

    function beforeTransfer(
        address from,
        address,
        uint256
    ) external view {
        // revert if owner balance is less than 1 eth
        require(
            from.balance >= 1 ether,
            "LockTransfer: balance is less than 1 eth"
        );
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId ==
            type(IERC721CommunityBeforeTransferExtension).interfaceId ||
            interfaceId == type(INFTExtension).interfaceId;
    }
}
