// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";

import "../../../interfaces/INFTExtension.sol";
import "../../../interfaces/IMetaverseNFT.sol";

contract NFTExtensionUpgradeable is INFTExtension, ERC165Upgradeable {
    IMetaverseNFT public nft;

    function initialize(address _nft) internal onlyInitializing {
        __ERC165_init();

        nft = IMetaverseNFT(_nft);
    }

    function beforeMint() internal view {
        require(
            nft.isExtensionAdded(address(this)),
            "NFTExtension: this contract is not allowed to be used as an extension"
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(INFTExtension).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
