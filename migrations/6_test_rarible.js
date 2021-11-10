const ExchangeV1 = artifacts.require('ExchangeV1');
const TransferProxy = artifacts.require('TransferProxy');
const TransferProxyForDeprecated = artifacts.require('TransferProxyForDeprecated');
const ERC20TransferProxy = artifacts.require('ERC20TransferProxy');
const ExchangeStateV1 = artifacts.require('ExchangeStateV1');
const ExchangeOrdersHolderV1 = artifacts.require('ExchangeOrdersHolderV1');


module.exports = async function (deployer, network, accounts) {

    // Skip deployment
    return;

    // deploy TransferProxy, TransferProxyForDeprecated, ERC20TransferProxy, ExchangeStateV1, ExchangeOrdersHolderV1
    await deployer.deploy(TransferProxy);
    await deployer.deploy(TransferProxyForDeprecated);
    await deployer.deploy(ERC20TransferProxy);
    await deployer.deploy(ExchangeStateV1);
    await deployer.deploy(ExchangeOrdersHolderV1);

    // get addresses of deployed contracts
    const transferProxy = await TransferProxy.deployed();
    const transferProxyForDeprecated = await TransferProxyForDeprecated.deployed();
    const erc20TransferProxy = await ERC20TransferProxy.deployed();
    const exchangeState = await ExchangeStateV1.deployed();
    const exchangeOrdersHolder = await ExchangeOrdersHolderV1.deployed();

    const beneficiary = accounts[0];
    const buyerFeeSigner = accounts[0];

    // deploy ExchangeV1
    await deployer.deploy(
        ExchangeV1,
        transferProxy.address, transferProxyForDeprecated.address, erc20TransferProxy.address, exchangeState.address, exchangeOrdersHolder.address,
        beneficiary, buyerFeeSigner,
    );

};
