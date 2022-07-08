// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";

contract OffchainAllowListExtension is NFTExtension, Ownable, SaleControl {
    uint256 public price;

    address public signer;

    mapping(address => uint256) public claimedByAddress;

    constructor(
        address _nft,
        address _signer,
        uint256 _price
    ) NFTExtension(_nft) SaleControl() {
        stopSale();

        price = _price;
        signer = _signer;
    }

    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function mint(uint256 nTokens, uint256 maxAllowedAmount, bytes32 data, bytes memory signature)
        external
        payable
        whenSaleStarted
    {
        require(
            isWhitelisted(signature, msg.sender, maxAllowedAmount, data),
            "Not whitelisted"
        );

        require(
            claimedByAddress[msg.sender] + nTokens <= maxAllowedAmount,
            "Cannot claim more per address"
        );

        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        claimedByAddress[msg.sender] += nTokens;

        nft.mintExternal{value: msg.value}(nTokens, msg.sender, data);
    }

    function isWhitelisted(
        bytes memory signature,
        address receiver,
        uint256 amount,
        bytes32 data
    ) public view returns (bool) {
        return SignatureChecker.isValidSignatureNow(signer, keccak256(abi.encodePacked(receiver, amount, data)), signature);
    }
}
