// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title LICENSE REQUIREMENT
 * @dev This contract is licensed under the MIT license.
 * @dev You're not allowed to remove DEVELOPER() and DEVELOPER_ADDRESS() from contract
 */

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
// import "@openzeppelin/contracts/interfaces/IERC2981.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// import "./interfaces/INFTExtension.sol";
// import "./interfaces/IMetaverseNFT.sol";
// import "./utils/OpenseaProxy.sol";

import "./behaviour/SaleControlUpgradeable.sol";
import "./behaviour/PriceControlUpgradeable.sol";
import "./behaviour/OpenseaControlUpgradeable.sol";
import "./behaviour/ExtensionControlUpgradeable.sol";
import "./behaviour/PayoutControlUpgradeable.sol";
import "./behaviour/URIControlUpgradeable.sol";
// import "./extensions/base/MintControlUpgradeable.sol";

//      Want to launch your own collection?
//        Check out https://buildship.xyz

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
contract MetaverseNFT1 is
    ERC721Upgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    OpenseaControlUpgradeable,
    // MintControlUpgradeable,
    URIControlUpgradeable,
    SaleControlUpgradeable,
    PriceControlUpgradeable,
    ExtensionControlUpgradeable,
    PayoutControlUpgradeable
{

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIndexCounter; // token index counter

    uint256 public maxSupply;
    uint256 public reserved;

    bool private startAtOne = false;

    /**
     * @dev Additional data for each token that needs to be stored and accessed on-chain
     */
    mapping(uint256 => bytes32) public data;

    function initialize(
        uint256 _price,
        uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxPerMint,
        uint256 _royaltyFee,
        string memory _uri,
        string memory _name,
        string memory _symbol,
        bool _startAtOne
    ) public initializer {
        maxSupply = _maxSupply;
        reserved = _nReserved;

        price = _price;
        maxPerMint = _maxPerMint;

        royaltyFee = _royaltyFee;
        royaltyReceiver = address(this);

        startAtOne = _startAtOne;

        // Need help with uploading metadata? Try https://buildship.xyz
        BASE_URI = _uri;

        __ReentrancyGuard_init();
        __ERC721_init(_name, _symbol);
        __Ownable_init();
    }

    // This constructor ensures that this contract can only be used as a master copy
    // Marking constructor as initializer makes sure that real initializer cannot be called
    // Thus, as the owner of the contract is 0x0, no one can do anything with the contract
    // on the other hand, it's impossible to call this function in proxy,
    // so the real initializer is the only initializer
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory uri = super.extensionTokenURI(tokenId);

        if (bytes(uri).length > 0) {
            return uri;
        }

        return withPostfix(super.tokenURI(tokenId));

        // if (bytes(URI_POSTFIX).length > 0) {
        //     return
        //         string(abi.encodePacked(super.tokenURI(tokenId), URI_POSTFIX));
        // } else {
        //     return super.tokenURI(tokenId);
        // }
    }

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    function _startTokenId() internal view virtual returns (uint256) {
        return startAtOne ? 1 : 0;
    }

    function startTokenId() public view returns (uint256) {
        return _startTokenId();
    }

    // ---- Minting ----

    function _mintConsecutive(
        uint256 nTokens,
        address to,
        bytes32 extraData
    ) internal {
        require(
            _tokenIndexCounter.current() + nTokens + reserved <= maxSupply,
            "Not enough Tokens left."
        );

        for (uint256 i; i < nTokens; i++) {
            uint256 tokenId = _tokenIndexCounter.current() + startTokenId();
            _tokenIndexCounter.increment();

            _safeMint(to, tokenId);
            data[tokenId] = extraData;
        }
    }

    // ---- Mint public ----

    // Contract can sell tokens
    function mint(uint256 nTokens)
        external
        payable
        nonReentrant
        whenSaleStarted
    {
        require(
            nTokens <= maxPerMint,
            "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!"
        );

        require(nTokens * price <= msg.value, "Inconsistent amount sent!");

        _mintConsecutive(nTokens, msg.sender, 0x0);
    }

    // Owner can claim free tokens
    function claim(uint256 nTokens, address to)
        external
        nonReentrant
        onlyOwner
    {
        require(nTokens <= reserved, "That would exceed the max reserved.");

        reserved = reserved - nTokens;

        _mintConsecutive(nTokens, to, 0x0);
    }

    // ---- Mint via extension

    function mintExternal(
        uint256 nTokens,
        address to,
        bytes32 extraData
    ) external payable onlyExtension nonReentrant {
        _mintConsecutive(nTokens, to, extraData);
    }

    // -------- ERC721 overrides --------

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC721Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IMetaverseNFT).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Override isApprovedForAll to allowlist user's OpenSea proxy accounts to enable gas-less listings.
     * Taken from CryptoCoven: https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        if (isApprovedForOpensea(owner, operator)) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}
