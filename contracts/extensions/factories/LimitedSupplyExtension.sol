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

import "./base/SaleControlUpgradeable.sol";

import "./base/NFTExtensionUpgradeable.sol";

interface NFT is IERC721Community {
    function maxSupply() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

contract LimitedSupplyExtension is NFTExtensionUpgradeable, SaleControlUpgradeable {

    uint256 public price;
    uint256 public maxPerMint;
    uint256 public maxPerWallet;
    uint256 public totalMinted;
    uint256 public extensionSupply;

    string public title;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        string memory _title,
        address _nft,
        uint256 _price,
        uint256 _maxPerMint,
        uint256 _maxPerWallet,
        uint256 _extensionSupply
    ) initializer public {
        NFTExtensionUpgradeable.initialize(_nft);
        SaleControlUpgradeable.initialize();

        title = _title;
        price = _price;
        maxPerMint = _maxPerMint;
        maxPerWallet = _maxPerWallet;
        extensionSupply = _extensionSupply;
    }

    function mint(uint256 nTokens) external payable whenSaleStarted {
        require(
            IERC721(address(nft)).balanceOf(msg.sender) + nTokens <=
                maxPerWallet,
            "LimitedSupplyMintingExtension: max per wallet reached"
        );

        require(
            nTokens + totalMinted <= extensionSupply,
            "max extensionSupply reached"
        );
        require(nTokens <= maxPerMint, "Too many tokens to mint");
        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        totalMinted += nTokens;

        nft.mintExternal{value: msg.value}(nTokens, msg.sender, bytes32(0x0));
    }

    function maxSupply() public view returns (uint256) {
        return NFT(address(nft)).maxSupply();
    }

    function totalSupply() public view returns (uint256) {
        return NFT(address(nft)).totalSupply();
    }
}

