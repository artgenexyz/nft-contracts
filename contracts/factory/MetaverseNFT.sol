// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
* @title LICENSE REQUIREMENT
* @dev This contract is licensed under the MIT license.
* @dev You're not allowed to remove DEVELOPER() and DEVELOPER_ADDRESS() from contract
*/

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./extensions/INFTExtension.sol";

import "./OpenseaProxy.sol";


//      Want to launch your own collection ? Check out https://buildship.dev.
//      Tell us the promo code ORIGINAL NFT for a 10% discount!
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


/**
    * This is the main contract for the NFT collection.
    * This is a copy of AvatarNFT.sol, but all the OpenZeppelin code is replaced with the upgradeable versions.
    * ! The constructor is replaced with initializer, too
    * This way, deployment costs about 350k gas instead of 4.5M.
    * 1. https://forum.openzeppelin.com/t/how-to-set-implementation-contracts-for-clones/6085/4
    * 2. https://github.com/OpenZeppelin/workshops/tree/master/02-contracts-clone/contracts/2-uniswap
    * 3. https://docs.openzeppelin.com/contracts/4.x/api/proxy
 */

// TODO: add Opensea autoapprove?
contract MetaverseNFT is
    ERC721Upgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable,
    // ReentrancyGuardUpgradeable,
    IERC2981
{
    using Address for address;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public reserved; // = 10;

    uint256 public constant DEVELOPER_FEE = 500; // of 10,000 = 5%
    uint256 public MAX_SUPPLY; // = 10000;

    uint256 public royaltyFee = 0; // of 10,000
    uint256 public startingIndex;
    uint256 public createdAt;

    address public royaltyReceiver;

    bool public isFrozen;
    bool private isOpenSeaProxyActive;

    mapping (uint256 => bytes32) public tokenData;
    mapping (address => bool) public isExtensionAllowed;

    address public uriExtension = address(0x0);

    string public PROVENANCE_HASH = "";
    string public CONTRACT_URI = "";
    string public BASE_URI;

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);
    event ExtensionURIAdded(address indexed extensionAddress);

    function initialize(
        uint256 _maxSupply,
        uint256 _nReserved,
        string memory _uri,
        string memory _name, string memory _symbol
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __ERC721Burnable_init();
        __Ownable_init();
        // __ReentrancyGuard_init();

        createdAt = block.timestamp;
        royaltyReceiver = address(this);

        reserved = _nReserved;
        MAX_SUPPLY = _maxSupply;

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
        uri = bytes(CONTRACT_URI).length == 0 ? CONTRACT_URI : _baseURI();
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

    function setExtensionTokenURI(address extension) public onlyOwner whenNotFrozen {
        require(extension != address(this), "Cannot add self as extension");

        require(ERC165Checker.supportsInterface(extension, type(INFTURIExtension).interfaceId), "Not conforms to extension");

        // isExtensionAllowed[extension] = true;

        uriExtension = extension;

        emit ExtensionURIAdded(extension);
    }

    // Optionally, migrate to IPFS and freeze metadata later
    function setBaseURI(string calldata uri) public onlyOwner whenNotFrozen {
        BASE_URI = uri;
    }

    // // Contract-level metadata for Opensea
    // function setContractURI(string calldata uri) public onlyOwner whenNotFrozen {
    //     CONTRACT_URI = uri;
    // }

    // Freeze forever, unreversible
    function freeze() public onlyOwner {
        isFrozen = true;
    }

    function addExtension(address _extension) public onlyOwner whenNotFrozen {
        require(_extension != address(this), "Cannot add self as extension");

        require(ERC165Checker.supportsInterface(_extension, type(INFTExtension).interfaceId), "Not conforms to extension");

        isExtensionAllowed[_extension] = true;

        emit ExtensionAdded(_extension);
    }

    function revokeExtension(address _extension) public onlyOwner {
        isExtensionAllowed[_extension] = false;

        emit ExtensionRevoked(_extension);
    }

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    // from CryptoCoven https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive) public onlyOwner {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    // ---- Minting ----

    function _mintConsecutive(uint256 nTokens, address to, bytes32 data) internal {
        // uint256 supply = totalSupply();
        // require(_nbTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");

        require(_tokenIdCounter.current() + nTokens + reserved <= MAX_SUPPLY, "Not enough Tokens left.");

        for (uint256 i; i < nTokens; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            _safeMint(to, tokenId);
            tokenData[tokenId] = data;
        }
    }

    // ---- Mint control ----

    // modifier whenSaleStarted() {
    //     require(saleStarted, "Sale not started");
    //     _;
    // }

    modifier whenNotFrozen() {
        require(!isFrozen, "Minting is frozen");
        _;
    }

    modifier onlyExtension() {
        require(isExtensionAllowed[msg.sender], "Extension should be added to contract before minting");
        _;
    }

    // ---- Mint public ----

    // Contract can sell tokens
    // function mint(uint256 nTokens) external payable {
    //     // uint256 supply = totalSupply();
    //     require(nTokens <= 10000, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");

    //     // TODO: dont check MAX_SUPPLY if collection is unfrozen
    //     // require(supply + nTokens <= MAX_SUPPLY - reserved, "Not enough Tokens left.");

    //     require(nTokens * 1 ether <= msg.value, "Inconsistent amount sent!");

    //     _mintConsecutive(nTokens, msg.sender, 0x0);
    // }

    // // Owner can claim free tokens
    function claim(uint256 nTokens, address to) external onlyOwner {
        require(nTokens <= reserved, "That would exceed the max reserved.");

        _mintConsecutive(nTokens, to, 0x0);

        reserved = reserved - nTokens;
    }

    // ---- Mint via extension

    function mintExternal(uint256 nTokens, address to, bytes32 data) external payable onlyExtension whenNotFrozen {
        // uint256 supply = totalSupply();

        // DONT CHECK HERE, extensions are allowed to do anything
        // require(supply + nTokens <= MAX_SUPPLY - reserved, "Not enough Tokens left.");

        _mintConsecutive(nTokens, to, data);
    }

    // // ---- Sale control ----
    // function flipSaleStarted() external onlyOwner whenNotFrozen {
    //     saleStarted = !saleStarted;

    //     if (saleStarted && startingIndex == 0) {
    //         setStartingIndex();
    //     }
    // }

    // Make it possible to change the price: just in case
    // function setPrice(uint256 _price) external onlyOwner {
    //     price = _price;
    // }

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

    // NOTICE: This function is not meant to be called by the user.
    // Contrary to AvatarNFT, where it is public
    // function setStartingIndex() internal onlyOwner {
    //     // moved to extension

    //     // require(startingIndex == 0, "Starting index is already set");

    //     // // BlockHash only works for the most 256 recent blocks.
    //     // uint256 _block_shift = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    //     // _block_shift =  1 + (_block_shift % 255);

    //     // // This shouldn't happen, but just in case the blockchain gets a reboot?
    //     // if (block.number < _block_shift) {
    //     //     _block_shift = 1;
    //     // }

    //     // uint256 _block_ref = block.number - _block_shift;
    //     // startingIndex = uint(blockhash(_block_ref)) % MAX_SUPPLY;

    //     // // Prevent default sequence
    //     // if (startingIndex == 0) {
    //     //     startingIndex = startingIndex + 1;
    //     // }
    // }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        uint256 amount = balance * (10000 - DEVELOPER_FEE) / 10000;

        address payable dev = DEVELOPER_ADDRESS();

        Address.sendValue(payable(msg.sender), amount);
        Address.sendValue(dev, balance - amount);
    }

    // function withdrawToken(IERC20 token) public onlyOwner {
    //     uint256 balance = token.balanceOf(address(this));

    //     uint256 amount = balance * (10000 - DEVELOPER_FEE) / 10000;

    //     address payable dev = DEVELOPER_ADDRESS();

    //     token.safeTransfer(payable(msg.sender), amount);
    //     token.safeTransfer(dev, balance - amount);
    // }

    function DEVELOPER() public pure returns (string memory _url) {
        _url = "https://buildship.dev";
    }

    function DEVELOPER_ADDRESS() public pure returns (address payable _dev) {
        _dev = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC721Upgradeable)
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
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
