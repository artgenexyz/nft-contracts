## Layerzero Draft

Deploy steps

- deploy ONFT to zksync
- deploy ONFT to goerli
- call setTrustedRemote on zksync and on goerli with addresses from that deployment
- call setMinGas on both networks


Plan

TODO


## send message to mainnet from l2

- deploy Gradients to zksync goerli
- mint 10 tokens
- deploy ONFTProxy to zksync goerli
- deploy ONFT to goerli l1
- call setTrustedRemote on zksync and on goerli with addresses from that deployment
- transfer and burn Gradient token to ONFTProxy
- 

## HH tools

```sh
hh deploy-zksync-contract --network zksync Gradients --args '["...","..."]'
hh call --network zksync Gradients 0x7eEc4b2207aa54dbdF547e6619204d1b756C5889 totalSupply
hh call --network zksync Gradients 0x7eEc4b2207aa54dbdF547e6619204d1b756C5889 transferOwnership --args '["0xnewowner"]'
```



## Guide

CONTRACT=Artgenes ARGS='["0x093D2CF57f764f09C3c2Ac58a42A2601B8C79281"]' hh deploy --network zksync
CONTRACT=Artgenes ARGS='["0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23"]' hh run deploy/lz/02_deploy_l1.ts --network goerli


REMOTE_CHAIN_ID=10121 hh run deploy/lz/03_set_trusted_remote.ts --network zksync
REMOTE_CHAIN_ID=10165 hh run deploy/lz/03_set_trusted_remote.ts --network goerli

REMOTE_CHAIN_ID=10121 hh run deploy/lz/04_set_min_gas.ts --network zksync
REMOTE_CHAIN_ID=10165 hh run deploy/lz/04_set_min_gas.ts --network goerli

## TODO

1. You can remove 01_DeployArtgene.s.sol, cause forge doesn't work on zksync, we only use hh scripts
2. Be careful with constants, need to rewrite deploy scripts to fetch constants and addersses from files


