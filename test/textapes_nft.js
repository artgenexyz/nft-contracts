const TextApesNFT = artifacts.require("TextApesNFT");

const ether = 1e18;

contract("TextApesNFT", accounts => {
    // it should deploy successfully
    it("should deploy successfully", async () => {
        const nft = await TextApesNFT.deployed();
        assert.ok(nft.address);
    });

    // it should be able to upgrade max supply
    it("should be able to upgrade max supply", async () => {
        const nft = await TextApesNFT.deployed();
        const supply = await nft.MAX_SUPPLY();
        assert.equal(supply, 100);
        await nft.upgradeMaxSupply(500);
        const newSupply = await nft.MAX_SUPPLY();
        assert.equal(newSupply, 500);
    });

    // it should fail if you try to decrease max supply
    it("should fail if you try to decrease max supply", async () => {
        const nft = await TextApesNFT.deployed();
        const supply = await nft.MAX_SUPPLY();
        assert.equal(supply, 500);

        try {
            await nft.upgradeMaxSupply(50);
        } catch (err) {
            // expect error to contain "can only increase maxSupply"
            assert.include(err.message, "can only increase maxSupply");
        }
    });

    // it should fail to increase supply to 1500
    it("should fail to increase supply to 1500", async () => {
        const nft = await TextApesNFT.deployed();
        const supply = await nft.MAX_SUPPLY();
        assert.equal(supply, 500);

        try {
            await nft.upgradeMaxSupply(1500);
        } catch (err) {
            // expect error to contain "Everything has a limit"
            assert.include(err.message, "Everything has a limit");
        }
    });

})