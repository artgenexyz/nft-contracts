// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// TODO: update as AvatarNFT, here only few new methods compared to that
// TODO: add tests for this
contract BurnNFT is ERC721, ERC721Enumerable, IERC721Receiver, Ownable {
    uint256 public constant maxSupply = 10000;
    uint256 private _price = 0.03 ether;
    uint256 private _reserved = 250;

    string public PROVENANCE_HASH = "";
    uint256 public startingIndex;

    bool private _saleStarted;

    constructor() ERC721("HoldersClub", "HODL") {
        _saleStarted = false;
        // _registerInterface(IERC721Receiver.onERC721Received.selector);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://metadata.buildship.dev/api/token/hodl/";
    }

    function contractURI() public pure returns (string memory) {
        return "https://metadata.buildship.dev/api/token/hodl/";
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
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

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override(IERC721Receiver) returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
        // return bytes4(keccak256(abi.encodePacked(IERC721Receiver.onERC721Received.selector)));
    }

    modifier whenSaleStarted() {
        require(_saleStarted);
        _;
    }

    function flipSaleStarted() external onlyOwner {
        _saleStarted = !_saleStarted;

        if (_saleStarted && startingIndex == 0) {
            setStartingIndex();
        }
    }

    function saleStarted() public view returns (bool) {
        return _saleStarted;
    }

    // Make it possible to change the price: just in case
    function setPrice(uint256 _newPrice) external onlyOwner {
        _price = _newPrice;
    }

    function getPrice() public view returns (uint256) {
        return _price;
    }

    function getReservedLeft() public view returns (uint256) {
        return _reserved;
    }

    // This should be set before sales open.
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE_HASH = provenanceHash;
    }

    // Helper to list all the tokens of a wallet
    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function claimReserved(uint256 _number, address _receiver)
        external
        onlyOwner
    {
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
        uint256 _block_shift = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        );
        _block_shift = 1 + (_block_shift % 255);

        // This shouldn't happen, but just in case the blockchain gets a reboot?
        if (block.number < _block_shift) {
            _block_shift = 1;
        }

        uint256 _block_ref = block.number - _block_shift;
        startingIndex = uint256(blockhash(_block_ref)) % maxSupply;

        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex + 1;
        }
    }

    function withdraw() public onlyOwner {
        uint256 _balance = address(this).balance;

        require(payable(msg.sender).send(_balance));
    }

    function withdraw(ERC721 token, uint256 tokenId) public onlyOwner {
        token.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    // function mint(uint256 _nbTokens) external payable whenSaleStarted {
    //     uint256 supply = totalSupply();
    //     require(_nbTokens < 21, "You cannot mint more than 20 Tokens at once!");
    //     require(supply + _nbTokens <= maxSupply - _reserved, "Not enough Tokens left.");
    //     require(_nbTokens * _price <= msg.value, "Inconsistent amount sent!");

    //     for (uint256 i; i < _nbTokens; i++) {
    //         _safeMint(msg.sender, supply + i);
    //     }
    // }

    function burnAndMintOne(ERC721 token, uint256 tokenId)
        external
        payable
        whenSaleStarted
    {
        uint256 supply = totalSupply();
        require(supply < maxSupply - _reserved, "Not enough Tokens left.");
        require(_price <= msg.value, "Inconsistent amount sent!");

        // HACK: use unsafe transfer so that contract doesn't check
        token.safeTransferFrom(msg.sender, address(this), tokenId);

        _safeMint(msg.sender, supply + 1);
    }

    function burnAndMintAll(ERC721Enumerable token)
        external
        payable
        whenSaleStarted
    {
        // Call token.setApprovalForAll first!

        uint256 supply = totalSupply();
        uint256 nTokens = token.balanceOf(msg.sender);

        require(nTokens > 0, "You should mint at least 1 Token!");
        require(nTokens * _price <= msg.value, "Inconsistent amount sent!");
        require(nTokens < 50, "You cannot mint more than 50 Tokens at once!");
        require(
            supply + nTokens <= maxSupply - _reserved,
            "Not enough Tokens left."
        );

        // require(_nbTokens == nAllTokens, "You need to mint exactly how many you have");

        for (uint256 i; i < nTokens; i++) {
            uint256 tokenId = token.tokenOfOwnerByIndex(msg.sender, i);

            token.safeTransferFrom(msg.sender, address(this), tokenId);
            _safeMint(msg.sender, supply + i);

            // TODO: store burned token address and id
        }
    }
}
