# OffchainAllowListExtension









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

### isWhitelisted

```solidity
function isWhitelisted(bytes signature, address receiver, uint256 amount, bytes32 data) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| signature | bytes | undefined |
| receiver | address | undefined |
| amount | uint256 | undefined |
| data | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### mint

```solidity
function mint(uint256 nTokens, uint256 maxAllowedAmount, bytes32 data, bytes signature) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |
| maxAllowedAmount | uint256 | undefined |
| data | bytes32 | undefined |
| signature | bytes | undefined |

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
function price() external view returns (uint256)
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

### signer

```solidity
function signer() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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



