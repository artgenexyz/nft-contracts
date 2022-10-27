# NFT









## Methods

### DEVELOPER

```solidity
function DEVELOPER() external pure returns (string _url)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _url | string | undefined |

### DEVELOPER_ADDRESS

```solidity
function DEVELOPER_ADDRESS() external pure returns (address payable _dev)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _dev | address payable | undefined |

### addExtension

```solidity
function addExtension(address extension) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extension | address | undefined |

### data

```solidity
function data(uint256 tokenId) external view returns (bytes32)
```

Extra information stored for each tokenId. Optional, provided on mint



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### isExtensionAdded

```solidity
function isExtensionAdded(address extension) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extension | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### maxSupply

```solidity
function maxSupply() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### mintExternal

```solidity
function mintExternal(uint256 amount, address to, bytes32 data) external payable
```

Mint from NFTExtension contract. Optionally provide data parameter.



#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | undefined |
| to | address | undefined |
| data | bytes32 | undefined |

### revokeExtension

```solidity
function revokeExtension(address extension) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extension | address | undefined |

### royaltyInfo

```solidity
function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount)
```

Recommended royalty for tokenId sale.



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| salePrice | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |
| royaltyAmount | uint256 | undefined |

### saleStarted

```solidity
function saleStarted() external view returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### setRoyaltyFee

```solidity
function setRoyaltyFee(uint256 fee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee | uint256 | undefined |

### setRoyaltyReceiver

```solidity
function setRoyaltyReceiver(address receiver) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### withdraw

```solidity
function withdraw() external nonpayable
```









