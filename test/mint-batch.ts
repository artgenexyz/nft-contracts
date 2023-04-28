import { expect } from "chai";
import { ethers, network } from "hardhat";
import { MintBatchExtension } from "../typechain-types";
import { BigNumber } from "ethers";

describe("MintBatchExtension Mainnet Test", () => {
  const recipients =
    "[0x26b3f5214fe3faef6811204ecda0c72854790e0e,0x08a31368cc747621252abb9029440c1af6237fc7,0xe37f987967cfb7c0f7c2a45624a92d34ece681a8,0x0a602e90a9a8edf67274f06569af640873e8e7d5,0xad3c9aefb16ce19e0c31b505d7b76e5b8e7eb9d6,0x95b128b19d961a1f85ff128d69fa77bec69901c2,0x69459ba40bb3b8cff9b0a1daa54ba5571c4dcef1,0x48d25088c42eea5b064e1ac2f89214b2c7e1f465,0x15f04d03a01374787c815979f3aa8074e51026f7,0x8832654103358f9bfde4c3f1108a9bb4c2a449f3,0xa0ee18da01b13bfc1d7a7781df5f450800cd13f4,0x95b128b19d961a1f85ff128d69fa77bec69901c2,0x5f0d1ab2f71bd6e13f38c72708c292f07e5b21da,0x95b128b19d961a1f85ff128d69fa77bec69901c2,0x33bda6543d6b3f4a1345b6cbb76ac1c34522917b,0x13eee41d67b8d99e11174161d72cf8ccd194458c,0x9de0bbb3d6401c70c105e985124bb2c0d91ca0d2,0xd62bd8569622fbd2c3bf8dcf5e4236a240254729,0x04aedebb9b3f88c7e2ba28dd7ef82eb868e91d6d,0xd9af96861de6992b299e9ac004aa4c68771d0815,0x65117b92721fe1faafae732b6a14888590cb6b34,0x64bebdd4423038209545dd6423c13f53341af75f,0xd2b8f16672f26a6de2a396c1bae9f8e1f1b14fcc,0xe2f77048b21932f4f9ed0e3ee39ee81d47502446,0xc1033ebdbf17e1a350d18196035c26090eaac708,0xf604f8b06a7db47b1ff805cdea6d9425dd654891,0x79e53ff1e2dcbeb720d4b0c6eb8474d5cf1744d3,0xe5cc6f5bbb3eee408a1c022d235e6903656f2509,0x973344c664de588b716a17b364757b487f6516ea,0x569d15e3975af6d1e251b7d55d2578c2f92cd33f,0x48d25088c42eea5b064e1ac2f89214b2c7e1f465,0xe7f4fb77920dc6ce633bd90544cfc3c4288135b9,0xb48393dfc231c96abd4d3e46774dccf79f51f240,0xe3497b16ee2efd1d954ed88ca4f3c4c97fcf71bd,0xdc265c5be4dc88a0d254a1ebd48fd593ee3ae1ae,0xf54e19e28b10fb45573b6050d268833eec0302f4,0x070691092906a53663d042d4a2b7cab8da3b7239,0x24333f08e19e69a94e4ba4bda4b097cb7828f1fb,0x530a1e17ae91f5555a2c7f4846cedfd83bb31993,0xb735bed7000627ddbcbc45296bca4f7dc224d511,0xea6c59c77de39701283442b0d008eab4ce338ed3,0xf93f9d82b23176db9307dbe58c61614ae4ce4a05]";
  const amounts =
    "[10,2,10,4,3,4,3,2,10,3,10,4,2,5,2,10,2,10,3,9,2,10,2,2,10,2,5,2,3,5,13,13,7,7,5,5,3,3,3,3,3,3]";

  const nftAddress = "0x04aedebb9b3f88c7e2ba28dd7ef82eb868e91d6d";

  let multiMinter: MintBatchExtension;

  beforeEach(async () => {
    // make sure we're on mainnet fork, if no => exit test

    // if (hre.network.name == "hardhat") {
    //   console.log("on hardhat network, skipping");
    //   return;
    // }

    multiMinter = await ethers.getContractAt(
      "MintBatchExtension",
      "0x06Cb98a36D3564b1CCb542b2F47e233Af63FFEBC"
    );

    if (!multiMinter) {
      console.log("no multiMinter, skipping");
      throw new Error("No multiMinter on this network");
    }

    if ((await multiMinter.provider.getCode(multiMinter.address)) == "0x") {
      console.log("no multiMinter bytecode, skipping");
      return;
    }
  });

  xit("should multimint [only mainnet fork]", async () => {
    const james = "0x4C5489fA2ccE6687f2390854f65FA88Aa338d133";
    const piris = await ethers.getContractAt(
      "Artgene721Implementation",
      nftAddress
    );

    // login as james

    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [james],
    });

    // give james some eth
    await network.provider.send("hardhat_setBalance", [
      james,
      "0x29A2241AF62C0000", // 3 ether
    ]);

    const admin = ethers.provider.getSigner(james);

    await piris.connect(admin).addExtension(multiMinter.address);

    // remove [ and ], then split by comma
    const _recipients = recipients
      .substring(1, recipients.length - 1)
      .split(",");
    const _amounts = amounts.substring(1, amounts.length - 1).split(",");

    // take first 10
    _recipients.length = 25;
    _amounts.length = 25;

    const tx = await multiMinter
      .connect(admin)
      .mintAndSendBatch(piris.address, _recipients, _amounts);

    const receipt = await tx.wait();

    console.log("gas used", receipt.gasUsed.toString());
    console.log("gas price used", tx.maxFeePerGas?.toString());

    console.log(
      "total cost (ETH)",
      receipt.gasUsed
        .mul(tx.maxFeePerGas ?? BigNumber.from(0))
        .div((1e18).toString())
        .toString()
    );

    const totalSupply = await piris.totalSupply();

    // expect(totalSupply).to.equal(42);

    for (let i = 0; i < _recipients.length; i++) {
      const balance = await piris.balanceOf(_recipients[i]);
      expect(balance).to.equal(parseInt(_amounts[i]));
    }
  });
});
