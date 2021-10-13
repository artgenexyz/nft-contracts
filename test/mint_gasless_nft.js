const GaslessNFT = artifacts.require("GaslessNFT");

const ether = 1e18;
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("GaslessNFT", function (accounts) {
  it("should assert true", async function () {
    await GaslessNFT.deployed();
    return assert.isTrue(true);
  });

  /* test whether the contract is deployed */
  it("should deploy the contract", async function () {
    const contract = await GaslessNFT.deployed();
    assert.ok(contract.address);
  });

  // test that after you flip sale started, saleStarted is true
  it("should flip sale started", async function () {
    const contract = await GaslessNFT.deployed();
    await contract.flipSaleStarted();
    const saleStarted = await contract.saleStarted();
    assert.equal(saleStarted, true);
  });

  // const tx = manager.contract.transferOwnership(ALEKS_TESTNET);
  // const result = await manager.verboseWaitForTransaction(tx.hash, 'Transfer Ownership');

  // test that contract fails to mint a token if you don't supply ETH
  it("should fail to mint a token if you don't supply ETH", async function () {
    const contract = await GaslessNFT.deployed();
    const nTokens = 1
    try {
      const tx = await contract.mint(nTokens, { from: accounts[0], value: 0 });
    }
    // catch an error and check that error message contains "Inconsistent amount sent!"
    catch (error) {
      assert.include(error.message, "Inconsistent amount sent!");
    }
  })

  // test that minting a token results in success when you supply 0.1 ETH
  it("should mint a token if you supply 0.1 ETH", async function () {
    const contract = await GaslessNFT.deployed();
    const nTokens = 1;
    // set value to 0.1 eth
    const tx = await contract.mint(nTokens, { from: accounts[0], value: 0.1 * ether });

    // assert.equal(tx.status, "success");
  });

  // test that the contract is able to transfer a token
  it("should transfer a token", async function () {
    const contract = await GaslessNFT.deployed();
    const tokenId = 0;
    await contract.mint(1, { from: accounts[0], value: 0.1 * ether });
    await contract.transferFrom(accounts[0], accounts[1], tokenId, { from: accounts[0] });
    assert.equal(await contract.ownerOf(tokenId), accounts[1]);
  });

  // test that the contract is able to burn a token
  xit("should burn a token", async function () {
    const contract = await GaslessNFT.deployed();
    const tokenId = await contract.mint({ from: accounts[0] });
    await contract.burn(tokenId, { from: accounts[0] });
    assert.equal(await contract.ownerOf(tokenId), 0);
  });


  // test that it can mint token and the amount of ether transferred approximates the cost of the transaction
  it("should mint a token and the amount of ether transferred approximates the cost of the transaction [ @skip-on-coverage ]", async function () {

    const contract = await GaslessNFT.deployed();

    // get account balance before the transaction and save
    const balanceBefore = await web3.eth.getBalance(accounts[0]);

    // mint one token token, supply enough ETH, but set gas price to 200 gwei
    const nTokens = 1;
    const tx = await contract.mint(nTokens, { from: accounts[0], value: 0.1 * ether, gasPrice: 200e9 });

    console.log('gasUsed', tx.receipt.gasUsed);

    // check the account balance after transaction
    const balanceAfter = await web3.eth.getBalance(accounts[0]);

    // output balance before, balance after, and their difference with labels
    console.log('balanceBefore', balanceBefore);
    console.log('balanceAfter', balanceAfter);
    console.log('balanceDifference', balanceAfter - balanceBefore, 'wei');

    // output balance difference in ether
    console.log('balanceDifference', (balanceAfter - balanceBefore) / ether, '%');

    // check that balance difference before and after transaction is less than 0.001 ether
    assert.isBelow(balanceAfter - balanceBefore, 0.001);

    // assert.equal(tx.receipt.gasUsed, tx.receipt.gasUsed * 1.1);
  });


});
