// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
* @title LICENSE REQUIREMENT
* @dev This contract is licensed under the MIT license.
* @dev You're not allowed to remove DEVELOPER() and DEVELOPER_ADDRESS() from contract
*/

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./extensions/INFTExtension.sol";
import "./IMetaverseNFT.sol";
import "./OpenseaProxy.sol";

//      Want to launch your own collection ? Check out https://buildship.dev.
//
//                                   zAAAAA#QQQQQ=                                     
//                                   yN8NNN@@@@@@L                                     
//                                   jgggggQ@@@@@|                                     
//                                   ~;!!!!|ccccc~                                     
//                                   ,~__~~>||L||_                                     
//                                   ,~__~~>|||||_                                     
//                                   ,~__~~>|||||_                                     
//             ``````````````````````',,,,,~;;;;;,``````````````````````               
//             .'..................''''''''.....''''.................''.               
//            `'''..'''....''''''.....''''''..''''''''....'''''''....''.               
//            `'''',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'.'.               
//            `.'''!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~'...`              
//            `..''!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~''..`              
//     ```````...''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:''..```````        
//     ..'..........''...'''...'...''''..''..''''...'...'''...''.............''`       
//     .''..........''.........'.........''.........'.........''.............''`       
//     .''..';^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~'....`       
//     .''..,aqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqv'....`       
//     .''..,aqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc'..''`       
//     .''..,|77777777777777777777777777777777777777777777777777777777777^'..''`       
//     .''..'.''.'''.....'''''.....''.'''....''.'''.....'''''.....''.''''....''`       
//     .''..''...'''..............................................''''...''..''`       
//     ``````....''',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,''...'```````       
//           `...'':_______________________________________________,'...'`             
//           ....'':_______________________________________________,'....`             
//           .'...':__~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~___,'....`             
//           .'...':__~~~!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;~~___,'...'`             
//          `.'..'':___~~!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;~___~,'...'.             
// `,,,,,,,,:~~~~~~;!!!!!r=================|iiiiiiiiiiiiiiiii|>>>>>=^^^^^^;;;;;;;;:    
// `>LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU?    
//  ~LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUw:    
//  .t555555555yyyyy55555yyyyy555555yyyyy55Dgggggggggggggggggggggggggggggggggggggz     
//   vNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ@QQQ!     
//   ,KNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQP`     
//    |6666666666666666666666666666666666668QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ8;      
//    `>LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLZUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU6L       
//     ,LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUj.       
//      !LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLS6UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUX;        
//      .*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU7`        
//       _LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUa'         
//        ^LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUX!          
//        `+LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU>           
//         '*LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLS6UUUUUUUUUUUUUUUUUUUUUUUUUUUUUz`           
//          ,|LLLLLLLLLLLLLLLLLLLLLLLLLLLLLSUUUUUUUUUUUUUUUUUUUUUUUUUUUUUj'            
//           ~LLLLLLLLLLLLLLLLLLLLLLLLLLLLLSU6UUUUUUUUUUUUUUUUUUUUUUUUUUX:             
contract ArtNFT is
    ERC721Upgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    IMetaverseNFT // implements IERC2981
{
    using Address for address;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public constant SALE_STARTS_AT_INFINITY = 2**256 - 1;
    uint256 public constant DEVELOPER_FEE = 500; // of 10,000 = 5%

    uint256 public startTimestamp = SALE_STARTS_AT_INFINITY;
    uint256 public createdAt;

    uint256 public maxSupply;
    uint256 public amountOfAllTokens;

    uint256 public royaltyFee;

    address public royaltyReceiver;
    address public uriExtension = address(0x0);

    bool public isFrozen;
    bool private isOpenSeaProxyActive;

    /** 
    * @dev Additional data for each token that needs to be stored and accessed on-chain
    */
    mapping (uint256 => bytes32) public data;

    /**
    * @dev List of connected extensions
    */
    INFTExtension[] public extensions;

    /**
    * @dev Prices for each token
    */
    mapping (uint256 => uint256) public prices;

    string public PROVENANCE_HASH = "";
    string private CONTRACT_URI = "";
    string private BASE_URI;

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);
    event ExtensionURIAdded(address indexed extensionAddress);

    function initialize(
        uint256 _maxSupply,
        uint256 _royaltyFee,
        string memory _uri,
        string memory _name, string memory _symbol
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __ReentrancyGuard_init();
        __Ownable_init();

        createdAt = block.timestamp;
        startTimestamp = SALE_STARTS_AT_INFINITY;

        maxSupply = _maxSupply;

        royaltyFee = _royaltyFee;
        royaltyReceiver = address(this);

        // Need help with uploading metadata? Try https://buildship.dev
        BASE_URI = _uri;
    }

    // This constructor ensures that this contract can only be used as a master copy
    // Marking constructor as initializer makes sure that real initializer cannot be called
    // Thus, as the owner of the contract is 0x0, no one can do anything with the contract
    // on the other hand, it's impossible to call this function in proxy,
    // so the real initializer is the only initializer
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    function contractURI() public view returns (string memory uri) {
        uri = bytes(CONTRACT_URI).length > 0 ? CONTRACT_URI : _baseURI();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (uriExtension != address(0)) {
            string memory uri = INFTURIExtension(uriExtension).tokenURI(tokenId);

            if (bytes(uri).length > 0) {
                return uri;
            }
        }

        return super.tokenURI(tokenId);
    }

    function totalSupply() public view returns (uint256) {
        // Only works like this for sequential mint tokens
        return _tokenIdCounter.current();
    }

    // ----- Admin functions -----

    function setBaseURI(string calldata uri) public onlyOwner {
        BASE_URI = uri;
    }

    // Contract-level metadata for Opensea
    function setContractURI(string calldata uri) public onlyOwner {
        CONTRACT_URI = uri;
    }

    function batchSell(uint256[] calldata tokenIds, uint256[] calldata newPrices) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            prices[tokenIds[i]] = newPrices[i];
        }
        // TODO emit event    
    }

    function sell(uint256 tokenId, uint256 newPrice) public onlyOwner {
        prices[tokenId] = newPrice;
        // TODO emit event
    }

    // Freeze forever, irreversible
    function freeze() public onlyOwner {
        isFrozen = true;
    }

    function isExtensionAllowed(address _extension) public view returns (bool) {
        if (!ERC165Checker.supportsInterface(_extension, type(INFTExtension).interfaceId)) {
            return false;
        }

        for (uint index = 0; index < extensions.length; index++) {
            if (extensions[index] == INFTExtension(_extension)) {
                return true;
            }
        }

        return false;
    }

    // Extensions are allowed to mint
    function addExtension(address _extension) public onlyOwner {
        require(_extension != address(this), "Cannot add self as extension");

        require(!isExtensionAllowed(_extension), "Extension already added");

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

        require(extension == address(0x0) || ERC165Checker.supportsInterface(extension, type(INFTURIExtension).interfaceId), "Not conforms to extension");

        uriExtension = extension;

        emit ExtensionURIAdded(extension);
    }

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    // from CryptoCoven https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive) public onlyOwner {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    // ---- Minting ----

    function _mintConsecutive(uint256 nTokens, address to, bytes32 extraData) internal {
        require(amountOfAllTokens + nTokens <= maxSupply, "Not enough Tokens left.");
        for (uint256 i; i < nTokens; i++) {
            if (_exists(i)) continue;

            _safeMint(to, i);
            
            data[i] = extraData;
        }
        amountOfAllTokens = amountOfAllTokens + nTokens;
    }

    function _mintSpecific(uint256 tokenId, address to, bytes32 extraData) internal {
        require(amountOfAllTokens + 1 <= maxSupply, "Not enough Tokens left");

        _safeMint(to, tokenId);
        data[tokenId] = extraData;
        amountOfAllTokens = amountOfAllTokens + 1;
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

    modifier onlyExtension() {
        require(isExtensionAllowed(msg.sender), "Extension should be added to contract before minting");
        _;
    }

    // ---- Mint public ----

    // Contract can sell tokens
 
    function mint(uint256 tokenId) external payable nonReentrant whenSaleStarted {
        require(prices[tokenId] <= msg.value, "Inconsistend amount sent!");

        _mintSpecific(tokenId, msg.sender, 0x0);
    }   
    
     //Conract 

    // Owner can increase maxSupply

    function upgradeMaxSupply(uint256 countToAdd) external whenNotFrozen onlyOwner{
        maxSupply += countToAdd;
    }


    // Owner can claim free tokens
    function claim(uint256 nTokens, address to) external nonReentrant onlyOwner {
        _mintConsecutive(nTokens, to, 0x0);
    }

    // Owner can take special token from 0 to maxSupply
    function claimSpecific(uint256 tokenId, address to) external nonReentrant onlyOwner {
        _mintSpecific(tokenId, to, 0x0);
    }
    // ---- Mint via extension

    function mintExternal(uint256 nTokens, address to, bytes32 extraData) external payable onlyExtension nonReentrant {
        _mintConsecutive(nTokens, to, extraData);
    }


    // ---- Sale control ----

    function updateStartTimestamp(uint256 _startTimestamp) public onlyOwner whenNotFrozen {
        startTimestamp = _startTimestamp;
    }

    function startSale() public onlyOwner whenNotFrozen {
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
        require(block.timestamp >= createdAt + 26 weeks, "Only after 6 months of contract creation can the royalty receiver be changed.");
        royaltyReceiver = _receiver;
    }

    function royaltyInfo(uint256, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        // We use the same contract to split royalties: 5% of royalty goes to the developer
        receiver = royaltyReceiver;
        royaltyAmount = salePrice * royaltyFee / 10000;
    }

    // ---- Allow royalty deposits from Opensea ----- 

    receive() external payable {}

    // ---- Withdraw -----

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        uint256 amount = balance * (10000 - DEVELOPER_FEE) / 10000;

        address payable dev = DEVELOPER_ADDRESS();

        Address.sendValue(payable(msg.sender), amount);
        Address.sendValue(dev, balance - amount);
    }

    function withdrawToken(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));

        uint256 amount = balance * (10000 - DEVELOPER_FEE) / 10000;

        address payable dev = DEVELOPER_ADDRESS();

        token.safeTransfer(payable(msg.sender), amount);
        token.safeTransfer(dev, balance - amount);
    }

    function DEVELOPER() public pure returns (string memory _url) {
        _url = "https://buildship.dev";
    }

    function DEVELOPER_ADDRESS() public pure returns (address payable _dev) {
        _dev = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    }

    // -------- ERC721 overrides --------

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId
            || interfaceId == type(IMetaverseNFT).interfaceId
            || super.supportsInterface(interfaceId);
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
        ProxyRegistry proxyRegistry = ProxyRegistry(0xa5409ec958C83C3f309868babACA7c86DCB077c1);

        if (isOpenSeaProxyActive && address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

}
