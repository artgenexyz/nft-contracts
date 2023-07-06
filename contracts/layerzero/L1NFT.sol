// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/solidity-examples/contracts/token/onft/ONFT721.sol";

import "../utils/OpenseaProxy.sol";

contract GradientsL1 is ONFT721 {
    string public uri = "https://metadata.artgene.xyz/api/g/era/gradients/";

    address public royaltyReceiver;
    uint256 public royaltyFee = 500;

    // true by default, can be disabled manually
    bool public isOpenSeaProxyActive = true;

    // minimal gas required to mint nft
    uint constant DEFAULT_MIN_GAS_STORE_TRANSFER = 150_000;

    constructor(
        address _lzEndpoint
    )
        ONFT721(
            "Infinite Shades of Gradient",
            "GRADIENTS",
            DEFAULT_MIN_GAS_STORE_TRANSFER,
            _lzEndpoint
        )
    {}

    function setBaseURI(string memory _uri) external onlyOwner {
        uri = _uri;
    }

    function setIsOpenSeaProxyActive(
        bool _isOpenSeaProxyActive
    ) external onlyOwner {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    function setRoyaltyFee(uint256 _royaltyFee) public onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uri;
    }

    function PLATFORM() public pure returns (string memory) {
        return "https://artgene.xyz";
    }

    function getRoyaltyReceiver()
        public
        view
        returns (address payable receiver)
    {
        receiver = royaltyReceiver != address(0)
            ? payable(royaltyReceiver)
            : payable(owner());
    }

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = getRoyaltyReceiver();
        royaltyAmount = (salePrice * royaltyFee) / 10000;
    }

    /**
     * @dev Override isApprovedForAll to allowlist user's OpenSea proxy accounts to enable gas-less listings.
     * Taken from CryptoCoven: https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view override(ERC721, IERC721) returns (bool) {
        if (isOpenSeaProxyActive && operator == OPENSEA_CONDUIT) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}
