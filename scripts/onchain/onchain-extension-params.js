const deployedContracts = {
  mainnet: {
    ScriptyStorage: "0x096451F43800f207FC32B4FF86F286EdaF736eE3",
    ScriptyBuilder: "0x16b727a2Fc9322C724F4Bc562910c99a5edA5084",
    ETHFSFileStorage: "0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e",
  },
  goerli: {
    ScriptyStorage: "0x730B0ADaaD15B0551928bAE7011F2C1F2A9CA20C",
    ScriptyBuilder: "0xc9AB9815d4D5461F3b53Ebd857b6582E82A45C49",
    ETHFSFileStorage: "0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa",
  },
};

const artgeneScript = {
  address: "0xA9130dd87b0DAf3c18A11397aAF79f72a36676fc",
};

module.exports = [
  "0xA0aB30ABbb6135ddD2Be89D6CdAE5d6B33EE08aD",
  artgeneScript.address,

  deployedContracts.mainnet.ETHFSFileStorage,
  deployedContracts.mainnet.ScriptyStorage,
  deployedContracts.mainnet.ScriptyBuilder,
];
