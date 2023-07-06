// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "lib/solidity-examples/contracts/token/onft/ONFT721.sol";

import "../interfaces/IRenderer.sol";
import "../utils/OpenseaProxy.sol";

contract Gradients is ONFT721 {
    uint constant DEFAULT_MIN_GAS_STORE_TRANSFER = 150_000;

    event RendererAdded(address indexed extensionAddress);

    // ==== token metadata ====
    address public renderer;

    string public uri = "https://metadata.artgene.xyz/api/g/era/gradients/";

    // ==== marketplace metadata ====

    // @dev true by default, can be disabled manually
    bool public isOpenSeaProxyActive = true;

    address public royaltyReceiver;
    uint256 public royaltyFee = 500;

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

    function setRenderer(address _renderer) public onlyOwner {
        require(_renderer != address(this), "Cannot add self as renderer");

        require(
            _renderer == address(0) ||
                ERC165Checker.supportsInterface(
                    _renderer,
                    type(IRenderer).interfaceId
                ),
            "Not conforms to renderer interface"
        );

        renderer = _renderer;

        emit RendererAdded(_renderer);
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

    // ====== token metadata ======
    function tokenHTML(
        uint256 tokenId,
        bytes32 dna,
        bytes calldata _data
    ) external view returns (string memory) {
        if (renderer != address(0)) {
            return IRenderer(renderer).tokenHTML(tokenId, dna, _data);
        }

        return "";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (renderer != address(0)) {
            string memory _uri = IRenderer(renderer).tokenURI(tokenId);

            if (bytes(_uri).length > 0) {
                return uri;
            }
        }

        return super.tokenURI(tokenId);
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
