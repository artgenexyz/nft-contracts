pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721CommunityBase is Context, Ownable, ERC721Enumerable, ERC721URIStorage {
    using Address for address;

    uint256 private _maxSupply;
    uint256 private _totalMinted;

    constructor (
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_,
        uint256 maxSupply_
    ) ERC721(name_, symbol_) {
        _maxSupply = maxSupply_;
        _setBaseURI(baseTokenURI_);
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }

    function totalMinted() public view virtual returns (uint256) {
        return _totalMinted;
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721CommunityBase: Caller is not owner nor approved");
        _burn(tokenId);
        _maxSupply -= 1;
    }

    function reduceMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply <= _maxSupply, "ERC721CommunityBase: New max supply is greater than current max supply");
        require(newMaxSupply >= _totalMinted, "ERC721CommunityBase: New max supply is less than total minted");
        _maxSupply = newMaxSupply;
    }

    // Overriden functions from OpenZeppelin's ERC721

    function _mint(address to, uint256 tokenId) internal virtual override {
        require(totalMinted() < maxSupply(), "ERC721CommunityBase: Max supply reached");
        _totalMinted += 1;
        super._mint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}