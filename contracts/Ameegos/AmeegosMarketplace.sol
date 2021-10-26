// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
// import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
// import "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
// import "@uniswap/v3-core/contracts/libraries/FullMath.sol";


// import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

// interface IUniswapRouter is ISwapRouter {
//     function refundETH() external payable;
// }

//   IUniswapRouter public constant uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
//   IQuoter public constant quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

import "./Base64.sol";

/*
 Simple ERC1155 contract for initial sale. It represents in-game items, so each option corresponds to an game item, like: Skin, Weapon, Armor.
 
 The features:
 - admin can add new items to the marketplace (name, price, max supply)
 - admin can lower max supply of an item
 - admin can change price for each item
 - users can purchase item if minter didn't run out of supply and if saleStarted = true

 - admin can withdraw funds from sale, but 10% goes to the developer address "0x704C043CeB93bD6cBE570C6A2708c3E1C0310587"
 - tokens are burnable
 - admin can flipSaleStarted, switching between sale active or disabled (saleStarted is true/false)

 Items are stored in array of struct GameItem.

 In ERC1155, tokens have id, which represents itemId.
 */


/*
DONE:
- add claimItem onlyOwner whenSaleStarted = false
- remove URI not used
- can we edit imageUrl later? No
- double-check description
- buy limit per address ? No
- burn?
- create AGOS token for testing
- deploy buildship on rinkeby to make sure we receive money

*/

enum ItemType {
    Payable, // 0 = default
    Claimable // 1
}

