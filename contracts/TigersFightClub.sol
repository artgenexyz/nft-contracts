// SPDX-License-Identifier: MIT
// Adapted from World of Women: https://etherscan.io/token/0xe785e82358879f061bc3dcac6f0444462d4b5330#readContract
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.2.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.2.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.2.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.2.0/utils/Counters.sol";

contract TigersFightClub is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public constant maxSupply = 10000;
    uint256 private _price = 0.03 ether;
    uint256 private _reserved = 200;

    string public TFC_PROVENANCE = "";
    uint256 public startingIndex;

    bool private _saleStarted;
    // string public baseURI;

    constructor() ERC721("TigersFightClub", "TFC") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://tigersfightclub.vercel.app/api/token/tfc/";
    }
    
    function contractURI() public pure returns (string memory) {
        return "https://tigersfightclub.vercel.app/api/token/tfc/";
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
        require(_saleStarted);
        _;
    }

    function mint(uint256 _nbTokens) external payable whenSaleStarted {
        uint256 supply = totalSupply();
        require(_nbTokens < 21, "You cannot mint more than 20 Tokens at once!");
        require(supply + _nbTokens <= maxSupply - _reserved, "Not enough Tokens left.");
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
        TFC_PROVENANCE = provenanceHash;
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
        startingIndex = uint(blockhash(_block_ref)) % maxSupply;

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
