# NFT Contracts by Buildship

This is a collection of smart-contracts that help you to launch your own 10k-avatar collection like [CryptoPunks](https://www.larvalabs.com/cryptopunks), [Bored Ape Yacht Club](https://boredapeyachtclub.com/) or [Pudgy Penguins](https://www.pudgypenguins.io/).

Made by https://buildship.xyz. If you can't code, use our simple web-app to deploy!

USE AT YOUR OWN RISK. Most of the features are in production already, however this doesn't guarantee any security. Unreleased and speculative code is located in `contracts/experiments` directory.

Features include:

## MetaverseNFT.sol
- Limited supply
- Mint N tokens in one transaction
- Generative art
- Lazy Mint – buyers pays for mint
- Manually start/stop sale
- Reserve X tokens for team or community
- Deployed by Factory using Clones
- Supports `NFTExtension` to upgrade mint and tokenURI functions

## MetaverseBaseNFT.sol
- Same features as MetaverseNFT
- Import and inherit in your own projects

```solidity
contract MyPFPNFT is MetaverseBaseNFT {

    constructor() MetaverseBaseNFT(
        0.1 ether, // public mint price, you can change later
        10000, // total supply
        100, // reserved
        20, // max mint per transaction
        0, // royalty fee
        "ipfs://Qm/", // baseURI
        "Bored Ape Yacht Club", 
        "BAYC",
        false // should start at 1 or at 0?
    ) {}

}
```

## NFTExtension
- Can be added to main NFT using `addExtension`
- Support changing mint and tokenURI functions

## How to use:

### Init

```bash
npm i
touch .mnemonic
node scripts/generate_mnemonic.mjs
vim .mnemonic # input generated mnemonic

cp .env.example .env
vim .env # input your keys
```

### Development

When you change something, run:

```bash
npx hardhat compile
```

Then, to test your code:

```bash
npx hardhat test
```

### Deploy to production

You can deploy using Hardhat. Refer to Hardhat scripts and console guides for deployment.
https://hardhat.org/guides/deploying.html

However, we also support deploying with your Metamask:

### Upload to IPFS for Frontend Deploy

Instead of deploying from your local machine, you can compile and send it for deployment from  the Buildship web app.

```bash
hh upload contracts/Greeter.sol --args '"hello","bar"'
```

It needs network selection to run, but it doesn't matter which you use. You can run with development network.

In the end, you get IPFS hash to the uploaded bytecode. Use in on https://gate-rinkeby.buildship.xyz/deploy/bafkreid4l4ru7sngq6fcvpizljo7hpm6dmcwjory4kcrbpbkde2xih75au?args=[]



