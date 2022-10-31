# ERC20SaleExtension









## Methods

### changeCurrency

```solidity
function changeCurrency(address _newCurrency, uint256 _newPrice) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _newCurrency | address | undefined |
| _newPrice | uint256 | undefined |

### currency

```solidity
function currency() external view returns (contract IERC20)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IERC20 | undefined |

### maxPerMint

```solidity
function maxPerMint() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### mint

```solidity
function mint(uint256 nTokens) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |

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

### currencyChanged

```solidity
event currencyChanged(address indexed newCurrency, uint256 newPrice)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newCurrency `indexed` | address | undefined |
| newPrice  | uint256 | undefined |



