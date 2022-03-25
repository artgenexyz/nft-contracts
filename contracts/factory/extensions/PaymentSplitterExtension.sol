// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

import "./NFTExtension.sol";

contract SplitterExtension is PaymentSplitter, NFTExtension {
    constructor(address _nft, address[] memory payees, uint256[] memory shares)
        NFTExtension(_nft)
        PaymentSplitter(payees, shares) {}

    // function release(address payable) public pure override {
    //     revert("Not supported");
    // }

    function release() public virtual {
        uint256 index = 0;

        while (true) {
            // Get the next account to release
            address account = payee(index);

            if (account == address(0)) {
                break;
            }

            index += 1;

            super.release(payable(account));
        }
    }

}
