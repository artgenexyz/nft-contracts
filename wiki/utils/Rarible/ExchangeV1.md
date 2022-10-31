# ExchangeV1









## Methods

### beneficiary

```solidity
function beneficiary() external view returns (address payable)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address payable | undefined |

### buyerFeeSigner

```solidity
function buyerFeeSigner() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### cancel

```solidity
function cancel(ExchangeDomainV1.OrderKey key) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| key | ExchangeDomainV1.OrderKey | undefined |

### erc20TransferProxy

```solidity
function erc20TransferProxy() external view returns (contract ERC20TransferProxy)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ERC20TransferProxy | undefined |

### exchange

```solidity
function exchange(ExchangeDomainV1.Order order, ExchangeDomainV1.Sig sig, uint256 buyerFee, ExchangeDomainV1.Sig buyerFeeSig, uint256 amount, address buyer) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| order | ExchangeDomainV1.Order | undefined |
| sig | ExchangeDomainV1.Sig | undefined |
| buyerFee | uint256 | undefined |
| buyerFeeSig | ExchangeDomainV1.Sig | undefined |
| amount | uint256 | undefined |
| buyer | address | undefined |

### ordersHolder

```solidity
function ordersHolder() external view returns (contract ExchangeOrdersHolderV1)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ExchangeOrdersHolderV1 | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### prepareBuyerFeeMessage

```solidity
function prepareBuyerFeeMessage(ExchangeDomainV1.Order order, uint256 fee) external pure returns (string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| order | ExchangeDomainV1.Order | undefined |
| fee | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### prepareMessage

```solidity
function prepareMessage(ExchangeDomainV1.Order order) external pure returns (string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| order | ExchangeDomainV1.Order | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### setBeneficiary

```solidity
function setBeneficiary(address payable newBeneficiary) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newBeneficiary | address payable | undefined |

### setBuyerFeeSigner

```solidity
function setBuyerFeeSigner(address newBuyerFeeSigner) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newBuyerFeeSigner | address | undefined |

### state

```solidity
function state() external view returns (contract ExchangeStateV1)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ExchangeStateV1 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### transferProxy

```solidity
function transferProxy() external view returns (contract TransferProxy)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract TransferProxy | undefined |

### transferProxyForDeprecated

```solidity
function transferProxyForDeprecated() external view returns (contract TransferProxyForDeprecated)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract TransferProxyForDeprecated | undefined |



## Events

### Buy

```solidity
event Buy(address indexed sellToken, uint256 indexed sellTokenId, uint256 sellValue, address owner, address buyToken, uint256 buyTokenId, uint256 buyValue, address buyer, uint256 amount, uint256 salt)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sellToken `indexed` | address | undefined |
| sellTokenId `indexed` | uint256 | undefined |
| sellValue  | uint256 | undefined |
| owner  | address | undefined |
| buyToken  | address | undefined |
| buyTokenId  | uint256 | undefined |
| buyValue  | uint256 | undefined |
| buyer  | address | undefined |
| amount  | uint256 | undefined |
| salt  | uint256 | undefined |

### Cancel

```solidity
event Cancel(address indexed sellToken, uint256 indexed sellTokenId, address owner, address buyToken, uint256 buyTokenId, uint256 salt)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sellToken `indexed` | address | undefined |
| sellTokenId `indexed` | uint256 | undefined |
| owner  | address | undefined |
| buyToken  | address | undefined |
| buyTokenId  | uint256 | undefined |
| salt  | uint256 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



