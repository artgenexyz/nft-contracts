// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title LICENSE REQUIREMENT
 * @dev This contract is licensed under the MIT license.
 * @dev You're not allowed to remove PLATFORM() from contract
 */

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IERC4906.sol";
import "./interfaces/INFTExtension.sol";
import "./interfaces/IRenderer.sol";
import "./interfaces/IArtgene721.sol";
import "./interfaces/IArtgenePlatform.sol";
import "./utils/OpenseaProxy.sol";

/**
 * @title contract by artgene.xyz
 */

//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
//                                                                                                  //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#S%??%S#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%***++***S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?+***%?**+*#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@S+*+*#@@?+*+?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*+++%@@@#*+++S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@S+++*#@@@@%+++*#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*+++%@@@@@#*+++%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@S+++*#@@@@@@%+++*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?+++%@@@@@@@#++++S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@S++++#@@@@@@@@?+++*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?+++?@@@@@@@@@S++++S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#++++S@@@@@@@@@@*+++*%???#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@S+++*#@@@@@#S%?*+++++++++S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@?+++?@@@@#?+++;+++++++%%S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#++++S@@@#*;+++?%S%++++@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%;+++@@@@#+++;%@@@#+++;S@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;+;?@@@@@%;+;+#@@@*;+;?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#+;;;S@@@@@@?;;;+S@@%;;;+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%;;;+@@@@@@@@?;;;;?#%;;;+#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;;;?@@@@@@@@@%+;;;+;;;;?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#;;;;#@@@@@@@@@@#%*+;;;+%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#?+*%@@@@@@@@@@@@@@#SS#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    //
//                                                                                                  //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////

