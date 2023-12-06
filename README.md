# NFT Contracts by Buildship

[![Hardhat Tests](https://github.com/buildship-dev/nft-contracts/actions/workflows/hardhat.yml/badge.svg)](https://github.com/buildship-dev/nft-contracts/actions/workflows/hardhat.yml)

> [Donate on Gitcoin](https://gitcoin.co/grants/5779/buildship) if you like this repo ❤️‍🔥

This is a collection of smart-contracts that help you to launch your own 10k-avatar collection like [CryptoPunks](https://www.larvalabs.com/cryptopunks), [Bored Ape Yacht Club](https://boredapeyachtclub.com/) or [Pudgy Penguins](https://www.pudgypenguins.io/).

Made by https://buildship.xyz. If you can't code, use our simple web-app to deploy!

USE AT YOUR OWN RISK. Most of the features are in production already, however this doesn't guarantee any security. Unreleased and speculative code is located in `contracts/experiments` directory.

Features include:

## ERC721CommunityImplementation.sol
- Limited supply
- Mint N tokens in one transaction
- Generative art
- Lazy Mint – buyers pays for mint
- Manually start/stop sale
- Reserve X tokens for team or community
- Deployed by Factory using Clones
- Supports `NFTExtension` to upgrade mint and tokenURI functions

## ERC721CommunityBase.sol
- Same features as ERC721CommunityImplementation
- Import and inherit in your own projects

```solidity
contract MyPFPNFT is ERC721CommunityBase {

    constructor() ERC721CommunityBase(
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

## ERC721CommunityImplementation_

A copy of ERC721CommunityImplementation without any mention of Buildship. It's used as a base interface for Buildship Fuelpass subscribers (https://buildship.xyz/fuelpass).

```bash
colordiff contracts/ERC721CommunityImplementation_.sol contracts/ERC721CommunityImplementation.sol
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

### ZkSync

1. Setup env variable ZKSYNC=true when you compile

```bash
ZKSYNC=true hh compile
```

2. Deploy contracts

```bash
hh deploy-zksync --network zksync|zksyncEra
```

#### Gas Costs?

```
    gasUsed     * maxFeePerGas  +   pubdata     * gasPerPubdata     * gasPriceL1
  (developer)     (zksync load)    (developer)      (operator)          (l1 load)
```

Also see `results.md` for more details.

### Checking different versions of ERC721CommunityImplementation:

```bash
colordiff contracts/ERC721CommunityBase.sol contracts/ERC721CommunityImplementation.sol --context=1
colordiff contracts/ERC721CommunityBase_ERC1155.sol contracts/ERC721CommunityBase.sol --context=1
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

### Thanks

Thanks to Gitbook.com for providing free access to their platform to host our docs! https://learn.buildship.xyz/

ERC721A for their mint-optimized ERC721 https://erc721a.org/

Our contributors

Buildship users who have given us their trust and used our code on mainnet, already processing >5M$ in total volume and >35,000 NFT minted! https://dune.xyz/caffeinum/buildship_xyz


