// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "./Allowlist.sol";

contract AllowlistFactory {
  event ContractDeployed(address indexed owner, address indexed deployedAddress, address nft, string title);
  address public immutable implementation;
  constructor() {
    implementation = address(new Allowlist());
  }
  function genesis(string memory title, address nft, bytes32 root, uint256 price, uint256 maxPerAddress) external returns (address) {
    address payable clone = payable(Clones.clone(implementation));
    Allowlist list = Allowlist(clone);
    list.initialize(nft, root, price, maxPerAddress);
    emit ContractDeployed(msg.sender, clone, nft, title);
    return clone;
  }
}