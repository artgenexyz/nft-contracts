const NFTFactory = artifacts.require("NFTFactory");

module.exports = async function (deployer) {

  await deployer.deploy(NFTFactory);

  // const factory = await NFTFactory.deployed();

  // const implementation = await factory.proxyImplementation();

  // console.log('Implementation created at address', implementation)

  // const [ nftCreated ] = factory.contract.getPastEvents('NFTCreated', { fromBlock: 0, toBlock: 'latest' });

  // console.log('nft created:', nftCreated?.returnValues?.deployedAddress);

};
