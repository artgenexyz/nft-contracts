// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBadgeNFT is IERC721 {
    function getRawData(uint256 _tokenId) external view returns (bytes32); 
}

contract BadgeNFT is ERC721, ERC721Enumerable, IBadgeNFT, Ownable {

    // bytes32 bitmask = 0x0;
    // later we can use this to marker which RANGES of bytes32 data encapsulate which values
    // e.g. bitmask = 0x1111111122222222
    // would have first 8 bytes for field1, second 8 bytes for field2, the rest would be irrelevant

    mapping (uint256 => bytes32) public data;

    // Human-readable description of what's inside bytes32 data
    string public BADGE_README;

    // TODO: create factory for badges, for now everyone deploys them by themselves
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description
        // bytes32 _bitmask
    ) ERC721(_name, _symbol) {
        // bitmask = _bitmask;
        BADGE_README = _description;
    }

    function getRawData(uint256 _tokenId) external view returns (bytes32) {
        return data[_tokenId];
    }

    /**
     * For example, after hackathon finish,
     * ETHGlobal runs `issue` over a list of winners,
     * with data = 0x{year}{category_id}{place}
     */
    function issue(address _receiver, bytes32 _data) public onlyOwner {
        uint256 tokenId = nextTokenId();

        _safeMint(_receiver, tokenId);

        data[tokenId] = _data;
    }

    function nextTokenId() internal view returns (uint256) {
        // TODO: replace with OpenZeppelin Counter, autoincrement in this function
        return totalSupply();
    }

    // ----- Required overrides ------

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
