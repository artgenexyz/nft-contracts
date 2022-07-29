import { ethers } from "hardhat";
import { assert } from "console";
import { xmur3, sfc32 } from "./predictable-random/lib";

import addresses from "../addresses.json";
import balances from "../balances.json";

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

const seed = "Marco Grassi Jessica Lancia Wilderness to Blockchain";

// same seed as in original collection
const hash = xmur3(seed);

// first hash is used to generate the seed
assert(hash() === 1744442382);

// Pad seed with Phi, Pi and E.
// https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
export const rand = sfc32(0x9E3779B9, 0x243F6A88, 0xB7E15162, hash());

// take first 8 values, convert to hex and join, should match:
// node scripts / predictable - random--seed "Marco Grassi Jessica Lancia Wilderness to Blockchain" --run--n = 8
// seed: Marco Grassi Jessica Lancia Wilderness to Blockchain, hash: 1744442382
// 06c4243bdf6691aa87120d255c53b717010bec098f20f02d1061f31878bd566
const str = Array(8).fill(null).map(i => rand().toString(16).slice(2)).join('')

// check that the same seed generates the same random numbers
assert(str === "06c4243bdf6691aa87120d255c53b717010bec098f20f02d1061f31878bd566");

export async function main() {
    const accounts = await ethers.getSigners();

    const [deployer] = accounts;

    const wild = await ethers.getContractFactory("Wilderness");

    const wildContract = wild.attach("0xde95471123ce8bd81ad8e7ba553e019da110b654");

    console.log('wild contract', wildContract.address);

    // console.log('balance of', 1, await wildContract.balanceOf(deployer.address, 1));
    // console.log('balance of', 2, await wildContract.balanceOf(deployer.address, 2));
    // console.log('balance of', 88, await wildContract.balanceOf(deployer.address, 88));

    // const balances = await Promise.all(Array(88).fill(null).map((_, i) => i + 1).map(async (i) => {
    //     return await wildContract.balanceOf(deployer.address, i);
    // }));

    // console.log('balances', JSON.stringify(balances.reduce((obj, val, index) => ({
    //     ...obj,
    //     [index + 1]: val.toNumber(),
    // }), {})));


    const mapOffsetToTokenId = (offset: number) => {
        // scan balances dictionary
        // take each balance one by one and subtract the offset, stop when offset fits into the balance

        for (const [tokenId, balance] of Object.entries(balances)) {
            if (balance >= offset) {
                return parseInt(tokenId);
            } else {
                offset -= balance;
            }
        }

        throw new Error('offset too big');
    }

    const totalBalance = Object.values(balances).reduce((acc, val) => acc + val, 0);

    console.log('total balance', totalBalance);

    const fisherYates = (array: any[]) => {
        let currentIndex = array.length;
        let temporaryValue;

        while (0 !== currentIndex) {
            // Pick a remaining element...
            const randomIndex = Math.floor(rand() * currentIndex);
            currentIndex -= 1;

            // And swap it with the current element.
            temporaryValue = array[currentIndex];
            array[currentIndex] = array[randomIndex];
            array[randomIndex] = temporaryValue;
        }

        return array;
    }

    // for each address, generate a random offset from 0 to totalBalance, convert offset to token id, and save to specific dictionary

    for (let i = 0; i < totalBalance; i++) {
        const offset = i;
        const tokenId = mapOffsetToTokenId(offset);
        console.log('offset', offset, 'tokenId', tokenId, 'balance', balances[String(tokenId) as keyof typeof balances]);
    }

    const randomOffsets = fisherYates(Array(totalBalance).fill(null).map((_, i) => i));

    console.log('randomOffsets', Array(totalBalance).fill(null).map((_, i) => i));
    console.log('randomOffsets', randomOffsets);

    const addressesToTokenIds: { [key: string]: number[] } = addresses.reduce((obj, json, index) => ({
        ...obj,
        [json.data.from]: [
            ...((!!obj && (obj as any)[json.data.from]) ? (obj as any)[json.data.from] : []),
            mapOffsetToTokenId(randomOffsets[index])
        ],
    }), {});

    console.log('addressesToTokenIds', addressesToTokenIds);

    // build transaction to send wild.transfer(address, tokenId)

    // emulate with .estimateGas()

    // send transaction

    let gasSpent = 0;
    let ethSpent = 0;

    // const deployerFork = "0xe5cc6f5bbb3eee408a1c022d235e6903656f2509";
    // await network.provider.request({ method: "hardhat_impersonateAccount", params: [deployerFork] })


    const skipUntil = "0x874fbe5c1ffad91d77422bd79895b2a06c2ab4bb";
    let shouldSkip = true;

    let nonce = await deployer.getTransactionCount();

    console.log('nonce', nonce);

    for (const [address, tokenId] of Object.entries(addressesToTokenIds)) {

        if (address === skipUntil) {
            shouldSkip = false;
            continue;
        } else if (shouldSkip) {
            continue;
        }

        if (tokenId.length == 1) {
            console.log('skipping', address);
            continue;
        }

        if (address === "0x5e6a1899bb32c968eaf3ad18fc1a2a5787ecf755") {
            console.log('skipping because already received', address);
            continue;
        }

        // const [ ...ids, skipped ] = tokenId;
        const ids = tokenId.slice(0, -1);
        const skipped = tokenId[tokenId.length - 1];

        console.log('skipped', skipped, 'for', address);

        console.log('transfer', address, ids);

        // console.log('balance of', tokenId, deployer.address, await wildContract.balanceOf(deployer.address, tokenId));
        //, maxFeePerGas: ethers.utils.parseUnits('15', 'gwei'), maxPriorityFeePerGas: ethers.utils.parseUnits('2', 'gwei') })

        ids.forEach(async id => {

            await delay(100);

            const tx = await wildContract.safeTransferFrom(deployer.address, address, id, 1, []);
            // .then(tx => {
            console.log(' === tx', tx.gasPrice, tx.hash);
            // , { gasPrice: ethers.utils.parseUnits('15', 'gwei') });

            tx.wait().then(r => {

                gasSpent += r.gasUsed.toNumber();
                ethSpent += r.gasUsed.mul(r.effectiveGasPrice).div(1e9.toString()).toNumber();

                console.log(' === tx mined', tx.hash, r.effectiveGasPrice, r.gasUsed);

            })
        })
        // });

    }

    console.log('==== Summary ====');
    console.log('gas spent', gasSpent);
    console.log('eth spent', ethSpent / 1e9);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
