const MintPass = artifacts.require("MintPass");

const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert } = require("chai");

contract("Mint Pass", function (accounts) {
  const [owner, user1, user2, user3, user4] = accounts;

  let nft, pass;

  it("should deploy Mint Pass", async function () {
    pass = await MintPass.new(100, 5, 1e17.toString(), "https://uri");
  });

  // test:
  // - can only mint when sale started, fail if saleStarted is false
  // - can mint 10 mint passes, but not more than that
  // - can't mint more than 5 per address
  // - should fail if provides less than 1e15 wei
  // - owner is able to withdraw
  // - deploy mint pass again with price = 0 wei, check that users can mint for free

  // it should have correct URI
  it("should have correct URI", async function () {
    const uri = await pass.uri(0);
    assert.equal(uri, "https://uri");
  });

  // it should fail to mint if saleStarted is false
  it("should fail to mint if saleStarted is false", async function () {
    await expectRevert(
      pass.claim(user1, { from: user1, value: 1e15 }),
      "Sale not started"
    );
  });

  it("should mint 10 passes", async function () {

    pass = await MintPass.new(10, 9999, 1e15, "https://uri"); // max per address = 100

    await pass.flipSaleStarted();

    for (let i = 0; i < 10; i++) {
      await pass.claim(1, { from: user1, value: 1e15 });
    }

    const balance = await pass.balanceOf(user1, 0);
    assert.equal(balance.toNumber(), 10);

    // should fail if mint more
    await expectRevert(
      pass.claim(1, { from: user1 }),
      "Already minted too much tokens",
    );
  });

  // it should fail if mint more than 5 per address
  it("should fail if mint more than 5 per address", async function () {
    pass = await MintPass.new(100, 5, 1e15, "https://uri");

    await pass.flipSaleStarted();

    await pass.claim(5, { from: user1, value: 5*1e15 });

    await expectRevert(
      pass.claim(1, { from: user1 }),
      "Too many tokens per address"
    );
  });

  // it should fail if provides less than 1e15 wei
  it("should fail if provides less than 1e15 wei", async function () {
    pass = await MintPass.new(100, 5, 1e15, "https://uri");

    await pass.flipSaleStarted();

    await expectRevert(
      pass.claim(1, { from: user1, value: 1e14 }),
      "Not enough ETH"
    );
  });

  // it should allow owner to withdraw
  it("should allow owner to withdraw", async function () {
    pass = await MintPass.new(100, 5, 1e15, "https://uri");

    await pass.flipSaleStarted();

    await pass.claim(1, { from: user1, value: 1e15 });

    const balanceBefore = await web3.eth.getBalance(owner);

    await pass.withdraw({ from: owner });

    const balance = await web3.eth.getBalance(owner);

    assert.isAbove(Number(balance), Number(balanceBefore));
  });

  // it should allow free mint pass option
  it("should allow free mint pass option", async function () {
    pass = await MintPass.new(100, 5, 0, "https://uri");

    await pass.flipSaleStarted();

    await pass.claim(1, { from: user1 });

    const balance = await pass.balanceOf(user1, 0);
    assert.equal(balance.toNumber(), 1);
  });

});
