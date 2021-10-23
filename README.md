# nft-contracts

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

```
truffle migrate
truffle test
```

### Deploy

```bash
truffle migrate --network rinkeby
truffle run verify MoonNFT --network rinkeby
```

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



