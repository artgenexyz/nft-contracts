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
//                        'ox0X0d:           cNK,
//                 ','  ;xXX0x:              dWk
//            ,cdO0KKKKKXKo,                ,0Nl
//         ;oOXKko:,;kWMNl                  dWO'
//      ,o0XKd:'    oNMMK:                 cXX:
//   'ckNNk:       ;KMN0c                 cXXl
//  'OWMMWKOdl;'    cl;                  oXXc
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
        0xA43220565f2F47565C58bcDf9994b70fdCd279c5;

    struct MetaverseNFTArgs {
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

    event MetaverseNFTCreated(
        string _name,
        string _symbol,
        uint256 maxSupply
    );

    constructor(MetaverseNFTArgs memory args) {

        Address.functionDelegateCall(
            proxyImplementation,
            abi.encodeWithSelector(
                IMetaverseNFTSetup.initialize.selector,
                args.startPrice,
                args.maxSupply,
                args.nReserved,
                args.maxTokensPerMint,
                args.royaltyFee,
                args.uri,
                args.name,
                args.symbol,
                args.miscParams & (1 << 1) != 0
            )
        );

        emit MetaverseNFTCreated(args.name, args.symbol, args.maxSupply);

    }

    function initialize(
        // init sale : (should start = true/false)
        // uint256 _startPrice,
        // uint256 _maxTokensPerMint,
        // uint256 _royaltyFee,
        address payoutReceiver,
        uint16 miscParams,
        bool shouldUseJSONExtension
    ) public {
        if (shouldUseJSONExtension) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(
                    IMetaverseNFTSetup.setPostfixURI.selector,
                    ".json"
                )
            );
        }

        if (miscParams & (1 << 2) != 0) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(IMetaverseNFTSetup.startSale.selector)
            );
        }

        if (payoutReceiver != address(0)) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(
                    IMetaverseNFTSetup.setPayoutReceiver.selector,
                    payoutReceiver
                )
            );
        }

        if (miscParams & (1 << 3) != 0) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(
                    IMetaverseNFTSetup.lockPayoutChange.selector
                )
            );
        }
    }

    function implementation() public view returns (address) {
        return _implementation();
    }

    function _implementation() internal pure override returns (address) {
        return address(proxyImplementation);
    }
}
