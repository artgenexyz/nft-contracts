# MintBatchExtension









## Methods

### mintToOwner

```solidity
function mintToOwner(contract IERC721Community nft, uint256 nTokens) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nft | contract IERC721Community | undefined |
| nTokens | uint256 | undefined |

### multimintMany

```solidity
function multimintMany(contract IERC721Community nft, address[] recipients, uint256[] amounts) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nft | contract IERC721Community | undefined |
| recipients | address[] | undefined |
| amounts | uint256[] | undefined |

### multimintOne

```solidity
function multimintOne(contract IERC721Community nft, address[] recipients) external nonpayable
```



*Mint tokens to a list of recipients*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nft | contract IERC721Community | The NFT contract |
| recipients | address[] | The list of recipients, each getting exactly one token |

### multisend

```solidity
function multisend(contract IERC721Community nft, uint256[] ids, address[] recipients) external nonpayable
```



*Send a batch of tokens to a list of recipientsThe sender must have approved this contract to transfer the tokensUse `multisendBatch` for ERC721A-optimized transfer*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nft | contract IERC721Community | The NFT contract |
| ids | uint256[] | Token IDs to send |
| recipients | address[] | The list of recipients |

### multisendBatch

```solidity
function multisendBatch(contract IERC721Community nft, uint256 startTokenId, address[] recipients) external nonpayable
```



*Sequentially sends tokens to a list of recipients, starting from `startTokenId`The sender must have approved this contract to transfer the tokensOptimized for ERC721A: when you transfer tokenIds sequentially, the gas cost is lower*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nft | contract IERC721Community | The NFT contract |
| startTokenId | uint256 | The first token ID to send |
| recipients | address[] | The list of recipients |




