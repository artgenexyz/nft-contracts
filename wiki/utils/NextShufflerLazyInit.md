# NextShufflerLazyInit









## Methods

### isNumToShuffleSet

```solidity
function isNumToShuffleSet() external view returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### numToShuffle

```solidity
function numToShuffle() external view returns (uint256)
```

Total number of elements to shuffle.THIS LINE IS DIFFERENT, ORIGINALLY THIS VALUE IS IMMUTABLE




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |



## Events

### ShuffledWith

```solidity
event ShuffledWith(uint256 current, uint256 with)
```

Emited on each call to _next() to allow for thorough testing.



#### Parameters

| Name | Type | Description |
|---|---|---|
| current  | uint256 | undefined |
| with  | uint256 | undefined |



