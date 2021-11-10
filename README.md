# nft-contracts

This is a collection of smart-contracts that help you to launch your own 10k-avatar collection like [CryptoPunks](https://www.larvalabs.com/cryptopunks), [Bored Ape Yacht Club](https://boredapeyachtclub.com/) or [Pudgy Penguins](https://www.pudgypenguins.io/).

Features include:
- ERC721 (AvatarNFT.sol)
    - Limited supply
    - Mint N tokens in one transaction
    - Generative art
    - Lazy Mint – buyes pays for mint
    - Manually start/stop sale
    - Reserve X tokens for team or community
    - Random token index shift on sale start
- ERC1155 (ERC1155Sale.sol)
    - Limited supply for each tokenId
    - Lazy Mint – buyer pays for mint
    - Admin can add new tokenId
    - On-chain metadata storage
    - Manual start/stop sale for each tokenId
- Tier-based Pricing (TierNFT.sol)
    - Set different prices for different tokenId
- Mint with Referral info (ReferralNFT.sol)
    - Save referral and accrue his rewards at each mint
- Experimental features
    - refund gas for minting
    - burn NFT to mint NFT
    - mint pass
    - on-chain metadata
    - 0% marketplace for your tokens (please help fix issues)

USE AT YOUR OWN RISK. Most of the features are in production already, however this doesn't guarantee any security. Unreleased and speculative code is located in `contracts/experiments` directory.

## How to use:

### Init

```bash
npm i
touch .mnemonic
nano .mnemonic # input deploy wallet

cp .env.local .env
nano .env # input your keys
```

### Development

When you change something, run:

```bash
truffle compile
```

Then, in another tab and leave running:

```bash
npx ganache-cli
```

Finally, to test your code:

```bash
truffle migrate
truffle test
```

### Deploy to production

By default, it deploys `TemplateNFT`. The deployment is specified in `2_deploy_nft.js`.

Edit the file `contracts/TemplateNFT.sol` to use your metadata, and run:

```bash
truffle migrate --network rinkeby -f 2 --to 2

truffle run verify TemplateNFT --network rinkeby
```

Most probably, you want to transfer contract ownership from your deployment keys to your Metamask account. You can use this piece of code:

```bash
truffle console --network rinkeby
```

And then:
```
nft = await TemplateNFT.at("0xDeployedAddress")
nft.transferOwnership("0xyourMetamaskAccount")
```

### Upload for Frontend Deploy

Instead of deploying from your local machine, you can compile and send it for deployment from  the Buildship web app.

```bash
truffle exec ./scripts/upload.mjs [contract name] --compile
```

It needs network selection to run, but it doesn't matter which you use. You can run with development network.

In the end, you get IPFS hash to the uploaded bytecode. Use in on https://app.buildship.dev/deploy?ipfs=QmExampleHash

### Bonus

How to interact with contracts from deployed truffle?

```bash
truffle console --network rinkeby
```

### Mainnet fork

We have a special test for `AmeegosMintPass`. It runs on testnet, but it's best to run on mainnet fork too.

Run ganache to fork from mainnet:

```bash
source .env
npx ganache-cli --fork https://mainnet.infura.io/v3/$INFURA_KEY\
                --unlock 0x44244acacd0b008004f308216f791f2ebe4c4c50
```

0x4424 is an address of original AmeegosNFT owner.

Then, run test suite for mainnet fork. It will automatically detect we're on forked version, and will not deploy new contract, instead attach to the old one.

```bash
truffle test test/mintpass_mainnet_fork.js
```



