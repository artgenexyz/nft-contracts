// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/solidity-examples/contracts/token/onft/extension/ProxyONFT721.sol";

contract L2NFTProxy is ProxyONFT721 {
    constructor(
        address _lzEndpoint,
        address _proxyToken
    ) ProxyONFT721(200_000, _lzEndpoint, _proxyToken) {}
}
