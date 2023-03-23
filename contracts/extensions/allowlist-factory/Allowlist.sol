// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//      Want to launch your own collection?
//        Check out https://buildship.xyz
//
//                                    ,:loxO0KXXc
//                               ,cdOKKKOxol:lKWl
//                            ;oOXKko:,      ;KNc
//                        'ox0X0d:           cNK,
//                 ','  ;xXX0x:              dWk
//            ,cdO0KKKKKXKo,                ,0Nl
//         ;oOXKko:,;kWMNl                  dWO'
//      ,o0XKd:'    oNMMK:                 cXX:
//   'ckNNk:       ;KMN0c                 cXXl
//  'OWMMWKOdl;'    cl;                  oXXc
//   ;cclldxOKXKkl,                    ;kNO;
//            ;cdk0kl'             ;clxXXo
//                ':oxo'         c0WMMMMK;
//                    :l:       lNMWXxOWWo
//                      ';      :xdc' :XWd
//             ,                      cXK;
//           ':,                      xXl
//           ;:      '               o0c
//           ;c;,,,,'               lx;
//            '''                  cc
//                                ,'

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

import "./base/SaleControlUpgradeable.sol";

import "./base/NFTExtensionUpgradeable.sol";

contract Allowlist is NFTExtensionUpgradeable, SaleControlUpgradeable {
    uint256 public price;

    bytes32 public allowlistRoot;

    string public title;

    mapping(address => uint256) public claimedByAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        string memory _title,
        address _nft,
        bytes32 _allowlistRoot,
        uint256 _price
    ) public initializer {
        NFTExtensionUpgradeable.initialize(_nft);
        SaleControlUpgradeable.initialize();

        title = _title;
        price = _price;
        allowlistRoot = _allowlistRoot;
    }

    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function updateAllowlistRoot(bytes32 _allowlistRoot) public onlyOwner {
        allowlistRoot = _allowlistRoot;
    }

    function mint(
        uint256 amount,
        uint256 maxAllocatedAmount,
        bytes32[] memory proof
    ) external payable whenSaleStarted {
        require(
            isAllowlisted(allowlistRoot, msg.sender, maxAllocatedAmount, proof),
            "Not whitelisted"
        );

        require(
            claimedByAddress[msg.sender] + amount <= maxAllocatedAmount,
            "Cannot claim more per address"
        );

        require(msg.value >= amount * price, "Not enough ETH to mint");

        claimedByAddress[msg.sender] += amount;

        nft.mintExternal{value: msg.value}(amount, msg.sender, bytes32(0));
    }

    function computeLeaf(
        address receiver,
        uint256 maxAmount
    ) public pure returns (bytes32) {
        // leaf is [keccak256(address), maxAmount]
        // double hash to prevent length extension attack

        bytes memory leafData = abi.encode(
            keccak256(abi.encodePacked(receiver)),
            maxAmount
        );

        return keccak256(bytes.concat(keccak256(leafData)));
    }

    function isAllowlisted(
        bytes32 root,
        address receiver,
        uint256 maxAmount,
        bytes32[] memory proof
    ) public pure returns (bool) {
        bytes32 leaf = computeLeaf(receiver, maxAmount);

        return MerkleProofUpgradeable.verify(proof, root, leaf);
    }
}