contract Artgene721Base is
    ERC721A,
    ERC721ABurnable,
    ReentrancyGuard,
    Ownable,
    IArtgene721 // implements IERC2981, IERC4906
{
    using Address for address;
    using SafeERC20 for IERC20;

    uint32 internal constant TIMESTAMP_INFINITY = type(uint32).max; // 4 294 967 295 is 136 years, which is year 2106

    uint256 internal constant MAX_PER_MINT_LIMIT = 50; // based on ERC721A limitations

    uint256 public PLATFORM_FEE; // of 10,000
    address payable PLATFORM_TREASURY;

    uint32 public startTimestamp;
    uint32 public endTimestamp;

    uint256 public reserved;
    uint256 public maxSupply;
    uint256 public maxPerMint;
    uint256 public maxPerWallet;
    uint256 public price;

    uint256 public royaltyFee;

    address public royaltyReceiver;
    address public payoutReceiver;
    address public renderer;

    bool public isPayoutChangeLocked;
    bool private isOpenSeaProxyActive;
    bool private startAtOne;

    /**
     * @dev Additional data for each token that needs to be stored and accessed on-chain
     */
    mapping(uint256 => bytes32) public data;

    /**
     * @dev Storing how many tokens each address has minted in public sale
     */
    mapping(address => uint256) public mintedBy;

    /**
     * @dev List of connected extensions
     */
    INFTExtension[] public extensions;

    string private baseURI;

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);
    event RendererAdded(address indexed extensionAddress);

    event Evolution(uint256 indexed tokenId, bytes32 dna);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _nReserved,
        bool _startAtOne,
        string memory _uri,
        MintConfig memory _config
    ) ERC721A(_name, _symbol) {
        // CHECK INPUTS
        // either open edition or limited edition
        if (_maxSupply == ARTGENE_MAX_SUPPLY_OPEN_EDITION) {
            require(
                _config.startTimestamp != 0 && _config.endTimestamp != 0,
                "OpenEdition requires start and end timestamp"
            );
            require(
                _config.startTimestamp < _config.endTimestamp,
                "OpenEdition requires startTimestamp < endTimestamp"
            );

            require(
                _config.maxTokensPerWallet != 0,
                "OpenEdition requires maxPerWallet != 0"
            );
        } else {
            // limited edition doesn't require start and end timestamp
            // you can provide them optionally
        }

        reserved = _nReserved;
        maxSupply = _maxSupply;

        require(
            _startAtOne == false,
            "Doesn't support starting at one with ERC721A"
        );
        startAtOne = _startAtOne;

        baseURI = _uri;

        maxPerMint = MAX_PER_MINT_LIMIT;
        isOpenSeaProxyActive = true;

        // test if platform is deployed
        require(
            ARTGENE_PLATFORM_ADDRESS.code.length != 0,
            "Platform not deployed"
        );

        (PLATFORM_FEE, PLATFORM_TREASURY) = IArtgenePlatform(
            ARTGENE_PLATFORM_ADDRESS
        ).getPlatformInfo();

        _configure(
            _config.publicPrice,
            _config.maxTokensPerMint,
            _config.maxTokensPerWallet,
            _config.royaltyFee,
            _config.payoutReceiver,
            _config.shouldLockPayoutReceiver,
            _config.startTimestamp,
            _config.endTimestamp
        );
    }

    function _configure(
        uint256 publicPrice,
        uint256 maxTokensPerMint,
        uint256 maxTokensPerWallet,
        uint256 _royaltyFee,
        address _payoutReceiver,
        bool shouldLockPayoutReceiver,
        uint32 _startTimestamp,
        uint32 _endTimestamp
    ) internal {
        if (_startTimestamp != 0) {
            startTimestamp = _startTimestamp;
        }

        if (_endTimestamp != 0) {
            endTimestamp = _endTimestamp;
        }

        if (publicPrice != 0) {
            price = publicPrice;
        }

        if (maxTokensPerMint > 0) {
            maxPerMint = maxTokensPerMint;
        }
        if (maxTokensPerWallet > 0) {
            maxPerWallet = maxTokensPerWallet;
        }

        if (_royaltyFee > 0) {
            royaltyFee = _royaltyFee;
        }

        if (_payoutReceiver != address(0)) {
            payoutReceiver = _payoutReceiver;
        }

        if (shouldLockPayoutReceiver) {
            isPayoutChangeLocked = true;
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        // NB: It requires static value, override when inherit
        return 0;
    }

    function isOpenEdition() internal view returns (bool) {
        return maxSupply == ARTGENE_MAX_SUPPLY_OPEN_EDITION;
    }

    // @dev used on Opensea to show collection-level metadata
    function contractURI() external view returns (string memory uri) {
        uri = _baseURI();
    }

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
    ) public view override(ERC721A, IERC721A) returns (string memory) {
        if (renderer != address(0)) {
            string memory uri = IRenderer(renderer).tokenURI(tokenId);

            if (bytes(uri).length > 0) {
                return uri;
            }
        }

        return super.tokenURI(tokenId);
    }

    function startTokenId() public view returns (uint256) {
        return _startTokenId();
    }

    // ----- Admin functions -----

    function setBaseURI(string calldata uri) public onlyOwner {
        baseURI = uri;

        // update metadata for all tokens
        if (_totalMinted() == 0) return;

        uint256 fromTokenId = _startTokenId();
        uint256 toTokenId = _startTokenId() + _totalMinted() - 1;

        emit BatchMetadataUpdate(fromTokenId, toTokenId);
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function reduceMaxSupply(
        uint256 _maxSupply
    ) public whenSaleNotStarted onlyOwner {
        require(
            _totalMinted() + reserved <= _maxSupply,
            "Max supply is too low, already minted more (+ reserved)"
        );

        require(
            _maxSupply < maxSupply,
            "Cannot set higher than the current maxSupply"
        );

        maxSupply = _maxSupply;
    }

    // Lock changing withdraw address
    function lockPayoutReceiver() public onlyOwner {
        isPayoutChangeLocked = true;
    }

    function isExtensionAdded(address _extension) public view returns (bool) {
        for (uint256 index = 0; index < extensions.length; index++) {
            if (address(extensions[index]) == _extension) {
                return true;
            }
        }

        return false;
    }

    function extensionsLength() external view returns (uint256) {
        return extensions.length;
    }

    function extensionList() external view returns (INFTExtension[] memory) {
        // @dev this is O(N), don't use this on-chain
        return extensions;
    }

    // Extensions are allowed to mint
    function addExtension(address _extension) public onlyOwner {
        require(_extension != address(this), "Cannot add self as extension");

        require(!isExtensionAdded(_extension), "Extension already added");

        extensions.push(INFTExtension(_extension));

        emit ExtensionAdded(_extension);
    }

    function revokeExtension(address _extension) public onlyOwner {
        uint256 index = 0;

        for (; index < extensions.length; index++) {
            if (extensions[index] == INFTExtension(_extension)) {
                break;
            }
        }

        extensions[index] = extensions[extensions.length - 1];
        extensions.pop();

        emit ExtensionRevoked(_extension);
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

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    // from CryptoCoven https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
    function setIsOpenSeaProxyActive(
        bool _isOpenSeaProxyActive
    ) public onlyOwner {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    // ---- Minting ----

    function _mintConsecutive(uint256 nTokens, address to) internal {
        if (isOpenEdition()) {
            // unlimited minting
        } else {
            require(
                _totalMinted() + nTokens + reserved <= maxSupply,
                "Not enough Tokens left."
            );
        }

        uint256 nextTokenId = _nextTokenId();

        _safeMint(to, nTokens, "");

        for (uint256 i; i < nTokens; i++) {
            uint256 tokenId = nextTokenId + i;

            bytes32 dna = _createDNA(tokenId);

            emit Evolution(tokenId, dna);
        }
    }

    // @dev depends on the current block, so it's not possible to know the DNA in advance
    function _createDNA(uint256 tokenId) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    bytes32(block.prevrandao),
                    blockhash(block.number - 1),
                    bytes32(tokenId)
                )
            );
    }

    // ---- Mint control ----

    modifier whenSaleActive() {
        require(saleStarted(), "Sale not active");
        _;
    }

    modifier whenSaleNotStarted() {
        require(!saleStarted(), "Sale should not be active");
        _;
    }

    modifier whenNotPayoutChangeLocked() {
        require(!isPayoutChangeLocked, "Payout change is locked");
        _;
    }

    modifier onlyExtension() {
        require(
            isExtensionAdded(msg.sender),
            "Extension should be added to contract before minting"
        );
        _;
    }

    // ---- Mint public ----

    // Contract can sell tokens
    function mint(
        uint256 nTokens
    ) external payable nonReentrant whenSaleActive {
        // setting it to 0 means no limit
        if (maxPerWallet > 0) {
            require(
                mintedBy[msg.sender] + nTokens <= maxPerWallet,
                "You cannot mint more than maxPerWallet tokens for one address!"
            );

            // only store minted amounts after limit is enabled to save gas
            mintedBy[msg.sender] += nTokens;
        }

        require(
            nTokens <= maxPerMint,
            "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!"
        );

        require(nTokens * price <= msg.value, "Inconsistent amount sent!");

        _mintConsecutive(nTokens, msg.sender);
    }

    // Owner can claim free tokens
    function claim(
        uint256 nTokens,
        address to
    ) external nonReentrant onlyOwner {
        require(nTokens <= reserved, "That would exceed the max reserved.");

        reserved = reserved - nTokens;

        _mintConsecutive(nTokens, to);
    }

    // ---- Mint via extension

    function mintExternal(
        uint256 nTokens,
        address to,
        bytes32
    ) external payable onlyExtension nonReentrant {
        _mintConsecutive(nTokens, to);
    }

    // ---- Mint configuration

    function updateMaxPerMint(
        uint256 _maxPerMint
    ) public onlyOwner nonReentrant {
        require(_maxPerMint <= MAX_PER_MINT_LIMIT, "Too many tokens per mint");
        maxPerMint = _maxPerMint;
    }

    // set to 0 to save gas, mintedBy is not used
    function updateMaxPerWallet(
        uint256 _maxPerWallet
    ) public onlyOwner nonReentrant {
        maxPerWallet = _maxPerWallet;
    }

    // ---- Sale control ----

    function updateStartTimestamp(uint32 _startTimestamp) public onlyOwner {
        startTimestamp = _startTimestamp;
    }

    function updateMintStartEnd(
        uint32 _startTimestamp,
        uint32 _endTimestamp
    ) public onlyOwner {
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
    }

    function startSale() public onlyOwner {
        startTimestamp = uint32(block.timestamp);

        if (endTimestamp < startTimestamp) {
            // if endTimestamp is not set, reset it to infinity
            endTimestamp = TIMESTAMP_INFINITY;
        }
    }

    function stopSale() public onlyOwner {
        startTimestamp = 0;
    }

    function saleStarted() public view returns (bool) {
        if (startTimestamp == 0) {
            // this is default value, means sale wasn't initilized
            // set startTimestamp to now to start sale
            return false;
        }

        if (endTimestamp == 0) {
            // if endTimestamp is not set, sale starts as usual
            return block.timestamp >= startTimestamp;
        }

        // otherwise check if sale is active
        return
            block.timestamp >= startTimestamp &&
            block.timestamp <= endTimestamp;
    }

    // ---- Offchain Info ----

    function setRoyaltyFee(uint256 _royaltyFee) public onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    function setPayoutReceiver(
        address _receiver
    ) public onlyOwner whenNotPayoutChangeLocked {
        payoutReceiver = payable(_receiver);
    }

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = getRoyaltyReceiver();
        royaltyAmount = (salePrice * royaltyFee) / 10000;
    }

    function getPayoutReceiver()
        public
        view
        returns (address payable receiver)
    {
        receiver = payoutReceiver != address(0x0)
            ? payable(payoutReceiver)
            : payable(owner());
    }

    function getRoyaltyReceiver()
        public
        view
        returns (address payable receiver)
    {
        receiver = royaltyReceiver != address(0x0)
            ? payable(royaltyReceiver)
            : getPayoutReceiver();
    }

    // ---- Allow royalty deposits from Opensea -----

    receive() external payable {}

    // ---- Withdraw -----

    modifier onlyPlatform() {
        require(
            payable(msg.sender) == PLATFORM_TREASURY,
            "Caller is not Platform"
        );
        _;
    }

    function _withdraw() private {
        uint256 balance = address(this).balance;
        uint256 amount = (balance * (10000 - PLATFORM_FEE)) / 10000;

        address payable receiver = getPayoutReceiver();
        address payable platform = PLATFORM_TREASURY;

        Address.sendValue(receiver, amount);
        Address.sendValue(platform, balance - amount);
    }

    function withdraw() public virtual onlyOwner {
        _withdraw();
    }

    function forceWithdrawPlatform() public virtual onlyPlatform {
        _withdraw();
    }

    function withdrawToken(IERC20 token) public virtual onlyOwner {
        uint256 balance = token.balanceOf(address(this));

        uint256 amount = (balance * (10000 - PLATFORM_FEE)) / 10000;

        address payable receiver = getPayoutReceiver();
        address payable platform = PLATFORM_TREASURY;

        token.safeTransfer(receiver, amount);
        token.safeTransfer(platform, balance - amount);
    }

    function PLATFORM() public pure returns (string memory _url) {
        _url = "https://artgene.xyz";
    }

    // -------- ERC721 overrides --------

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IERC4906).interfaceId ||
            interfaceId == type(IArtgene721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Override isApprovedForAll to allowlist user's OpenSea proxy accounts to enable gas-less listings.
     * Taken from CryptoCoven: https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        if (isOpenSeaProxyActive && operator == OPENSEA_CONDUIT) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    // @dev from openzeppelin-contracts/contracts/interfaces/IERC4906.sol
    function forceMetadataUpdate(
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) public onlyOwner {
        require(_fromTokenId <= _toTokenId, "Invalid range");

        /// @dev This event emits when the metadata of a range of tokens is changed.
        /// So that the third-party platforms such as NFT market could
        /// timely update the images and related attributes of the NFTs.
        emit BatchMetadataUpdate(_fromTokenId, _toTokenId);
    }
}
