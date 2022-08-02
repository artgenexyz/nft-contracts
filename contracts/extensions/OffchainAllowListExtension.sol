// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
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

    function mint(
        uint256 nTokens,
        uint256 maxAllowedAmount,
        // uint256[] calldata ids,
        // uint256[] calldata amounts,
        bytes32 data,
        bytes memory signature
    ) external payable whenSaleStarted {
        console.log(
            // "SOLIDITY args",
            nTokens,
            maxAllowedAmount
            // ,
            // iToHex(abi.encodePacked(ids)),
            // iToHex(abi.encodePacked(amounts))
        );

        // require(ids.length == amounts.length, "Inconsistent array lengths");

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

    function bytesToString(bytes memory byteCode)
        internal
        pure
        returns (string memory stringData)
    {
        uint256 blank = 0; //blank 32 byte value
        uint256 length = byteCode.length;

        uint256 cycles = byteCode.length / 0x20;
        uint256 requiredAlloc = length;

        if (
            length % 0x20 > 0
        ) //optimise copying the final part of the bytes - to avoid looping with single byte writes
        {
            cycles++;
            requiredAlloc += 0x20; //expand memory to allow end blank, so we don't smack the next stack entry
        }

        stringData = new string(requiredAlloc);

        //copy data in 32 byte blocks
        assembly {
            let cycle := 0

            for {
                let mc := add(stringData, 0x20) //pointer into bytes we're writing to
                let cc := add(byteCode, 0x20) //pointer to where we're reading from
            } lt(cycle, cycles) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
                cycle := add(cycle, 0x01)
            } {
                mstore(mc, mload(cc))
            }
        }

        //finally blank final bytes and shrink size (part of the optimisation to avoid looping adding blank bytes1)
        if (length % 0x20 > 0) {
            uint256 offsetStart = 0x20 + length;
            assembly {
                let mc := add(stringData, offsetStart)
                mstore(mc, mload(add(blank, 0x20)))
                //now shrink the memory back so the returned object is the correct size
                mstore(stringData, length)
            }
        }
    }

    function iToHex(bytes memory buffer) internal pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }

    function isWhitelisted(
        bytes memory signature,
        address receiver,
        uint256 amount,

        // uint256[] calldata ids,
        // uint256[] calldata amounts

        bytes32 data
    ) public view returns (bool) {
        console.log(
            "SOLIDITY raw",
            iToHex(abi.encodePacked(receiver, bytes32(amount), data))
        );

        bytes32 hash = keccak256(
            abi.encodePacked(receiver, bytes32(amount))
        );

        bytes32 digest = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked(receiver, bytes32(amount), data))
        );

        // usedDigest = true

        console.log(
            "SOLIDITY hash",
            string(Strings.toHexString(uint256(hash)))
        );
        console.log(
            "SOLIDITY digest",
            string(Strings.toHexString(uint256(digest)))
        );

        return SignatureChecker.isValidSignatureNow(signer, digest, signature);
    }
}
