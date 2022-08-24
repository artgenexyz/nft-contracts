// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/IMetaverseNFT.sol";

//      Want to launch your own collection?
//        Check out https://buildship.xyz

//                                    ,:loxO0KXXc
//                               ,cdOKKKOxol:lKWl
//                            ;oOXKko:,      ;KNc
//                         ox0X0d:           cNK,
//                      ;xXX0x:              dWk
//            ,cdO0KKKKKXKo,                ,0Nl
//         ;oOXKko:,;kWMNl                  dWO'
//      ,o0XKd:'    oNMMK:                 cXX:
//   'ckNNk:       ;KMN0c                 cXXl
//  'OWMMWKOdl;     cl;                  oXXc
//   ;cclldxOKXKkl,                    ;kNO;
//            ;cdk0kl'             ;clxXXo
//                ':oxo'         c0WMMMMK;
//                    :l:       lNMWXxOWWo
//                      ';      :xdc' :XWd
//             ,                      cXK;
//           ':,                      xXl
//           ;:      '               o0c
//           ;c;,,,,'               lx;
//            '''                  cc
//                                ,'
contract MetaverseNFTProxy is Proxy {
    address internal constant proxyImplementation =
        0xb1b1B1B17c265aF88dDbD25e385EA9f46237459e;

    event MetaverseNFTCreated(
        string _name,
        string _symbol,
        uint256 maxSupply,
        address deployedAddress
    );

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 nReserved,
        bool startAtOne,
        string memory uri,
        MetaverseNFTConfig memory config
    ) {
        Address.functionDelegateCall(
            proxyImplementation,
            abi.encodeWithSelector(
                IMetaverseNFTImplementation.initialize.selector,
                name,
                symbol,
                maxSupply,
                nReserved,
                startAtOne,
                uri,
                config
            )
        );

        emit MetaverseNFTCreated(name, symbol, maxSupply, address(this));
    }


    function config(
        uint256 price,
        uint256 maxTokensPerMint,
        uint256 maxTokensPerWallet,
        uint256 royaltyFee,
        address payoutReceiver,
        bool shouldLockPayoutReceiver,
        bool shouldStartSale,
        bool shouldUseJsonExtension
    ) internal pure returns (MetaverseNFTConfig memory) {
        return
            MetaverseNFTConfig({
                publicPrice: price,
                maxTokensPerMint: maxTokensPerMint,
                maxTokensPerWallet: maxTokensPerWallet,
                royaltyFee: royaltyFee,
                payoutReceiver: payoutReceiver,
                shouldLockPayoutReceiver: shouldLockPayoutReceiver,
                shouldStartSale: shouldStartSale,
                shouldUseJsonExtension: shouldUseJsonExtension
            });
    }

    function implementation() public pure returns (address) {
        return _implementation();
    }

    function _implementation() internal pure override returns (address) {
        return address(proxyImplementation);
    }
}
