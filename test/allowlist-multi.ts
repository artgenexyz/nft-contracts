import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";

import { AllowlistFactory } from "../typechain-types";
import { ContractTransaction } from "ethers";
import { keccak256 } from "ethers/lib/utils";

const { parseEther } = ethers.utils;

const MAX_AMOUNT_TESTING = 3;

describe("Allowlist Factory", () => {
  let factory: AllowlistFactory;

  // Setting some values
  const generateAllowlist = (
    users: SignerWithAddress[],
    { maxAmount }: any = { maxAmount: MAX_AMOUNT_TESTING }
  ) =>
    StandardMerkleTree.of(
      users.map((user) => [keccak256(user.address), maxAmount]),
      ["bytes32", "uint256"]
    );

  const getDeployedAddress = async (tx: ContractTransaction) => {
    const res = await tx.wait();

    const event = res.events?.find((e) => e.event === "ContractDeployed");

    return event?.args?.deployedAddress;
  };

  beforeEach(async () => {
    const f = await ethers.getContractFactory("AllowlistFactory");

    factory = await f.deploy();
  });

  it("should deploy factory", async () => {
    expect(factory.address).to.be.a("string");
  });

  it("should deploy contract", async function () {
    const [owner, user1, user2] = await ethers.getSigners();

    const nftAddress = user1.address;

    const tx = await factory.connect(user2).createAllowlist(
      "Test List",
      nftAddress,
      "0xbd204967d5ef69fe133d1e2e9509f68bf3ee681006804e37b0bd51a64aea0116",
      parseEther("0.1"),
      // 1,
      true
    );

    const res = await tx.wait();

    const event = res.events?.find((e) => e.event === "ContractDeployed");

    expect(event).to.exist;

    expect(event?.args?.nft).to.equal(nftAddress);

    const contract = await ethers.getContractAt(
      "Allowlist",
      event?.args?.deployedAddress
    );

    expect(event?.args?.title).to.equal("Test List");
    expect(contract.address).to.equal(event?.args?.deployedAddress);

    expect(await contract.owner()).to.equal(user2.address);
    expect(await contract.nft()).to.equal(nftAddress);

    expect(await contract.saleStarted()).to.equal(true);

    await contract.connect(user2).startSale();

    expect(await contract.saleStarted()).to.equal(true);
  });

  // it should mint successfully
  it("should check proof validity", async function () {
    const [owner, user1, user2] = await ethers.getSigners();

    const tree = generateAllowlist([owner, user1, user2], {
      maxAmount: MAX_AMOUNT_TESTING,
    });
    const root = tree.root;
    const proof = tree.getProof(1);

    const nftAddress = user1.address;

    const tx = await factory.createAllowlist(
      "Test List",
      nftAddress,
      root,
      parseEther("0"),
      false // start sale
    );

    const allwlst = await getDeployedAddress(tx);
    const contract = await ethers.getContractAt("Allowlist", allwlst);

    expect(await contract.allowlistRoot()).to.equal(root);

    const leaf = [keccak256(user1.address), MAX_AMOUNT_TESTING];
    tree.leafHash(leaf); // test proof against itself
    expect(
      StandardMerkleTree.verify(
        root,
        ["bytes32", "uint256"],
        [keccak256(user1.address), MAX_AMOUNT_TESTING],
        proof
      )
    ).to.equal(true);

    expect(
      await contract.computeLeaf(user1.address, MAX_AMOUNT_TESTING)
    ).to.equal(tree.leafHash(leaf));

    // test proof against itself
    expect(
      StandardMerkleTree.verify(
        root,
        ["bytes32", "uint256"],
        [keccak256(user1.address), MAX_AMOUNT_TESTING],
        proof
      )
    ).to.equal(true);

    expect(
      await contract.isAllowlisted(
        root,
        user1.address,
        MAX_AMOUNT_TESTING,
        proof
      )
    ).to.equal(true);

    expect(
      await contract.isAllowlisted(
        root,
        user2.address,
        MAX_AMOUNT_TESTING,
        proof
      )
    ).to.equal(false);
  });

  it("should have title for each allowlist", async function () {
    const [owner, user1, user2] = await ethers.getSigners();

    const nftAddress = user1.address;

    const tx = await factory.createAllowlist(
      "Test List",
      nftAddress,
      "0xbd204967d5ef69fe133d1e2e9509f68bf3ee681006804e37b0bd51a64aea0116",
      parseEther("0"),
      // 1,
      false
    );

    const contract = await ethers.getContractAt(
      "Allowlist",
      await getDeployedAddress(tx)
    );

    expect(await contract.title()).to.equal("Test List");
  });

  // it should mint successfully
  it("should mint successfully", async function () {
    const NFT = await ethers.getContractFactory("ERC721CommunityBase");

    const [minter1, minter2, minter3] = await ethers.getSigners();

    const tree = generateAllowlist([minter1, minter2, minter3]);
    const root = tree.root;

    const proof1 = tree.getProof(0);
    const proof2 = tree.getProof(1);
    const proof3 = tree.getProof(2);

    // const root =
    //   "0xfbc2f54de92972c0f2c6bbd5003031662aa9b8240f4375dc03d3157d8651ec45";

    // const proof1 = [
    //   "0x343750465941b29921f50a28e0e43050e5e1c2611a3ea8d7fe1001090d5e1436",
    // ];
    // const proof2 = [
    //   "0x8a3552d60a98e0ade765adddad0a2e420ca9b1eef5f326ba7ab860bb4ea72c94",
    //   "0xe9707d0e6171f728f7473c24cc0432a9b07eaaf1efed6a137a4a8c12c79552d9",
    // ];

    // const proof3 = [
    //   "0x00314e565e0574cb412563df634608d76f5c59d9f817e85966100ec1d48005c0",
    //   "0xe9707d0e6171f728f7473c24cc0432a9b07eaaf1efed6a137a4a8c12c79552d9",
    // ];

    const nft1 = await NFT.deploy(
      "Test NFT",
      "TEST",
      100,
      1,
      false,
      "https://example.com",
      {
        publicPrice: parseEther("0.1"),
        maxTokensPerMint: 5,
        maxTokensPerWallet: 5,
        royaltyFee: 500,
        payoutReceiver: "0x0000000000000000000000000000000000000000",
        shouldLockPayoutReceiver: false,
        shouldStartSale: false,
        shouldUseJsonExtension: false,
      }
    );

    const tx = await factory.createAllowlist(
      "Test List",
      nft1.address,
      root,
      parseEther("0"),
      // 1, // max per address
      true // start sale
    );

    const list = await ethers.getContractAt(
      "Allowlist",
      await getDeployedAddress(tx)
    );

    expect(await list.allowlistRoot()).to.equal(root);

    expect(
      await list.isAllowlisted(
        root,
        minter1.address,
        MAX_AMOUNT_TESTING,
        proof1
      )
    ).to.equal(true);

    await nft1.addExtension(list.address);

    await list.connect(minter1).mint(1, MAX_AMOUNT_TESTING, proof1);

    expect(await nft1.balanceOf(minter1.address)).to.equal(1);

    await list.connect(minter2).mint(1, MAX_AMOUNT_TESTING, proof2);

    expect(await nft1.balanceOf(minter2.address)).to.equal(1);

    await list.connect(minter3).mint(1, MAX_AMOUNT_TESTING, proof3);

    expect(await nft1.balanceOf(minter3.address)).to.equal(1);
  });
});
