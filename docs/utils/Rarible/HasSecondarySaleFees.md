# HasSecondarySaleFees









## Methods

### getFeeBps

```solidity
function getFeeBps(uint256 id) external view returns (uint256[])
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256[] | undefined |

### getFeeRecipients

```solidity
function getFeeRecipients(uint256 id) external view returns (address payable[])
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address payable[] | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |



## Events

### SecondarySaleFees

```solidity
event SecondarySaleFees(uint256 tokenId, address[] recipients, uint256[] bps)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId  | uint256 | undefined |
| recipients  | address[] | undefined |
| bps  | uint256[] | undefined |



