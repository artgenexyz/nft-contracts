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

