# DynamicPricePresaleListExtension









## Methods

### __SALE_NEVER_STARTS

```solidity
function __SALE_NEVER_STARTS() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### claimedByAddress

```solidity
function claimedByAddress(address) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### extensionSupply

```solidity
function extensionSupply() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### isWhitelisted

```solidity
function isWhitelisted(bytes32 root, address receiver, bytes32[] proof) external pure returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| root | bytes32 | undefined |
| receiver | address | undefined |
| proof | bytes32[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### maxPerAddress

```solidity
function maxPerAddress() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### mint

```solidity
function mint(uint256 nTokens, bytes32[] proof) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |
| proof | bytes32[] | undefined |

### nft

```solidity
function nft() external view returns (contract IERC721Community)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IERC721Community | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### price

```solidity
function price(uint256 nTokens) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### pricePerOne

```solidity
function pricePerOne() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### saleStarted

```solidity
function saleStarted() external view returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### startSale

```solidity
function startSale() external nonpayable
```






### startTimestamp

```solidity
function startTimestamp() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### stopSale

```solidity
function stopSale() external nonpayable
```






### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### updateMaxPerAddress

```solidity
function updateMaxPerAddress(uint256 _maxPerAddress) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _maxPerAddress | uint256 | undefined |

### updatePrice

```solidity
function updatePrice(uint256 _price) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _price | uint256 | undefined |

### updateStartTimestamp

```solidity
function updateStartTimestamp(uint256 _startTimestamp) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _startTimestamp | uint256 | undefined |

### updateWhitelistRoot

```solidity
function updateWhitelistRoot(bytes32 _whitelistRoot) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _whitelistRoot | bytes32 | undefined |

### whitelistRoot

```solidity
function whitelistRoot() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |



## Events

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



