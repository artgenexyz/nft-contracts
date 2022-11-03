// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";
import "./base/LimitedSupply.sol";

struct SignedAllowance {
    address minter;
    uint96 maxAmount;
    bytes signature;
}

contract OffchainAllowlistExtension is
    NFTExtension,
    Ownable,
    SaleControl,
    LimitedSupply
{
    uint256 public price;

    address public signer;

    mapping(address => uint256) public claimedByAddress;

    constructor(
        address _nft,
        address _signer,
        uint256 _price,
        uint256 _extensionSupply
    ) NFTExtension(_nft) SaleControl() LimitedSupply(_extensionSupply) {
        stopSale();

        price = _price;
        signer = _signer;
    }

    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function updateSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function mint(uint256 amount, SignedAllowance calldata allowance)
        external
        payable
        whenSaleStarted
    {
        // console.log("SOLIDITY args", amount, allowance.maxAmount);
        require(msg.sender == allowance.minter, "Minter mismatch");

        require(isValid(allowance), "Not allowed to mint");

        require(
            claimedByAddress[msg.sender] + amount <= allowance.maxAmount,
            "Cannot claim more per address"
        );

        require(msg.value >= amount * price, "Not enough ETH to mint");

        claimedByAddress[msg.sender] += amount;

        nft.mintExternal{value: msg.value}(amount, msg.sender, bytes32(0));
    }

    function isValid(SignedAllowance calldata allowance) public view returns (bool) {
        bytes32 digest = calculateDigest(allowance.minter, allowance.maxAmount);

        // console.log("SOLIDITY digest", digest);

        return
            SignatureChecker.isValidSignatureNow(
                signer,
                digest,
                allowance.signature
            );
    }

    function calculateDigest(address receiver, uint96 amount)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(receiver, amount));
    }
}
