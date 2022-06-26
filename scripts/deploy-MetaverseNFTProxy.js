const hre = require("hardhat");
const fs = require("fs");

const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function main() {
  const [ admin ] = await hre.ethers.getSigners();

  const MetaverseNFTFactory = await hre.ethers.getContractFactory("MetaverseNFTFactory");
  const MetaverseNFT = await hre.ethers.getContractFactory("MetaverseNFT");

  // const metaverseNFTFactory = await MetaverseNFTFactory.deploy(
  //   "0x0000000000000000000000000000000000000000"
  // );

  // await metaverseNFTFactory.deployed();

  // // wait 3 seconds until propagates
  // // console.log("Waiting 3 seconds...");
  // // await new Promise(resolve => setTimeout(resolve, 3000));

  // // await hre.run("verify", {
  // //   // contractName: "MetaverseNFTFactory111",
  // //   contract: "contracts/MetaverseNFTFactory.sol:MetaverseNFTFactory",
  // //   address: metaverseNFTFactory.address,
  // //   constructorArgs: "./scripts/params.js",
  // //   network: "rinkeby",
  // // });

  // console.log("MetaverseNFTFactory deployed to:", metaverseNFTFactory.address);

  // // Show the contract info.
  // // const contractAddress = metaverseNFTFactory.address;
  // // console.log(`${nftFactoryArtifact.contractName} was deployed to ${contractAddress}`);

  // // Call the deployed contract.
  // const args = [
  //   hre.ethers.utils.parseEther("0.0001"), // 0.0001 ETH
  //   10000,
  //   1, // reserved
  //   20,
  //   0, // royalty fee
  //   "factory-test-buy/",
  //   "Test",
  //   "NFT",
  //   admin.address,
  //   false,
  //   4,
  // ]

  // console.log(`Call deployed contract createNFT`, args)
  // const tx = await metaverseNFTFactory.createNFTWithoutAccessPass(...args, { gasLimit: 1_000_000 });

  // // Wait until the transaction is mined.
  // console.log(`Waiting for transaction to be mined...`, tx.hash, `/tx/${tx.hash}`);
  // const receipt = await tx.wait();

  // console.log('receipt', receipt.transactionHash);

  // // take last event from the receipt
  // const { deployedAddress } = receipt.events.pop().args;

  // const nftImplementation = await metaverseNFTFactory.proxyImplementation();

  // console.log(`NFT address: ${deployedAddress}`);
  // console.log(`NFT Implementation address: ${nftImplementation}`);

  // We get the contract to deploy
  const MetaverseNFTProxy = await hre.ethers.getContractFactory("MetaverseNFTProxy");

  // generate random bytes32
  const salt = hre.ethers.utils.randomBytes(32);

  const _args = [

    `0x${Buffer.from(salt).toString("hex")}`,

    "Test",
    "NFT",
    10000,
    1, // reserved

    "10000000000000000", // 0.01 ETH
    20,
    0, // royalty fee
    0,

    "proxy-test-buy/",

  ]

  const args = [
    {
      // salt: `0x${Buffer.from(salt).toString("hex")}`,
      name: "Test",
      symbol: "NFT",
      maxSupply: 10000,
      nReserved: 1,

      startPrice: "10000000000000000", // 0.01 ETH
      maxTokensPerMint: 20,
      royaltyFee: 20,

      miscParams: 0,
      uri: "proxy-test-buy/",
    }
  ]

  const metaverseNFT = await MetaverseNFTProxy.deploy(
    args[0],
    { gasLimit: 2_000_000 },
  );

  await metaverseNFT.deployed();

  console.log("MetaverseNFTProxy deployed to:", metaverseNFT.address);

  // write file to scripts/params.js

  fs.writeFileSync(
    "./scripts/params.js",
    `module.exports = ${JSON.stringify(args)}`,
    "utf8"
  );

  // print that we are waiting
  console.log("Waiting 3 seconds...");
  await delay(10000);

  // send verification request
  console.log("Verifying...", JSON.stringify(args));

  // verify contract
  await hre.run("verify", {
    contract: "contracts/MetaverseNFTProxy.sol:MetaverseNFTProxy",
    address: metaverseNFT.address,
    constructorArgs: "./scripts/params.js",
    network: "rinkeby",
  });

  const nft = MetaverseNFT.attach(metaverseNFT.address);

  // Call the deployed contract.
  const tx2 = await metaverseNFT.initialize(
    // "10000000000000000", // 0.01 ETH
    // 20,
    // 0, // royalty fee
    admin,
    0,
    // "proxy-test-buy/",
    false,
  );

  // Wait until the transaction is mined.
  console.log(`Waiting for transaction to be mined...`, tx2.hash, `/tx/${tx2.hash}`);
  const receipt2 = await tx2.wait();

  console.log('receipt', receipt2.transactionHash);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
