// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./base/NFTExtension.sol";

contract CCMintExtension is NFTExtension, Ownable {
    uint256 public price;
    uint256 public maxPerMint;
    mapping(address => bool) public minters;

    constructor(
        address _nft,
        uint256 _price,
        address[] memory _minters
    ) NFTExtension(_nft) {
        price = _price;

        for (uint256 i = 0; i < _minters.length; i++) {
            minters[_minters[i]] = true;
        }
    }

    function addMinters(address[] memory _minters) external onlyOwner {
        for (uint256 i = 0; i < _minters.length; i++) {
            minters[_minters[i]] = true;
        }
    }

    function removeMinters(address[] memory _minters) external onlyOwner {
        for (uint256 i = 0; i < _minters.length; i++) {
            minters[_minters[i]] = false;
        }
    }

    function mint(uint256 amount, address recipient) external payable {
        super.beforeMint();

        // check that msg.sender is one of minters
        require(minters[msg.sender] == true, "Not an allowed minter");

        require(msg.value >= price * amount, "Not enough ETH to mint");

        nft.mintExternal(amount, recipient, bytes32(0x0));
    }
}
