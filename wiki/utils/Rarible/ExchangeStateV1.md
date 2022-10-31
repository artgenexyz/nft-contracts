# ExchangeStateV1









## Methods

### addOperator

```solidity
function addOperator(address account) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

### completed

```solidity
function completed(bytes32) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getCompleted

```solidity
function getCompleted(ExchangeDomainV1.OrderKey key) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| key | ExchangeDomainV1.OrderKey | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getCompletedKey

```solidity
function getCompletedKey(ExchangeDomainV1.OrderKey key) external pure returns (bytes32)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| key | ExchangeDomainV1.OrderKey | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### isOperator

```solidity
function isOperator(address account) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### removeOperator

```solidity
function removeOperator(address account) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### setCompleted

```solidity
function setCompleted(ExchangeDomainV1.OrderKey key, uint256 newCompleted) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| key | ExchangeDomainV1.OrderKey | undefined |
| newCompleted | uint256 | undefined |

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

### OperatorAdded

```solidity
event OperatorAdded(address indexed account)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account `indexed` | address | undefined |

### OperatorRemoved

```solidity
event OperatorRemoved(address indexed account)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account `indexed` | address | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



