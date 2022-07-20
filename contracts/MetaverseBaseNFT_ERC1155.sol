// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title LICENSE REQUIREMENT
 * @dev This contract is licensed under the MIT license.
 * @dev You're not allowed to remove DEVELOPER() and DEVELOPER_ADDRESS() from contract
 */

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@divergencetech/ethier/contracts/random/NextShuffler.sol";
import "@divergencetech/ethier/contracts/random/PRNG.sol";
import "@divergencetech/ethier/contracts/random/CSPRNG.sol";

import "./interfaces/INFTExtension.sol";
import "./interfaces/IMetaverseNFT.sol";
import "./utils/OpenseaProxy.sol";


contract NextShufflerPublic is NextShuffler {
    using PRNG for PRNG.Source;

    PRNG.Source public src = PRNG.newSource(0);

    constructor () NextShuffler(0) {}

    function _setSource(PRNG.Source _src) internal {
        src = _src;
    }

    function _setNum(uint256 _num) internal {
        numToShuffle = _num;
    }

    function next() internal returns (uint256) {
        return _next(src);
    }

}

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
// ERC1155,
contract MetaverseBaseNFT_ERC1155 is
    ERC1155Supply,
    ReentrancyGuard,
    Ownable,
    // NextShuffler,
    NextShufflerPublic,
    IMetaverseNFT // implements IERC2981
{
    using Address for address;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using Strings for uint256;
    using PRNG for PRNG.Source;

    Counters.Counter private _tokenIndexCounter; // token index counter

    // PRNG.Source private source;
    // NextShufflerPublic private shuffler;
    // CSPRNG.Source private source;

    uint256 public constant SALE_STARTS_AT_INFINITY = 2**256 - 1;
    uint256 public constant DEVELOPER_FEE = 500; // of 10,000 = 5%

    uint256 public startTimestamp = SALE_STARTS_AT_INFINITY;

    uint256 public reserved;
    uint256 public maxSupply;
    uint256 public maxPerMint;
    uint256 public price;

    uint256 public royaltyFee;

    address public royaltyReceiver;
    address public payoutReceiver = address(0x0);
    address public uriExtension = address(0x0);

    bool public isFrozen;
    bool public isPayoutChangeLocked;
    bool private isOpenSeaProxyActive = true;
    bool private startAtOne = false;

    mapping(uint256 => uint256) public _maxSeriesSupply;

    /**
     * @dev Additional data for each token that needs to be stored and accessed on-chain
     */
    mapping(uint256 => bytes32) public data;

    /**
     * @dev List of connected extensions
     */
    INFTExtension[] public extensions;

    string public PROVENANCE_HASH = "";
    string private CONTRACT_URI = "";
    string private BASE_URI;
    string private URI_POSTFIX = "";

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);
    event ExtensionURIAdded(address indexed extensionAddress);

    constructor(
        uint256 _price,
        uint256 _maxSupply, // only limit ids here, not the full number of NFTs
        uint256 _nReserved,
        uint256 _maxPerMint,
        uint256 _royaltyFee,
        string memory _uri,
        // string memory _name,
        // string memory _symbol,
        bool _startAtOne
    ) ERC1155(_uri) {
        startTimestamp = SALE_STARTS_AT_INFINITY;

        price = _price;
        reserved = _nReserved;
        maxPerMint = _maxPerMint;
        maxSupply = _maxSupply;

        royaltyFee = _royaltyFee;
        royaltyReceiver = address(this);

        startAtOne = _startAtOne;

        // Need help with uploading metadata? Try https://buildship.xyz
        BASE_URI = _uri;
    }

    function startTokenId() public view returns (uint256) {
        return startAtOne ? 1 : 0;
    }

    function contractURI() public view returns (string memory _uri) {
        _uri = bytes(CONTRACT_URI).length > 0 ? CONTRACT_URI : BASE_URI;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return uri(_tokenId);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (uriExtension != address(0)) {
            string memory u = INFTURIExtension(uriExtension).tokenURI(tokenId);

            if (bytes(u).length > 0) {
                return u;
            }
        }

        if (bytes(URI_POSTFIX).length > 0) {
            return
                string(
                    abi.encodePacked(BASE_URI, tokenId.toString(), URI_POSTFIX)
                );
        } else {
            return string(abi.encodePacked(BASE_URI, tokenId.toString()));
        }
    }

    function maxSeriesSupply(uint256 id) public view returns (uint256) {
        return _maxSeriesSupply[id];
    }

    function totalSeriesSupply(uint256 id) public view returns (uint256) {
        return totalSupply(id);
    }

    function maxSupplyAll() public view returns (uint256) {
        // TODO: make O(1) by caching on mint?

        // sum of all token ids
        uint256 total = 0;

        for (uint256 id = startTokenId(); id <= lastTokenId(); id++) {
            total += maxSeriesSupply(id);
        }

        return total;
    }

    function totalSupplyAll() public view returns (uint256) {
        // TODO: make O(1) by caching on mint?

        // sum of all token ids
        uint256 total = 0;

        for (uint256 id = startTokenId(); id <= lastTokenId(); id++) {
            total += totalSupply(id);
        }

        return total;
    }

    // ----- Admin functions -----

    function setBaseURI(string calldata _uri) public onlyOwner {
        BASE_URI = _uri;
    }

    // Contract-level metadata for Opensea
    function setContractURI(string calldata _uri) public onlyOwner {
        CONTRACT_URI = _uri;
    }

    function setPostfixURI(string calldata postfix) public onlyOwner {
        URI_POSTFIX = postfix;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setSource(bytes32 seed) public onlyOwner {
        require(numToShuffle == 0, "Can't change source after seed has been set");

        // (, uint256 remain) = source.state();

        // require(remain == 0, "Already started mint");

        PRNG.Source source = PRNG.newSource(seed);

        _setNum( maxSupplyAll() );
        _setSource(source);

    }

    // Freeze forever, irreversible
    function freeze() public onlyOwner {
        isFrozen = true;
    }

    // Lock changing withdraw address
    function lockPayoutChange() public onlyOwner {
        isPayoutChangeLocked = true;
    }

    function isExtensionAdded(address _extension) public view returns (bool) {
        for (uint256 index = 0; index < extensions.length; index++) {
            if (address(extensions[index]) == _extension) {
                return true;
            }
        }

        return false;
    }

    function extensionsLength() public view returns (uint256) {
        return extensions.length;
    }

    // Extensions are allowed to mint
    function addExtension(address _extension) public onlyOwner {
        require(_extension != address(this), "Cannot add self as extension");

        require(!isExtensionAdded(_extension), "Extension already added");

        extensions.push(INFTExtension(_extension));

        emit ExtensionAdded(_extension);
    }

    function revokeExtension(address _extension) public onlyOwner {
        uint256 index = 0;

        for (; index < extensions.length; index++) {
            if (extensions[index] == INFTExtension(_extension)) {
                break;
            }
        }

        extensions[index] = extensions[extensions.length - 1];
        extensions.pop();

        emit ExtensionRevoked(_extension);
    }

    function setExtensionTokenURI(address extension) public onlyOwner {
        require(extension != address(this), "Cannot add self as extension");

        require(
            extension == address(0x0) ||
                ERC165Checker.supportsInterface(
                    extension,
                    type(INFTURIExtension).interfaceId
                ),
            "Not conforms to extension"
        );

        uriExtension = extension;

        emit ExtensionURIAdded(extension);
    }

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    // from CryptoCoven https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive)
        public
        onlyOwner
    {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    // ---- Minting ----

    function lastTokenId() public view returns (uint256) {
        return startTokenId() + _tokenIndexCounter.current();
    }

    function nextTokenId() internal returns (uint256 id) {
        _tokenIndexCounter.increment();

        return _tokenIndexCounter.current() - 1;

        // return id;
    }

    // TODO: optional push ipfs hash to metadata?
    function importSeries(uint256[] calldata supply) public onlyOwner {
        require(lastTokenId() + supply.length - startTokenId() <= maxSupply, "Too many tokens");

        for (uint256 i = 0; i < supply.length; i++) {
            uint256 tokenId = nextTokenId();
            uint256 _supply = supply[i];

            // require(_supply > 0, "Supply must be greater than 0");
            require(_maxSeriesSupply[tokenId] == 0, "Token already imported");
            require(_supply != 0, "Can't import empty series");

            _maxSeriesSupply[tokenId] = _supply;
        }
    }

    function _mintTokens(
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal {
        require(amount > 0, "Amount must be greater than 0");
        require(
            totalSeriesSupply(tokenId) + amount <= maxSeriesSupply(tokenId),
            "Amount exceeds max supply"
        );
        require(
            tokenId >= startTokenId() && tokenId <= lastTokenId(),
            "TokenId out of range"
        );

        // Mint the tokens
        _mint(to, tokenId, amount, "");
    }

    function _mintTokens(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        require(ids.length == amounts.length, "Ids and amounts must be same length");

        for (uint256 i = 0; i < ids.length; i++) {

            // console.log("Token ID", ids[i]);
            // console.log("Amount requested", amounts[i]);
            // console.log("Total supply", totalSeriesSupply(ids[i]));
            // console.log("Max supply", maxSeriesSupply(ids[i]));

            console.log(string(abi.encodePacked(
                ids[i].toString(), " => ", totalSeriesSupply(ids[i]).toString(), "/", maxSeriesSupply(ids[i]).toString(), " + ", amounts[i].toString()
            )));

            require(
                ids[i] >= startTokenId() && ids[i] <= lastTokenId(),
                "TokenId out of range"
            );
            require(
                totalSeriesSupply(ids[i]) + amounts[i] <= maxSeriesSupply(ids[i]),
                "Amount exceeds max supply"
            );

            // _mintTokens(to, ids[i], amount[i]);
        }

        _mintBatch(to, ids, amounts, "");
    }

    function _tokenIdSeed2TokenId(uint256 seed) internal view returns (uint256) {
        uint256 index = 0;
        uint256 lastIndex;

        for (uint256 tokenId = startTokenId(); tokenId <= lastTokenId(); tokenId++) {
            lastIndex = index + maxSeriesSupply(tokenId) - 1;

            if (seed <= lastIndex && seed >= index) {
                return tokenId;
            }

            index = lastIndex + 1;
        }

        console.log("Last Index", index);
        console.log("Seed", seed);

        revert("Not found");
        // id = 0;
    }

    function _mintRandomTokens(uint256 amount, address to) internal {
        require(totalSupplyAll() + amount <= maxSupplyAll(), "Not enough Tokens left");

        uint256 tokenIdSeed;
        uint256 tokenId;

        console.log("amount", amount);

        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);

        for (uint256 i = 0; i < amount; i++) {
            // 88 series
            // 100 tokens in each

            // next = [0, 88 * 100)

            tokenIdSeed = next();

            // token id is fetched from the random offset
            tokenId = _tokenIdSeed2TokenId(tokenIdSeed);

            // TODO: what's wrong?
            console.log(string(abi.encodePacked(
                "Mint: ", tokenId.toString(), " => ", totalSeriesSupply(tokenId).toString(), "/", maxSeriesSupply(tokenId).toString(), " + ", "1"
            )));

            // TODO: use array
            _mint(to, tokenId, 1, "");

            ids[i] = tokenId;
            amounts[i] = 1;
        }

        // unchecked {
        //     // print array info for ids[i]:
        //     console.log(string(abi.encodePacked(
        //         "[", ids[0].toString(), ",", ids[1].toString(), ",", ids[2].toString(), "]"
        //     )));
        // }

        console.log('ids', ids.length, amounts.length);

        // _mintTokens(to, ids, amounts);

    }

    function _mintConsecutive(
        uint256 nTokens,
        address to,
        bytes32 extraData
    ) internal {
        require(extraData == 0x0, "ERC1155 does not support extra data");

        // TODO: mint consecutive? token ids instead
        _mintRandomTokens(nTokens, to);
    }

    // ---- Mint control ----

    modifier whenSaleStarted() {
        require(saleStarted(), "Sale not started");
        _;
    }

    modifier whenNotFrozen() {
        require(!isFrozen, "Minting is frozen");
        _;
    }

    modifier whenNotPayoutChangeLocked() {
        require(!isPayoutChangeLocked, "Payout change is locked");
        _;
    }

    modifier onlyExtension() {
        require(
            isExtensionAdded(msg.sender),
            "Extension should be added to contract before minting"
        );
        _;
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

        _mintRandomTokens(nTokens, msg.sender);
    }

    // Owner can claim free tokens
    function claim(uint256 nTokens, address to)
        external
        nonReentrant
        onlyOwner
    {
        require(nTokens <= reserved, "That would exceed the max reserved.");

        reserved = reserved - nTokens;

        _mintRandomTokens(nTokens, to);
    }

    // ---- Mint via extension

    function mintExternal(
        uint256 nTokens,
        address to,
        bytes32 _data
    ) external payable onlyExtension nonReentrant {
        // if data is 0xffffff...ff, then it is a request for a N random tokens
        // else it's a request for a specific token id

        if (uint256(_data) == type(uint256).max) {
            _mintRandomTokens(nTokens, to);
        } else {
            uint256 id = uint256(_data);
            _mint(to, id, nTokens, "");
        }

    }

    // ---- Sale control ----

    function updateStartTimestamp(uint256 _startTimestamp)
        public
        onlyOwner
        whenNotFrozen
    {
        startTimestamp = _startTimestamp;
    }

    function startSale() public onlyOwner whenNotFrozen {
        require(numToShuffle != 0, "You should set source before startSale");

        startTimestamp = block.timestamp;
    }

    function stopSale() public onlyOwner {
        startTimestamp = SALE_STARTS_AT_INFINITY;
    }

    function saleStarted() public view returns (bool) {
        return block.timestamp >= startTimestamp;
    }

    // ---- Offchain Info ----

    // This should be set before sales open.
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE_HASH = provenanceHash;
    }

    function setRoyaltyFee(uint256 _royaltyFee) public onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    function setPayoutReceiver(address _receiver)
        public
        onlyOwner
        whenNotPayoutChangeLocked
    {
        payoutReceiver = payable(_receiver);
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        // We use the same contract to split royalties: 5% of royalty goes to the developer
        receiver = royaltyReceiver;
        royaltyAmount = (salePrice * royaltyFee) / 10000;
    }

    function getPayoutReceiver()
        public
        view
        returns (address payable receiver)
    {
        receiver = payoutReceiver != address(0x0)
            ? payable(payoutReceiver)
            : payable(owner());
    }

    // ---- Allow royalty deposits from Opensea -----

    receive() external payable {}

    // ---- Withdraw -----

    function withdraw() public virtual onlyOwner {
        uint256 balance = address(this).balance;
        uint256 amount = (balance * (10000 - DEVELOPER_FEE)) / 10000;

        address payable receiver = getPayoutReceiver();
        address payable dev = DEVELOPER_ADDRESS();

        Address.sendValue(receiver, amount);
        Address.sendValue(dev, balance - amount);
    }

    function withdrawToken(IERC20 token) public virtual onlyOwner {
        uint256 balance = token.balanceOf(address(this));

        uint256 amount = (balance * (10000 - DEVELOPER_FEE)) / 10000;

        address payable receiver = getPayoutReceiver();
        address payable dev = DEVELOPER_ADDRESS();

        token.safeTransfer(receiver, amount);
        token.safeTransfer(dev, balance - amount);
    }

    function DEVELOPER() public pure returns (string memory _url) {
        _url = "https://buildship.xyz";
    }

    function DEVELOPER_ADDRESS() public pure returns (address payable _dev) {
        _dev = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    }

    // -------- ERC1155 overrides --------

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
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
        // Get a reference to OpenSea's proxy registry contract by instantiating
        // the contract using the already existing address.
        ProxyRegistry proxyRegistry = ProxyRegistry(
            0xa5409ec958C83C3f309868babACA7c86DCB077c1
        );

        if (
            isOpenSeaProxyActive &&
            address(proxyRegistry.proxies(owner)) == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}
