// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./factory/extensions/INFTExtension.sol";
import "./factory/IMetaverseNFT.sol";
import "./utils/OpenseaProxy.sol";

// Want to launch your own collection ? Check out https://buildship.dev

/** 
    * @title AvatarNFTv2
    * @dev Upgrade for AvatarNFT, featuring extensions
    * @dev Other features include: optional freeze, royalty on-chain, setBeneficiary
 */
contract AvatarNFTv2 is ERC721, ERC721Enumerable, IAvatarNFT, Ownable {

    uint256 public price;
    uint256 public reserved;

    uint256 public MAX_SUPPLY;
    uint256 public MAX_TOKENS_PER_MINT;

    uint256 public startingIndex;

    uint256 public royaltyFee;
    address public royaltyReceiver;

    // ** Address for withdrawing money, separate from owner
    address payable beneficiary;

    bool public saleStarted;
    bool public isFrozen;
    bool public isOpenSeaProxyActive = true; // Active by default, disable in case of compromised proxy

    string public PROVENANCE_HASH = "";
    string public baseURI;

    mapping (address => bool) public isExtensionAdded;

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);

    constructor(
        uint256 _startPrice, uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxTokensPerMint,
        string memory _uri,
        string memory _name, string memory _symbol
    ) ERC721(_name, _symbol) {
        price = _startPrice;
        reserved = _nReserved;
        MAX_SUPPLY = _maxSupply;
        MAX_TOKENS_PER_MINT = _maxTokensPerMint;
        baseURI = _uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function contractURI() public view returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata uri) public onlyOwner {
        baseURI = uri;
    }

    function setBeneficiary(address payable _beneficiary) public virtual onlyOwner {
        beneficiary = _beneficiary;
    }

    // Freeze forever, unreversible
    function freeze() public onlyOwner {
        isFrozen = true;
    }

    modifier whenNotFrozen() {
        require(!isFrozen, "Minting is frozen");
        _;
    }

    function addExtension(address _extension) public onlyOwner whenNotFrozen {
        require(_extension != address(this), "Cannot add self as extension");

        require(ERC165Checker.supportsInterface(_extension, type(INFTExtension).interfaceId), "Not conforms to extension");

        isExtensionAdded[_extension] = true;

        emit ExtensionAdded(_extension);
    }

    function revokeExtension(address _extension) public onlyOwner {
        isExtensionAdded[_extension] = false;

        emit ExtensionRevoked(_extension);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function data(uint256) public pure returns (bytes32) {
        return 0x0;
    }

    modifier whenSaleStarted() {
        require(saleStarted, "Sale not started");
        _;
    }

    modifier onlyExtension() {
        require(isExtensionAdded[msg.sender], "Extension should be added to contract before minting");
        _;
    }

    function mintExternal(uint256 _nbTokens, address to, bytes32) public payable virtual onlyExtension {
        uint256 supply = totalSupply();

        require(supply + _nbTokens <= MAX_SUPPLY - reserved, "Not enough Tokens left.");

        for (uint256 i; i < _nbTokens; i++) {
            _safeMint(to, supply + i);
        }
    }

    function mint(uint256 _nbTokens) whenSaleStarted public payable virtual {
        uint256 supply = totalSupply();
        require(_nbTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!");
        require(supply + _nbTokens <= MAX_SUPPLY - reserved, "Not enough Tokens left.");
        require(_nbTokens * price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < _nbTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function flipSaleStarted() external onlyOwner {
        require(beneficiary != address(0), "Beneficiary not set");

        saleStarted = !saleStarted;

        if (saleStarted && startingIndex == 0) {
            setStartingIndex();
        }
    }

    // Make it possible to change the price: just in case
    function setPrice(uint256 _newPrice) external virtual onlyOwner {
        price = _newPrice;
    }

    function getPrice() public view virtual returns (uint256){
        return price;
    }

    function getReservedLeft() public view virtual returns (uint256) {
        return reserved;
    }

    // This should be set before sales open.
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE_HASH = provenanceHash;
    }

    // Helper to list all the tokens of a wallet
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function claimReserved(uint256 _number, address _receiver) external onlyOwner virtual {
        require(_number <= reserved, "That would exceed the max reserved.");

        uint256 _tokenId = totalSupply();
        for (uint256 i; i < _number; i++) {
            _safeMint(_receiver, _tokenId + i);
        }

        reserved = reserved - _number;
    }

    function setStartingIndex() public virtual {
        require(startingIndex == 0, "Starting index is already set");

        // BlockHash only works for the most 256 recent blocks.
        uint256 _block_shift = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        _block_shift =  1 + (_block_shift % 255);

        // This shouldn't happen, but just in case the blockchain gets a reboot?
        if (block.number < _block_shift) {
            _block_shift = 1;
        }

        uint256 _block_ref = block.number - _block_shift;
        startingIndex = uint(blockhash(_block_ref)) % MAX_SUPPLY;

        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex + 1;
        }
    }

    function withdraw() public virtual onlyOwner {
        require(beneficiary != address(0), "Beneficiary not set");

        uint256 _balance = address(this).balance;

        require(payable(beneficiary).send(_balance));
    }

    function setRoyaltyFee(uint256 _royaltyFee) public onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    function royaltyInfo(uint256, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = royaltyReceiver;
        royaltyAmount = salePrice * royaltyFee / 10000;
    }

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    // from CryptoCoven https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive) public onlyOwner {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
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

    function DEVELOPER() public pure returns (string memory _url) {
        _url = "https://buildship.dev";
    }

    function DEVELOPER_ADDRESS() public pure returns (address payable _dev) {
        _dev = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    }
}
