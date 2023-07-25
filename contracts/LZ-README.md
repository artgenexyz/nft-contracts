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

## Chain ids
goerli: 10121,
zksync: 10165,

ethereum: 101,
era: 165,


<!-- export const lzEndpoints = {
  goerli: "0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23",
  ethereum: "0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675",
  "zksync-testnet": "0x093D2CF57f764f09C3c2Ac58a42A2601B8C79281",
  "zksync-era": "0x9b896c0e23220469C7AE69cb4BbAE391eAa4C8da",
}; -->



```sh
# testnet
# export NFT=0x898032245550EB4B24A982fdC5eef65734676f76
# export ZKSYNC=0x1908e2BF4a88F91E4eF0DC72f02b8Ea36BEa2319
# export L2Endpoint=0x093D2CF57f764f09C3c2Ac58a42A2601B8C79281
# export L1Endpoint=0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23
# mainnet
export NFT=0x47087b347F04E51F4d612FC1a446A8881aBE1AC4
export ZKSYNC=0x32400084c286cf3e17e7b677ea9583e60a000324
export L2Endpoint=0x9b896c0e23220469C7AE69cb4BbAE391eAa4C8da
export L1Endpoint=0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675

hh clean
hh compile

hh clean-zksync
hh compile --network zksync

hh deploy-zksync-contract L2NFTProxy --network zksyncEra --args "[\"$L2Endpoint\",\"$NFT\"]"

hh deploy-contract Gradients --network mainnet --args "[\"$L1Endpoint\"]"

export L2NFTProxy=0f9458E0fcF39047504609c1A5257D2060547646
export L1NFT=682D3E5FCDfC4Dd6933A7745F59f5ec065bBfdfA

# _path = abi.encodePacked(remoteAddress, localAddress)
hh call --network zksyncEra L2NFTProxy 0x$L2NFTProxy \
    setTrustedRemote \
    --args "[101,\"0x$L1NFT$L2NFTProxy\"]"

hh call --network mainnet Gradients 0x$L1NFT \
    setTrustedRemote \
    --args "[165,\"0x$L2NFTProxy$L1NFT\"]"

# setMinDstGas
hh call --network zksyncEra L2NFTProxy 0x$L2NFTProxy \
    setMinDstGas \
    --args '[101, 1, 80000]'

hh call --network mainnet Gradients 0x$L1NFT \
    setMinDstGas \
    --args '[165, 1, 80000]'


## examples and fixes

hh call --network mainnet Gradients 0x$L1NFT \
    forceResumeReceive \
    --args "[101,\"0x$L2NFTProxy$L1NFT\"]"

hh call --network zksyncEra Gradients 0x$L1NFT \
    setMinGasToTransferAndStore \
    --args "[150000]"

# output links to zksync explorer, goerli etherscan, lzscan
echo https://testnet.layerzeroscan.com/10165/address/0x$L2NFTProxy/message/10121/address/0x$L1NFT/nonce/1
echo https://goerli.etherscan.io/address/0x$L1NFT
echo https://goerli.explorer.zksync.io/address/0x$L2NFTProxy

```

Zero Address = 0x0000000000000000000000000000000000000000

AdapterParams (needs to be > minDstGas = 1_000_000)
0x000100000000000000000000000000000000000000000000000000000000000F4240

Gradients
0x898032245550EB4B24A982fdC5eef65734676f76

ONFTProxy L2NFTProxy
0x06Ee17562D5322CA79CaD500fE90420667a8CaD0

L1 NFT
0x18148F776De6a2f9999b987554dd861C62B5660b

lzscan example:
https://testnet.layerzeroscan.com/10165/address/0xc88ebd403ae17e377c5500d899f2a9bb3d85df2e/message/10121/address/0x2fa5c3bb6a3f1f999d74771827166a551f0f6d9f/nonce/1

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


