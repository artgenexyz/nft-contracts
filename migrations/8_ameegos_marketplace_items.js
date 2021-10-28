const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");
const Market = artifacts.require("Market");

const DemoAGOS = artifacts.require("DemoAGOS");
const DemoShiba = artifacts.require("DemoShiba");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";

module.exports = async function(deployer, network) {
    if (true) { return }

    const extras = await AmeegosMarketplace.deployed();

    // Add items from the list one by one
    // Name, Image Url, Price, Max Supply, Item Type
    // extras.addItem(name, imageUrl, price, maxSupply, itemType, startSale = false)

    await extras.addItem('Pumpkin', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Pumpkin-Skin-Finished.png', '0', 547, 1, false)
    await extras.addItem('Bloodshed Aqua', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Bloodshed-Aqua.png', '60000000000000000000', 10, 0, false)
    await extras.addItem('Caramel', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Caramel-Skin.png', '30000000000000000000', 20, 0, false)
    await extras.addItem('Clouded Ice', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Clouded-Ice.png', '1000000000000000000', 50, 1, false)
    await extras.addItem('Devil', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Devil-Finished.png', '1000000000000000000', 30, 1, false)
    await extras.addItem('Flashy', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Flashy-Finished.png', '30000000000000000000', 20, 0, false)
    await extras.addItem('Funky', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Funky-Finished.png', '25000000000000000000', 25, 0, false)
    await extras.addItem('Galaxy', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Galaxy-Finished.png', '0', 30, 1, false)
    await extras.addItem('Hollow Phantom', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Hollow-Phantom-Finished.png', '40000000000000000000', 15, 0, false)
    await extras.addItem('Iconic', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Iconic-Skin-Finished.png', '80000000000000000000', 20, 0, false)
    await extras.addItem('Mustard Moss', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Mustard-Moss-Finished.png', '10000000000000000000', 50, 0, false)
    await extras.addItem('Ashfall', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Ashfall-Finished.png', '30000000000000000000', 20, 0, false)
    await extras.addItem('Ballistic Chrome', 'https://ameegos.mypinata.cloud/ipfs/Qma2wEeeuKqW5diCoB87CUCkZ3TFpevcoZTiKHkdDFr2Ds/Ballistic-Chrome-Finished.png', '20000000000000000000', 30, 0, false)

    await extras.addItem('Royal Chestplate', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Royal-Chestplate-Finished.png', '0', 547, 1, false)
    await extras.addItem('Royal Vambraces', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Royal-Vambraces-Finished.png', '0', 547, 1, false)
    await extras.addItem('Ashfall Chestplate', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Ashfall-Finished.png', '20000000000000000000', 35, 0, false)
    await extras.addItem('Goldstorm Chestplate', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Goldstorm-Finished.png', '20000000000000000000', 35, 0, false)
    await extras.addItem('Blue Venom', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Blue-Venom-Finished.png', '10000000000000000000', 50, 0, false)
    await extras.addItem('1965', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/1965-Finished.png', '13000000000000000000', 65, 0, false)

    await extras.addItem('Golden Magma', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Golden-Magma-Finished.png', '3000000000000000000', 20, 1, false)
    await extras.addItem('Zombie Cloak', 'https://ameegos.mypinata.cloud/ipfs/QmfXq2ZQeUwYpRHWhZUKVM4R6q1B5EqGVSi9Uczda251Zg/Zombie-Cloak-Finished.png', '0', 547, 1, false)

};