/// @custom:security-contact aleks@buildship.dev
contract AmeegosMarketplace is ERC1155, Ownable {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    // Buildship storage
    address payable buildship = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    uint256 constant DEVELOPER_FEE = 1000; // of 10000;

    address public immutable AGOS;
    address public immutable SHIBA;

    address private SHIBA_ETH_LP = 0x5764a6F2212D502bC5970f9f129fFcd61e5D7563;

    constructor(address _AGOS, address _SHIBA)
        ERC1155("override")
    {
        AGOS = _AGOS;
        SHIBA = _SHIBA;
    }

    struct GameItem {
        uint256 price; // in ETH, or always AGOS
        uint256 maxSupply;
        uint256 mintedSupply;
        ItemType itemType;
        string name;
        string imageUrl;
    }

    mapping(uint256 => GameItem) public items;
    // keep track of total number of items
    uint256 public totalItems;

    mapping (uint256 => bool) private _saleStarted;

    modifier whenSaleStarted(uint256 itemId) {
        require(_saleStarted[itemId], "Sale not started");
        _;
    }

    // ----- View functions -----

    function saleStarted(uint256 itemId) public view returns(bool) {
        return _saleStarted[itemId];
    }

    // function contractURI() public pure returns (string memory output) {
    //     string memory json = Base64.encode(bytes(string(abi.encodePacked(
    //         '{',
    //         '"name": "Ameegos Marketplace",',
    //         '"description": "The Fight for Meegosa is an NFT community MMORPG that utilises blockchain technology to give the gamer true ownership of their in-game assets. Our vision is to become the leader in decentralised, play-to-earn, PVM & PVP gaming. Learn more in our discord: https://discord.gg/c7NRVvvVZt https://twitter.com/AmeegosOfficial https://ameegos.io/",',
    //         '"external_link": "https://ameegos.io"',
    //         '}'
    //     ))));

    //     output = string(abi.encodePacked('data:application/json;base64,', json));
    // }

    function uri(uint256 tokenId) public view override returns (string memory output) {
        // on-chain metadata inspired by Loot https://etherscan.io/address/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7#code

        GameItem memory item = items[tokenId];

        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{',
            '"name": "', item.name, '",',
            '"description": "The Fight for Meegosa is an NFT community MMORPG. Join the community and learn more in our Discord. https://discord.gg/c7NRVvvVZt https://twitter.com/AmeegosOfficial https://ameegos.io/",',
            '"image": "', item.imageUrl, '"',
            '}'
        ))));

        output = string(abi.encodePacked('data:application/json;base64,', json));

    }

    // ----- Internal functions -----

    // Buy item
    function _buyItem(uint256 itemId, uint256 amount)
        internal
        whenSaleStarted(itemId)
    {
        require(itemId < totalItems, "No itemId");

        GameItem storage item = items[itemId];

        require(item.mintedSupply + amount <= items[itemId].maxSupply, "Out of stock");

        // buy item
        item.mintedSupply += amount;
        _mint(msg.sender, itemId, amount, "");
    }

    // function _buyItemBatch(uint256[] calldata itemIds, uint256[] calldata amounts)
    //     internal
    // {
    //     require(itemIds.length == amounts.length, "Length mismatch");

    //     for (uint256 i = 0; i < itemIds.length; i++) {
    //         require(itemIds[i] < totalItems, "No itemId");
    //         require(_saleStarted[itemIds[i]], "Sale not started for some of IDs");
    //     }

    //     for (uint256 i = 0; i < itemIds.length; i++) {

    //         GameItem storage item = items[itemIds[i]];

    //         require(item.mintedSupply + amounts[i] <= item.maxSupply, "Out of stock");

    //         item.mintedSupply += amounts[i];
    //     }

    //     _mintBatch(msg.sender, itemIds, amounts, "");
    // }

    // -------- User functions

    // Pays in ETH, requires not Claimable
    function buyItem(uint256 itemId, uint256 amount)
        external
        payable
        whenSaleStarted(itemId)
    {
        require(itemId < totalItems, "No itemId");

        GameItem memory item = items[itemId];

        require(item.itemType == ItemType.Payable, "Item is not payable, cant buy with ETH");
        require(item.price * amount <= msg.value, "Not enough ETH");

        _buyItem(itemId, amount);  
    }

    // // Pays in token, requires Payable
    // function buyItemToken(uint256 itemId, uint256 amount, IERC20 token)
    //     external
    //     whenSaleStarted(itemId)
    // {
    //     require(itemId < totalItems, "No itemId");

    //     GameItem memory item = items[itemId];

    //     require(item.itemType == ItemType.Payable, "Item is not payable, cant buy with ERC20");

    //     uint256 total = getPriceToken(token, itemId, amount);

    //     IERC20(token).safeTransferFrom(msg.sender, address(this), total);

    //     _buyItem(itemId, amount);
    // }

    function claimItem(uint256 itemId, uint256 amount)
        external
        whenSaleStarted(itemId)
    {
        require(itemId < totalItems, "No itemId");

        GameItem memory item = items[itemId];

        require(item.itemType == ItemType.Claimable, "Item is not claimable");

        uint256 total = 1 * amount; // If price not set, fall back to 1 AGOS
        // uint256 total = item.price > 0 ? item.price * amount : 1 * amount; // If price not set, fall back to 1 AGOS

        // IERC20(AGOS).safeTransferFrom(msg.sender, address(this), total);

        ERC20Burnable(AGOS).burnFrom(msg.sender, total);

        _buyItem(itemId, amount);
    }

    // function getPriceToken(IERC20 token, uint256 itemId, uint256 amount) public view returns (uint256) {
    //     require(itemId < totalItems, "No itemId");

    //     GameItem memory item = items[itemId];

    //     require(item.itemType == ItemType.Claimable, "Item is claimable, cant buy with ERC20");

    //     if (address(token) == AGOS) {
    //         return item.price * amount;
    //     } else if (address(token) == SHIBA) {
    //         (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(SHIBA_ETH_LP).slot0();

    //         uint256 priceETH = items[itemId].price;

    //         return priceETH * sqrtPriceX96 * amount;
    //     } else {
    //         return items[itemId].price * amount;
    //     }

    // }

    // ----- Admin functions -----

    // reserveItem onlyOwner, allows admin to claim any amount of any token,
    function reserveItem(uint256 itemId, uint256 amount) public onlyOwner {
        // require(_saleStarted[itemId] == false, "Only claim when sale is not active");

        require(itemId < totalItems, "No itemId");

        GameItem storage item = items[itemId];

        require(item.mintedSupply + amount <= item.maxSupply, "Not enough minted supply");

        item.mintedSupply += amount;
        _mint(msg.sender, itemId, amount, "");
    }

    // function reserveItemBatch(uint256[] calldata itemIds, uint256[] calldata amounts) public onlyOwner {
    //     require(itemIds.length == amounts.length, "Length mismatch");

    //     for (uint256 i = 0; i < itemIds.length; i++) {
    //         // require(_saleStarted[itemIds[i]] == false, "ClaimItem only when sale is not active");
    //         require(itemIds[i] < totalItems, "No itemId");
    //     }

    //     for (uint256 i = 0; i < itemIds.length; i++) {
    //         GameItem storage item = items[itemIds[i]];

    //         require(item.mintedSupply + amounts[i] <= item.maxSupply, "Not enough minted supply");

    //         item.mintedSupply += amounts[i];
    //     }

    //     _mintBatch(msg.sender, itemIds, amounts, "");
    // }

    function flipSaleStarted(uint256 itemId) external onlyOwner {
        _saleStarted[itemId] = !_saleStarted[itemId];
    }

    function startSaleAll() external onlyOwner {
        for (uint256 itemId = 0; itemId < totalItems; itemId++) {
            _saleStarted[itemId] = true;
        }
    }

    // Add new item to the marketplace
    // @notice Dont forget to add tokenId metadata to backend
    function addItem(string memory name, string memory imageUrl, uint256 price, uint256 maxSupply, ItemType itemType, bool startSale) public onlyOwner {
        require(maxSupply > 0, "Invalid maxSupply");

        uint256 newItemId = totalItems;

        // create new item
        GameItem memory item = GameItem(price, maxSupply, 0, itemType, name, imageUrl);

        // add item to the array
        items[newItemId] = item;
        totalItems++;

        // should start sale right after adding?
        _saleStarted[newItemId] = startSale;

        emit ItemAdded(newItemId, name, imageUrl, price, maxSupply, itemType, startSale);
    }

    // Change price for item
    function changePrice(uint256 itemId, uint256 newPrice) public onlyOwner {
        // require(newPrice > 0);

        // change price
        // TODO: change for AGOS too
        items[itemId].price = newPrice;
    }

    // Withdraw sale money
    function withdraw() public onlyOwner {
        uint256 _balance = address(this).balance;

        uint256 baseAmount = _balance * (10000 - DEVELOPER_FEE) / 10000;
        uint256 feesAmount = _balance * (DEVELOPER_FEE) / 10000;

        require(payable(msg.sender).send(baseAmount));
        require(payable(buildship).send(feesAmount));
    }

    // function withdrawToken(address token) public onlyOwner {
    //     uint256 balance = IERC20(token).balanceOf(address(this));

    //     uint256 baseAmount = balance * (10000 - DEVELOPER_FEE) / 10000;
    //     uint256 feesAmount = balance * (DEVELOPER_FEE) / 10000;

    //     IERC20(token).safeTransferFrom(address(this), msg.sender, baseAmount);
    //     IERC20(token).safeTransferFrom(address(this), buildship, feesAmount);
    // }

    event ItemAdded(uint256 itemId, string name, string imageUrl, uint256 price, uint256 maxSupply, ItemType itemType, bool startSale);

}
