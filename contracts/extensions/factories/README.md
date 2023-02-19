## NFT Extension Factories

update this README according to this block:
- factories deploy minting extensions
- `base` folder has extensions building blocks, you inherit them
- tell about Allowlist and LimitedSupplyExtension
- how to check extensions match their non-upgradeable versions using `colordiff`

## How it works

Factory is a contract that deploys extensions. It has two functions:

- `createExtension` deploys an extension and returns its address
- `createExtensionAndCall` deploys an extension and calls a function on it

Both functions have the same signature:

```solidity
function createExtensionAndCall(
    address _implementation,
    bytes memory _data
) public returns (address extension);
```

`_implementation` is the address of the extension implementation. `_data` is the data that is passed to the extension's constructor. It contains the parameters of the extension.

## Extensions

### AllowlistExtension

This extension allows to set an allowlist of addresses that can mint NFTs. It also allows to set a maximum number of NFTs that can be minted.

### LimitedSupplyExtension

This extension allows to set a maximum number of NFTs that can be minted.

## Base Extensions

LimitedSupply, SaleControl

### LimitedSupply

This extension allows to set a maximum number of NFTs that can be minted.

### SaleControl

This extension allows to start and stop sale for NFTs.


## How to move from non-upgradeable to upgradeable extensions

Extensions are not really upgradeable, it follows OpenZeppelin terminology. What this means it that they're ready to be used as proxies.

To move from non-upgradeable to upgradeable extensions, you need to:
- deploy a factory
- deploy an implementation
- deploy an extension using the factory and the implementation

### Example

Let's say you have a non-upgradeable extension that looks like this:

```solidity
contract MintOnlyExtension is NFTExtension {
    address public minter;

    constructor(address _minter) {
        minter = _minter;
    }

    function mint(address _to, uint256 _tokenId) external {
        require(msg.sender == minter, "MintOnlyExtension: not a minter");
        _mint(_to, _tokenId);
    }
}
```

To move to upgradeable extensions, you need to:

- deploy a factory

```solidity

contract MintOnlyExtensionFactory is NFTExtensionFactory {
    function createExtension(
        address nft,
        // ... other parameters
    ) public override returns (address extension) {
        extension = Clones.clone(_implementation);
        extension.initialize(/* ... */);
    }
}
```

- create upgradeable version of extension

```solidity
contract MintOnlyExtension is NFTExtension {
    address public minter;

    constructor() initializer {}

    function initialize(address _minter) external initializer {
        minter = _minter;
    }

    function mint(address _to, uint256 _tokenId) external {
        require(msg.sender == minter, "MintOnlyExtension: not a minter");
        _mint(_to, _tokenId);
    }
}
```

- check that the upgradeable version is the same as the non-upgradeable one

```bash
colordiff contracts/extensions/LimitedSupplyMintingExtension.sol contracts/extensions/factories/LimitedSupplyExtension.sol --context=1 | less
```

- deploy the upgradeable version in the factory constructor

```solidity
constructor() {
    _implementation = address(new MintOnlyExtension());
}
```
