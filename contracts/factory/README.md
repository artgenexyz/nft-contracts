# MetaverseNFTFactory

The architecture works as follows:

- MetaverseNFTFactory is a base contract that manages the creation of NFTs. It takes small gas fee (about 500k gas) to create a new NFT smart-contract.
- MetaverseNFT is an NFT sale contract. It can mint NFTs and allows other contracts to connect to it for minting. It includes public sale options by default.
- INFTExtension is an interface that is allowed to connect to MetaverseNFT and mint on their behalf
- MetaverseBaseNFT is a standalone contract that can be deployed without Factory. It has all the features from MetaverseNFT, but allows to be extended and deployed separately.

## How to connect extension to MetaverseNFT

1. Deploy extension contract that conforms to `INFTExtension` interface. Optionally, use `NFTExtension` as a base contract.
2. On that `MetaverseNFT`, call `addExtension(address _extension)` with the address of the extension.
3. Now you can startSale or use extension any other way to mint tokens from the `MetaverseNFT`.


## MetaverseNFTFactory

Pay a fee to create a new NFT smart-contract.

NFTFactory.createNFT is MUCH cheaper than deploying your own smart-contract.

Usual ERC721 deployment varies from 3m to 5m gas.

NFTFactory.createNFT eats about 300k gas, 10-20x cheaper.


## MetaverseNFT

This is a clone-able version of `contracts/AvatarNFT.sol`. It's a fixed-supply ERC721 minter. You can set price and other misc params for the public sale.

It doesn't use ERC721Enumerable, saving 30-40% of gas on mint or transfer.

Note: While it says `ERC721Upgradeable`, it's not upgradeable. We use this version of OpenZeppelin contracts, because we need to be able to `Clone` the contract.

Features:
- low gas on mint
- gasless Opensea listing (no need to call approve)
- includes public sale options
- can be extended to include other features


## MetaverseBaseNFT

Sometimes you need to override functionality. We published a `MetaverseBaseNFT` that can be used as a base for your own NFT smart-contract.

It's a copy of `MetaverseNFT`, but uses non-upgradeable versions of ERC721 and Ownable.

## INFTExtension

This one is a cherry on top of this architecture! It's a contract that can be connected to MetaverseNFT and mint on their behalf.

The main idea here is that `INFTExtension` is a stateless contract. The state should be stored in the `MetaverseNFT` contract.

This is meant to reduce deployment cost as much as possible. Extensions are meant to be deployed once and be available to use for every `MetaverseNFT` instance who wants to connect them.

Examples of state stored in the original contract would be:
- Tier info
- Sale price
- LastTokenId counter

However, sometimes you might need additional data in the extension, say, on-chain art. Then you would store this data in extension contract, but mapped by original NFT collection address.

Example:

```solidity
interface INFT is IERC721 {
    function getArt(address _collectionAddress) public view returns (bytes32);
}

contract Extension is INFTExtension {
    mapping (INFT => uint256) public ;
}
```

## (DRAFT) Research extension architecture

Basically there are three options to connect extension to MetaverseNFT.

NFTSale <=> ExtensionA
        <=> ExtensionB


1. Send token data to MetaverseNFT directly. Store extension data in MetaverseNFT.

```solidity
function mint(uint nTokens, bytes32[] data) {

    for (uint i; i < nTokens; i++) {
        tokenId = _tokenIdCounter + i;
        _tokenData[tokenId] = data[i];
    }

    _tokenIdCounter += nTokens;
}
```

+ no need to keep track in Extension, which tokenIds were minted
- can't control which tokenIds are being issued, only issued sequentially


2. MetaverseNFT accepts tokenIds data from outside and doesn't store lastTokenId

```solidity
function mint(uint[] tokenIds) {
    for (uint i; i < tokenIds.length; i++) {
        _safeMint(tokenIds[i]);
    }
}
```

+ control over tokenIds
+ can issue different sequences of tokenId, e.g. 0-100 separate from 1000-1100
- extension needs to store tokenIdCounter for each collection

3. MetaverseNFT accepts tokenIds data from outside, but also stores lastTokenId as a public value

```solidity
function totalSupply () {
    return _tokenIdCounter;
}

function mint(uint[] tokenIds) {
    for (uint i; i < tokenIds.length; i++) {
        _safeMint(tokenIds[i]);
    }
}
```



Usecases:

1. Sale 10k NFT avatars. Sell tokenIds sequentially, fixed price. Also allocate X tokens to owner (claimReserved)
2. Sell 5-10 NFT on your website. Can be minted by owner, or bought at fixed price, different for each token. Can mint new tokens in the collection.
3. Tiered 10k sale. Different amounts of different tokens, some can be minted by owner, others are sold publicly at the same price inside tier. 0-99: 1 ETH, 100-9999: 0.1 ETH, 1000-9999: 0.05 ETH;
4. LazyMint – different price for different tokenIds, but signed by owner, not on-chain before minting.
5. On-chain art. Replace URI with base64-encoded json and image.
6. ERC1155 Factory?


