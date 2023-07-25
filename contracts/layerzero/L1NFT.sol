// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "lib/solidity-examples/contracts/token/onft/ONFT721.sol";

import "lib/era-contracts/ethereum/contracts/common/interfaces/IAllowList.sol";
import "lib/era-contracts/ethereum/contracts/zksync/interfaces/IZkSync.sol";
import "lib/era-contracts/ethereum/contracts/common/libraries/L2ContractHelper.sol";
import "lib/era-contracts/ethereum/contracts/vendor/AddressAliasHelper.sol";

import "../interfaces/IRenderer.sol";
import "../utils/OpenseaProxy.sol";

import "../Artgene721Base.sol";

contract L1NFT is ONFT721 {
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

    mapping(address => uint) totalMintedAmountPerUser;

    IZkSync public immutable zkSync;
    address public immutable l2Nft;

    event MintInitiated(
        bytes32 indexed l2TxHash,
        address indexed sender,
        address indexed l2Receiver,
        // address l1Token,
        uint256 tokenId
    );

    constructor(
        IZkSync _zkSync,
        address _lzEndpoint,
        address _l2nft
    )
        ONFT721(
            "Infinite Shades of Gradient",
            "GRADIENTS",
            DEFAULT_MIN_GAS_STORE_TRANSFER,
            _lzEndpoint
        )
    {
        zkSync = _zkSync;
        l2Nft = _l2nft;
    }

    event MintRequest(
        address indexed sender,
        address indexed l2Receiver,
        uint256 quantity
    );

    function mintRequest(uint256 _quantity) external payable {
        require(msg.value >= 0.001 ether * _quantity, "not enough funds");

        emit MintRequest(msg.sender, msg.sender, _quantity);
    }

    function _verifyMintLimit(address _minter, uint256 _quantity) internal {
        // IAllowList.Deposit memory limitData = IAllowList(allowList)
        //     .getTokenMintLimitData(_l1Token);
        // if (!limitData.mintLimitation) return; // no mint limitation is placed for this token

        require(totalMintedAmountPerUser[_minter] + _quantity <= 100, "d0");
        totalMintedAmountPerUser[_minter] += _quantity;
    }

    function estimateL2GasCost(
        address _l2Receiver,
        uint256 _quantity,
        uint256 _gasPrice,
        uint256 _l2TxGasPerPubdataByteLimit
    ) public view returns (uint256) {
        bytes memory l2TxCalldata = abi.encodeWithSelector(
            Artgene721Base.mint.selector,
            _quantity
        );

        return
            zkSync.l2TransactionBaseCost(
                _gasPrice,
                l2TxCalldata.length,
                _l2TxGasPerPubdataByteLimit // 800, // REQUIRED_L2_GAS_PRICE_PER_PUBDATA,
            );
    }

    function mint(
        address _l2Receiver,
        uint256 _quantity,
        uint256 _l2TxGasPrice,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) public payable nonReentrant returns (bytes32 l2TxHash) {
        require(_quantity != 0, "Token ID cannot be zero");

        // Verify the minting limit
        _verifyMintLimit(msg.sender, _quantity);

        bytes memory l2TxCalldata = abi.encodeWithSelector(
            Artgene721Base.mint.selector,
            _quantity
        );

        address refundRecipient = _refundRecipient;
        if (_refundRecipient == address(0)) {
            refundRecipient = msg.sender != tx.origin
                ? AddressAliasHelper.applyL1ToL2Alias(msg.sender)
                : msg.sender;
        }

        l2TxHash = zkSync.requestL2Transaction{value: msg.value - 0.001 ether * _quantity}(
            l2Nft,
            0.001 ether * _quantity,
            l2TxCalldata,
            _l2TxGasLimit,
            _l2TxGasPerPubdataByte,
            new bytes[](0),
            refundRecipient
        );

        emit MintInitiated(
            l2TxHash,
            msg.sender,
            _l2Receiver,
            // _l1Token,
            _quantity
        );
    }

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
