// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title LICENSE REQUIREMENT
 * @dev This contract is licensed under the MIT license.
 * @dev You're not allowed to remove DEVELOPER() from contract
 */

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/INFTExtension.sol";
import "./interfaces/IRenderer.sol";
import "./interfaces/IArtgene721.sol";
import "./interfaces/IArtgenePlatform.sol";
import "./utils/OpenseaProxy.sol";
import "./utils/operator-filterer/upgradable/DefaultOperatorFiltererUpgradeable.sol";

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


contract Artgene721Implementation is
    ERC721AUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    DefaultOperatorFiltererUpgradeable,
    IArtgene721Implementation,
    IArtgene721 // implements IERC2981
{
    using Address for address;
    using SafeERC20 for IERC20;

    uint256 internal constant SALE_STARTS_AT_INFINITY = 2 ** 256 - 1;
    uint256 internal constant MAX_PER_MINT_LIMIT = 50; // based on ERC721A limitations
    address internal constant OPENSEA_CONDUIT =
        0x1E0049783F008A0085193E00003D00cd54003c71;

    uint256 public constant VERSION = 3;

    uint256 public startTimestamp;

    uint256 public PLATFORM_FEE; // of 10,000
    address payable PLATFORM_TREASURY;

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

    string public PROVENANCE_HASH = "";
    string private CONTRACT_URI = "";
    string private BASE_URI;
    string private URI_POSTFIX = "";

    event ExtensionAdded(address indexed extensionAddress);
    event ExtensionRevoked(address indexed extensionAddress);
    event RendererAdded(address indexed extensionAddress);

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _nReserved,
        bool _startAtOne,
        string memory _uri,
        MintConfig memory _config
    ) public initializerERC721A initializer {
        reserved = _nReserved;
        maxSupply = _maxSupply;

        // should be set before calling ERC721A_init !
        startAtOne = _startAtOne;

        BASE_URI = _uri;

        // defaults
        startTimestamp = SALE_STARTS_AT_INFINITY;
        maxPerMint = MAX_PER_MINT_LIMIT;
        isOpenSeaProxyActive = true;
        isOpenSeaTransferFilterEnabled = true;

        (PLATFORM_FEE, PLATFORM_TREASURY) = IArtgenePlatform(ARTGENE_PLATFORM_ADDRESS).getPlatformInfo();

        __ERC721A_init(_name, _symbol);
        __ReentrancyGuard_init();
        __Ownable_init();
        __DefaultOperatorFilterer_init();

        _configure(
            _config.publicPrice,
            _config.maxTokensPerMint,
            _config.maxTokensPerWallet,
            _config.royaltyFee,
            _config.payoutReceiver,
            _config.shouldLockPayoutReceiver,
            _config.shouldStartSale,
            _config.shouldUseJsonExtension
        );
    }

    function _configure(
        uint256 publicPrice,
        uint256 maxTokensPerMint,
        uint256 maxTokensPerWallet,
        uint256 _royaltyFee,
        address _payoutReceiver,
        bool shouldLockPayoutReceiver,
        bool shouldStartSale,
        bool shouldUseJsonExtension
    ) internal {
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

        if (shouldStartSale) {
            // start sale right now
            startTimestamp = block.timestamp;
        }

        if (shouldUseJsonExtension) {
            URI_POSTFIX = ".json";
        }
    }

    // This constructor ensures that this contract can only be used as a master copy
    // Marking constructor as initializer makes sure that real initializer cannot be called
    // Thus, as the owner of the contract is 0x0, no one can do anything with the contract
    // on the other hand, it's impossible to call this function in proxy,
    // so the real initializer is the only initializer
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {
        // NB: this is run only once per implementation, when it's deployed
        // NB: this is NOT run when deploying Proxy
        require(address(this) == ARTGENE_PROXY_IMPLEMENTATION, "Only deployable to vanity address");

    }

    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return startAtOne ? 1 : 0;
    }

    function contractURI() public view returns (string memory uri) {
        uri = bytes(CONTRACT_URI).length > 0 ? CONTRACT_URI : _baseURI();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (renderer != address(0)) {
            string memory uri = IRenderer(renderer).tokenURI(
                tokenId
            );

            if (bytes(uri).length > 0) {
                return uri;
            }
        }

        if (bytes(URI_POSTFIX).length > 0) {
            return
                string(abi.encodePacked(super.tokenURI(tokenId), URI_POSTFIX));
        } else {
            return super.tokenURI(tokenId);
        }
    }

    function startTokenId() public view returns (uint256) {
        return _startTokenId();
    }

    // ----- Admin functions -----

    function toggleOpenSeaTransferFilter() public onlyOwner {
        isOpenSeaTransferFilterEnabled = !isOpenSeaTransferFilterEnabled;
    }

    function setBaseURI(string calldata uri) public onlyOwner {
        BASE_URI = uri;
    }

    // Contract-level metadata for Opensea
    function setContractURI(string calldata uri) public onlyOwner {
        CONTRACT_URI = uri;
    }

    function setPostfixURI(string memory postfix) public onlyOwner {
        URI_POSTFIX = postfix;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function reduceMaxSupply(uint256 _maxSupply)
        public
        whenSaleNotStarted
        onlyOwner
    {
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

    function extensionsLength() public view returns (uint256) {
        return extensions.length;
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
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive)
        public
        onlyOwner
    {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }

    // ---- Minting ----

    function _mintConsecutive(
        uint256 nTokens,
        address to,
        bytes32 extraData
    ) internal {
        require(
            _totalMinted() + nTokens + reserved <= maxSupply,
            "Not enough Tokens left."
        );

        uint256 nextTokenId = _nextTokenId();

        _safeMint(to, nTokens, "");

        if (extraData.length > 0) {
            for (uint256 i; i < nTokens; i++) {
                uint256 tokenId = nextTokenId + i;
                data[tokenId] = extraData;
            }
        }
    }

    // ---- Mint control ----

    modifier whenSaleStarted() {
        require(saleStarted(), "Sale not started");
        _;
    }

    modifier whenSaleNotStarted() {
        require(!saleStarted(), "Sale should not be started");
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
    function mint(uint256 nTokens)
        external
        payable
        nonReentrant
        whenSaleStarted
    {
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

        _mintConsecutive(nTokens, msg.sender, 0x0);
    }

    // Owner can claim free tokens
    function claim(uint256 nTokens, address to)
        external
        nonReentrant
        onlyOwner
    {
        require(nTokens <= reserved, "That would exceed the max reserved.");

        reserved = reserved - nTokens;

        _mintConsecutive(nTokens, to, 0x0);
    }

    // ---- Mint via extension

    function mintExternal(
        uint256 nTokens,
        address to,
        bytes32 extraData
    ) external payable onlyExtension nonReentrant {
        _mintConsecutive(nTokens, to, extraData);
    }

    // ---- Mint configuration

    function updateMaxPerMint(uint256 _maxPerMint)
        public
        onlyOwner
        nonReentrant
    {
        require(_maxPerMint <= MAX_PER_MINT_LIMIT, "Too many tokens per mint");
        maxPerMint = _maxPerMint;
    }

    // set to 0 to save gas, mintedBy is not used
    function updateMaxPerWallet(uint256 _maxPerWallet)
        public
        onlyOwner
        nonReentrant
    {
        maxPerWallet = _maxPerWallet;
    }

    // ---- Sale control ----

    function updateStartTimestamp(uint256 _startTimestamp) public onlyOwner {
        startTimestamp = _startTimestamp;
    }

    function startSale() public onlyOwner {
        startTimestamp = block.timestamp;
    }

    function stopSale() public onlyOwner {
        startTimestamp = SALE_STARTS_AT_INFINITY;
    }

    function saleStarted() public view returns (bool) {
        return block.timestamp >= startTimestamp;
    }

    // ---- Offchain Info ----

    // This should be set before sales open.
    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        PROVENANCE_HASH = provenanceHash;
    }

    function setRoyaltyFee(uint256 _royaltyFee) public onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    function setPayoutReceiver(address _receiver)
        public
        onlyOwner
        whenNotPayoutChangeLocked
    {
        payoutReceiver = payable(_receiver);
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
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

    modifier onlyDeveloper() {
        require(
            payable(msg.sender) == PLATFORM_TREASURY,
            "Caller is not developer"
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

    function forceWithdrawDeveloper() public virtual onlyDeveloper {
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

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startId,
        uint256 quantity
    ) internal override onlyAllowedOperator(from) {
        super._beforeTokenTransfers(from, to, startId, quantity);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IArtgene721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Override isApprovedForAll to allowlist user's OpenSea proxy accounts to enable gas-less listings.
     * Taken from CryptoCoven: https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        if (isOpenSeaProxyActive && operator == OPENSEA_CONDUIT) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}
