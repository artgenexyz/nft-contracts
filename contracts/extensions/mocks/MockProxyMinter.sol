// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

interface IMetaverseNFT {
  function mint(uint256 nTokens) external payable;
}

contract MockProxyMinter is ERC721Holder {
  address public immutable nft;

  constructor(address _nft) {
    nft = _nft;
  }

  function mint() external payable {
    IMetaverseNFT(nft).mint{ value: msg.value }( 1 );
  }
}
