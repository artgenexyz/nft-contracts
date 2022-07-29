import { ethers } from "hardhat";

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

const erc1155 = "0xde95471123ce8bd81ad8e7ba553e019da110b654";
const receiver = "0x704C043CeB93bD6cBE570C6A2708c3E1C0310587";

export async function main() {
    const accounts = await ethers.getSigners();

    const [deployer] = accounts;

    const wild = await ethers.getContractFactory("Wilderness");

    const wildContract = wild.attach(erc1155);

    console.log('wild contract', wildContract.address);
    console.log('receiver', receiver)

    // get all balances
    // const balances = await Promise.all(Array(88).fill(null).map((_, i) => i + 1).map(async (i) => {
    //     const balance = await wildContract.balanceOf(deployer.address, i);
    //     console.log('balance of', i, balance.toNumber());

    //     return balance.toNumber();
    // }))

    const tokenIdToBalance = { "1": 3, "11": 1, "12": 3, "31": 1, "35": 2, "39": 3, "45": 1, "46": 4, "47": 1, "76": 5, "88": 4 }

    console.log('balances', JSON.stringify(tokenIdToBalance));

    const ids = Object.keys(tokenIdToBalance);
    const amounts = Object.values(tokenIdToBalance);

    // get total balance
    // const totalBalance = balances.reduce((acc, val) => acc + val, 0);

    // console.log('total balance', totalBalance);

    // send batch transfer from

    console.log('safeBatchTransferFrom',
        deployer.address,
        receiver,
        // ids
        ids,
        // amounts
        amounts,
        []
    )

    const tx = await wildContract.safeBatchTransferFrom(
        deployer.address,
        receiver,
        // ids
        ids,
        // amounts
        amounts,
        []
    );


    console.log('tx', tx.hash);

    await tx.wait();

    console.log('tx success');

}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
