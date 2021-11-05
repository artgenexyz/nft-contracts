// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// This implementation has free or paid mint passes, limited by address
contract MintPass is ERC1155, Ownable {
    constructor(
        uint256 _maxSupply,
        uint256 _maxPerAddress,
        uint256 _price,
        string memory uri
    ) ERC1155(uri) {
        maxSupply = _maxSupply;
        maxPerAddress = _maxPerAddress;
        price = _price;
    }

    uint256 public constant MINT_PASS_ID = 0;

    // TODO: maybe admin can edit this?
    uint256 immutable price;
    uint256 immutable maxPerAddress;
    uint256 immutable maxSupply;

    uint256 public mintedSupply;

    mapping(address => uint256) internal mintedPerAddress;

    // ---- Sale control block

    bool private _saleStarted;

    modifier whenSaleStarted() {
        require(_saleStarted, "Sale not started");
        _;
    }

    function saleStarted() public view returns (bool) {
        return _saleStarted;
    }

    function flipSaleStarted() external onlyOwner {
        _saleStarted = !_saleStarted;
    }

    // ---- Admin functions

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // ---- User functions

    function claim(uint256 nTokens) public payable virtual whenSaleStarted {
        require(nTokens > 0, "Too few tokens");
        require(
            mintedSupply + nTokens <= maxSupply,
            "Already minted too much tokens"
        );
        require(
            mintedPerAddress[msg.sender] + nTokens <= maxPerAddress,
            "Too many tokens per address"
        );

        require(msg.value >= nTokens * price, "Not enough ETH");

        mintedSupply += nTokens;
        mintedPerAddress[msg.sender] += nTokens;

        _mint(msg.sender, MINT_PASS_ID, nTokens, "");
    }

}
