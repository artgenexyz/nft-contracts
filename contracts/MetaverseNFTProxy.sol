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
        0xb1B131B17E2E2F50dC239917f33575779707D618;

    struct MetaverseNFTArgs {
        string name;
        string symbol;
        uint256 maxSupply;
        uint256 nReserved;
        // public sale setup:
        // uint256 startPrice;
        // uint256 maxTokensPerMint;
        // // todo: init sale : (should start = true/false)
        // uint256 royaltyFee;
        // // address payoutReceiver,
        // uint16 miscParams; // should claim X
        // string uri;
        // bool shouldUseJSONExtension
    }

    struct MetaverseNFTArgsFull {
        string name;
        string symbol;
        uint256 maxSupply;
        uint256 nReserved;
        // public sale setup:
        uint256 startPrice;
        uint256 maxTokensPerMint;
        // todo: init sale : (should start = true/false)
        uint256 royaltyFee;
        // address payoutReceiver,
        uint16 miscParams; // should claim X
        string uri;
        // bool shouldUseJSONExtension
    }

    event MetaverseNFTCreated(string _name, string _symbol, uint256 maxSupply);

    constructor(MetaverseNFTArgs memory args) {
        Address.functionDelegateCall(
            proxyImplementation,
            abi.encodeWithSelector(
                IMetaverseNFTSetup.initialize.selector,
                // 0,
                args.maxSupply,
                args.nReserved,
                // 0,
                // 0,
                // "",
                args.name,
                args.symbol
                // 0
            )
        );

        emit MetaverseNFTCreated(args.name, args.symbol, args.maxSupply);
    }

    function _super(bytes memory data) internal {
        Address.functionDelegateCall(
            proxyImplementation,
            data
        );
    }

    function implementation() public view returns (address) {
        return _implementation();
    }

    function _implementation() internal pure override returns (address) {
        return address(proxyImplementation);
    }
}
