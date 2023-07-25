//  hh call --network zksyncEra AllowlistBaseFactory 0xe3B404D760a6217E8CC5B2ebDc77777bA0260770 createAllowlist --args '["cmc", "0x6f0978c21beeCa1d74DAfbCc5bc86a6c466CE67C", "0x2092ad691bab26cc2d010e4be0e921096833757e003961b955bdefe1ccf6f3e3", "0", false]'  --value 0 

ARGS='["cmc", "0x6f0978c21beeCa1d74DAfbCc5bc86a6c466CE67C", "0x2092ad691bab26cc2d010e4be0e921096833757e003961b955bdefe1ccf6f3e3", "0", false]'

// now use it:
// hh call --network zksyncEra AllowlistBase 0xFa484b0b4E2836ff7599C5E461857aF35F7299bE startSale --args '[]'
// hh call --network zksyncEra colormcode 0x6f0978c21beeCa1d74DAfbCc5bc86a6c466CE67C addExtension --args '["0xFa484b0b4E2836ff7599C5E461857aF35F7299bE"]'

// omit last of an array
module.exports = JSON.parse(ARGS).slice(0, -1)
