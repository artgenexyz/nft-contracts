import fs from "fs";
import { generateMnemonic } from "bip39";
import { utils, Wallet } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

const zkscan_url = 'https://zksync2-testnet.zkscan.io'

const mnemonic = (() => {
    try {
        return fs.readFileSync(".mnemonic").toString().trim();
    } catch (err) {
        return generateMnemonic()
    }
})();

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {

    const admin = hre.ethers.Wallet.fromMnemonic(mnemonic);

    // Initialize the wallet.
    const wallet = new Wallet(admin.privateKey);

    // Create deployer object and load the artifact of the contract we want to deploy.
    const deployer = new Deployer(hre, wallet);
    const nftFactoryArtifact = await deployer.loadArtifact("MetaverseNFTFactory");
    const nftProxy = await deployer.loadArtifact("MetaverseNFTProxy");

    // check balance of admin
    const balance = await deployer.ethWallet.getBalance();
    console.log(`Admin Goerli balance: ${hre.ethers.utils.formatEther(balance)}`);

    // Deposit some funds to L2 in order to be able to perform L2 transactions.
    console.log('Deposit funds to L2...')
    console.log('Current L2 balance', await deployer.zkWallet.getBalance());

    if ((await deployer.zkWallet.getBalance()).eq(0)) {
        const depositAmount = hre.ethers.utils.parseEther("0.001");
        const depositHandle = await deployer.zkWallet.deposit({
            to: deployer.zkWallet.address,
            token: utils.ETH_ADDRESS,
            amount: depositAmount,
        });

        // Wait until the deposit is processed on zkSync
        console.log('Waiting for deposit to be processed...', depositHandle.hash);
        await depositHandle.wait();
    } else {
        console.log('L2 balance is not zero, skipping deposit...');
    }

    // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
    console.log('Deploying MetaverseNFTFactory...');
    const nftFactory = await deployer.deploy(nftFactoryArtifact, ["0x0000000000000000000000000000000000000000"]);

    // Show the contract info.
    const contractAddress = nftFactory.address;
    console.log(`${nftFactoryArtifact.contractName} was deployed to ${contractAddress}`);

    // Call the deployed contract.
    const args = [
        hre.ethers.utils.parseEther("0.0001"), // 0.0001 ETH
        10000,
        1, // reserved
        20,
        0, // royalty fee
        "factory-test-buy/",
        "Test",
        "NFT",
        admin.address,
        false,
        4,
    ]

    console.log(`Call deployed contract createNFT`, args)
    const tx = await nftFactory.createNFTWithoutAccessPass(...args, { gasLimit: 1_000_000 });

    // Wait until the transaction is mined.
    console.log(`Waiting for transaction to be mined...`, tx.hash, `${zkscan_url}/tx/${tx.hash}`);
    const receipt = await tx.wait();

    console.log('receipt', receipt);
    console.log('gasUsed', receipt.gasUsed);

    const { deployedAddress } = receipt.events.pop().args;

    console.log(`NFT address: ${deployedAddress}`);


}
