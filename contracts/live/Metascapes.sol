// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";

import "../AvatarNFTv2.sol";

// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMN+ohNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMy:`.mMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMy. `/hMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMm:   `dMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMm:   -yNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMy`   :mMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMNo`   -yMMMMMMMMMMMMMMMMMMMMMMMMMMm:   `sNMNyNMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMms`   -hMMMMMMMMMMMMMMMMMMMMMMNo`   -dMMM/ oMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMd:   `+mMMMMMMMMMMMMMMMMMMMh-    /NMMMy  :MMMMMMMMMMMM
// MMMMMMMMMMMMMMMdosNMMMNy-   .yMMMMMMMMMMMMMMMMm/`   `sMMMMs`  .MMMMMMMMMMMM
// MMMMMMMMMMMMMMd`  -hMMMMNh:   /mMMMMMMMMMMMMNs.    -hMMMMh    `MMMMMMMMMMMM
// MMMMMMMMMMMMMM/    `/mMMMMNy-  .dMMMMMMMMMMd-    :hNMMMMh.    `MMMMMMMMMMMM
// MMMMMMMMMMMMMM`      -NMMMMMNo` `yMMMMMMMMs`   :hMMMMMd+`     `MMMMMMMMMMMM
// MMMMMMMMMMMMMm     `..mMMMMMMMm/ `yMMMMMN/   .yMMMMMm:`  `.   .MMMMMMMMMMMM
// MMMMMMMMMMMMMm    `dNmMMMMMMMMMN: `oMMMN:  `+NMMMMMN:    dm+  .MMMMMMMMMMMM
// MMMMMMMMMMMMMN    oMMMMM+omMMMMMN/  /mN:  .hMMMMMMN/    /MMy  .MMMMMMMMMMMM
// MMMMMMMMMMMMMM    dMMMMM: `+mMMMMMy` .:  +mMMMMMMd-    /NMMy  `MMMMMMMMMMMM
// MMMMMMMMMMMMMM`   NMMMMMy   .yMMMMMh.-:-yMMMMMMNs`   -yMMMM+  `MMMMMMMMMMMM
// MMMMMMMMMMMMMM`   NMMMMMM+   `yMMMMMNNMMMMMMMMm/   `+NMMMMM-  `MMMMMMMMMMMM
// MMMMMMMMMMMMMM`   NMMMMMMM+   `hMMMMMMMMMMMMMy.   `yMMMMMMN   `NMMMMMMMMMMM
// MMMMMMMMMMMMMM.   MMMMMMMMMo`  `/mMMMMMMMMMm+    .dMMMMMMMN`  `NMMMMMMMMMMM
// MMMMMMMMMMMMMM-  -MMMMMMMMMMy`   .hMMMMMMMy.    -dMMMMMMMMM-  `MMMMMMMMMMMM
// MMMMMMMMMMMMMM/  yMMMMMMMMMMMd`   `sMMMMN/    `+NMMMMMMMMMM:  `MMMMMMMMMMMM
// MMMMMMMMMMMMMMs `NMMMMMMMMMMMMd.    sMMm-    omMMMMMMMMMMMM-  .MMMMMMMMMMMM
// MMMMMMMMMMMMMMm`+MMMMMMMMMMMMMMN:    /o-   `sMMMMMMMMMMMMMM-  :MMMMMMMMMMMM
// MMMMMMMMMMMMMMMmMMMMMMMMMMMMMMMMMs`   `   :dMMMMMMMMMMMMMMM/  +MMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd//yds/hMMMMMMMMMMMMMMMMMd-`hMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
// MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

contract Metascapes is AvatarNFTv2 {

    constructor() AvatarNFTv2(
        0.3 ether,
        3333, // total supply
        0, // reserved supply
        1, // max mint per transaction
        "https://metadata.buildship.dev/api/token/metascapes/",
        "Metascapes NFT", "META"
    ) {}

    function withdraw() public override onlyOwner {
        uint256 balance = address(this).balance;

        // Sloika multi-sig
        // 0x720d71822E5A128EA015323e9c2Da40DDABe8e08
        // 3.75%
        // Buildship multi-sig
        // 0x704C043CeB93bD6cBE570C6A2708c3E1C0310587
        // 3.75%
        // AI team
        // 0x3F547A321EE5869DeE7B035A89aB24CfF4633181
        // 5%
        // Metascape team
        // ​​0xD7096C2E4281a7429D94ee21B53E7F0011D59FA3
        // 87.5%

        Address.sendValue(payable(0x720d71822E5A128EA015323e9c2Da40DDABe8e08), balance * 375 / 10000);
        Address.sendValue(payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587), balance * 375 / 10000);
        Address.sendValue(payable(0x3F547A321EE5869DeE7B035A89aB24CfF4633181), balance * 500 / 10000);

        Address.sendValue(payable(0xD7096C2E4281a7429D94ee21B53E7F0011D59FA3), balance * 8250 / 10000);

    }

}