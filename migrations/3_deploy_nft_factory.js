const NFTFactory = artifacts.require("MetaverseNFTFactory");
const ArtNFTFactory = artifacts.require("ArtNFTFactory");

module.exports = async function (deployer, network, accounts) {

  if (!process.env.FACTORY_NOT_SKIP) return;

  await deployer.deploy(NFTFactory);
  await deployer.deploy(ArtNFTFactory);

  const factory = await NFTFactory.deployed();
  const artFactory = await ArtNFTFactory.deployed(); 
  const implementation = await factory.proxyImplementation();
  const artImplementation = await artFactory.proxyImplementation();

  console.log('   > implementation created at address:', implementation);
  console.log('   > implementation created at address:', artImplementation);
  console.log('')
  console.log('   -------------------------------------')
  console.log('   Verify:', `

      truffle run verify MetaverseNFTFactory ArtNFTFactory MetaverseNFT@${implementation} ArtNFT@${artImplementation} --network ${network}

  `)

  console.log('   -------------------------------------')

  // const [ nftCreated ] = factory.contract.getPastEvents('NFTCreated', { fromBlock: 0, toBlock: 'latest' });

  // console.log('nft created:', nftCreated?.returnValues?.deployedAddress);

};
