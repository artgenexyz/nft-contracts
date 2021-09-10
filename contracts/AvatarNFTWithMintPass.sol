// SPDX-License-Identifier: MIT
// Adapted from World of Women: https://etherscan.io/token/0xe785e82358879f061bc3dcac6f0444462d4b5330#readContract
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AvatarNFTWithMintPass is ERC721, ERC721Enumerable, Ownable {

    uint256 private _price = 0.03 ether;
    uint256 private _reserved = 200;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_TOKENS_PER_MINT = 20;

    uint256 public startingIndex;

    address public constant MINT_PASS_ADDRESS = 0x0000000000000000000000000000000000000000;

    bool private _saleStarted;

    string public PROVENANCE_HASH = "";
    string public baseURI = "https://metadata.buildship.dev/api/token/NFT/";

    constructor() ERC721("Avatar Collection NFT", "NFT") {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
    
    function contractURI() public view returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata uri) public onlyOwner {
        baseURI = uri;
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
    
    
    modifier whenSaleStarted() {
        require(_saleStarted, "Sale not started");
        _;
    }

    modifier withMintPass() {
        // ONLY ADDED THIS CHECK
        require(
            ERC721(MINT_PASS_ADDRESS).balanceOf(msg.sender) > 0,
            "You should have Mint Pass to access the sale"
        );
        _;
    }

    function mint(uint256 _nbTokens) external payable whenSaleStarted withMintPass {
        uint256 supply = totalSupply();
        require(_nbTokens <= MAX_TOKENS_PER_MINT, "You cannot mint more than 20 Tokens at once!");
        require(supply + _nbTokens <= MAX_SUPPLY - _reserved, "Not enough Tokens left.");
        require(_nbTokens * _price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < _nbTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function flipSaleStarted() external onlyOwner {
        _saleStarted = !_saleStarted;

        if (_saleStarted && startingIndex == 0) {
            setStartingIndex();
        }
    }

    function saleStarted() public view returns(bool) {
        return _saleStarted;
    }

    // Make it possible to change the price: just in case
    function setPrice(uint256 _newPrice) external onlyOwner {
        _price = _newPrice;
    }

    function getPrice() public view returns (uint256){
        return _price;
    }

    function getReservedLeft() public view returns (uint256) {
        return _reserved;
    }

    // This should be set before sales open.
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE_HASH = provenanceHash;
    }

    // Helper to list all the Tigers of a wallet
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function claimReserved(uint256 _number, address _receiver) external onlyOwner {
        require(_number <= _reserved, "That would exceed the max reserved.");

        uint256 _tokenId = totalSupply();
        for (uint256 i; i < _number; i++) {
            _safeMint(_receiver, _tokenId + i);
        }

        _reserved = _reserved - _number;
    }

    function setStartingIndex() public {
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

    function withdraw() public onlyOwner {
        uint256 _balance = address(this).balance;

        require(payable(msg.sender).send(_balance));
    }

    
}
