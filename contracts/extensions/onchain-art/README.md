## GunZip Onchain Art




## Artgene Script


Contract `ArtgeneScript` is a storage for artgene.js

How to generate it:

```bash
npx terser -m --ecma 8 scripts/artgene.js -o scripts/artgene.min.js
gzip -c scripts/artgene.min.js | xxd -p | tr -d '\n' | pbcopy
```

This copies the hex string in your clipboard. Paste it into:

```solidity
contract ArtgeneScript {
    ...
    bytes private constant _SCRIPT =
        hex'deadbeef'
}
```

`ArtgeneScript` is deployed once and most probably never updated. Other projects can connect to it and fetch its script directly.

Also see `compress.sh` for automated script doing that

## User Script

Contract `ScriptyOnchainArt` uses `scripty.sol` to fetch dependencies. This contract is an onchain code storage used per-project.

To generate hex version of your custom code, use same algorithm as for artgene.js:

```bash
gzip -c scripts/user-script.js | xxd -p | tr -d '\n' | pbcopy
```

Also see `scripts/onchain/gzip-hex.sh`




