const NFTFactory = artifacts.require("MetaverseNFTFactory");

module.exports = async function (deployer) {

  if (!process.env.FACTORY_NOT_SKIP) return;

  await deployer.deploy(NFTFactory);

  const factory = await NFTFactory.deployed();

  const implementation = await factory.proxyImplementation();

  console.log('   > implementation created at address:', implementation);

  console.log('   -------------------------------------')
  console.log('   Verify:\n\t', `truffle run verify MetaverseNFTFactory MetaverseNFT@${implementation} --network rinkeby`, '\n')

  console.log('   -------------------------------------')

  // const [ nftCreated ] = factory.contract.getPastEvents('NFTCreated', { fromBlock: 0, toBlock: 'latest' });

  // console.log('nft created:', nftCreated?.returnValues?.deployedAddress);

};
