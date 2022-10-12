// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@paperxyz/contracts/keyManager/IPaperKeyManager.sol";

import "./base/NFTExtension.sol";

contract CCMintExtension is NFTExtension, Ownable {
    uint256 public price;
    uint256 public maxPerMint;
    mapping(address => bool) public minters;

    IPaperKeyManager public paperKM;

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

    modifier onlyMinters() {
        // check that msg.sender is one of minters
        require(minters[msg.sender], "CCMintExtension: not a minter");
        _;
    }

    function setPaperKeyManager(address _paperKeyManagerAddress)
        external
        onlyOwner
    {
        paperKM = IPaperKeyManager(_paperKeyManagerAddress);
    }

    function registerPaperKey(address _paperKey) external onlyOwner {
        require(paperKM.register(_paperKey), "Error registering key");
    }

    // onlyPaper modifier to easily restrict multiple different function
    modifier onlyPaper(
        bytes32 _hash,
        bytes32 _nonce,
        bytes calldata _signature
    ) {
        bool success = paperKM.verify(_hash, _nonce, _signature);
        require(success, "CCMintExtension: Failed to verify paper.xyz signature");
        _;
    }

    // --- Minting ---

    // winter
    function mint(uint256 amount, address recipient)
        external
        payable
        onlyMinters
    {
        super.beforeMint();

        require(msg.value >= price * amount, "Not enough ETH to mint");

        nft.mintExternal(amount, recipient, bytes32(0x0));
    }

    // paper.xyz
    function mint(
        uint256 amount,
        address recipient,
        bytes32 _nonce,
        bytes calldata _signature
    )
        external
        payable
        onlyPaper(keccak256(abi.encode(amount, recipient)), _nonce, _signature)
    {
        super.beforeMint();

        require(msg.value >= price * amount, "Not enough ETH to mint");

        nft.mintExternal(amount, recipient, bytes32(0x0));
    }
}
