// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFT.sol";

contract TextApesNFT is AvatarNFT {

    constructor() AvatarNFT(0.05 ether, 100, 5, 5, "https://buildship-metadata-6xz0ctx2i-caffeinum.vercel.app/api/token/textapes/", "Text Apes", "TEXTAPES") {}

    function upgradeMaxSupply(uint256 newSupply) external onlyOwner {
        require(newSupply > MAX_SUPPLY, "You can only increase maxSupply");
        require(newSupply <= 1000, "Everything has a limit, even greed should.");

        MAX_SUPPLY = newSupply;
    }
}
