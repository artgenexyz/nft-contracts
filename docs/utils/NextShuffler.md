# NextShuffler





Returns the next value in a shuffled list [0,n), amortising the shuffle across all calls to _next(). Can be used for randomly allocating a set of tokens but the caveats in `dev` docs MUST be noted.

*Although the final shuffle is uniformly random, it is entirely deterministic if the seed to the PRNG.Source is known. This MUST NOT be used for applications that require secure (i.e. can&#39;t be manipulated) allocation unless parties who stand to gain from malicious use have no control over nor knowledge of the seed at the time that their transaction results in a call to _next().*

## Methods

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



