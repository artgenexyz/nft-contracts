// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title LICENSE REQUIREMENT
 * @dev This contract is licensed under the MIT license.
 * @dev You're not allowed to remove DEVELOPER() and DEVELOPER_ADDRESS() from contract
 */

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./MetaverseNFT.sol";

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

contract MetaverseNFTProxy is Proxy, Initializable {
    address internal constant proxyImplementation =
        0xA43220565f2F47565C58bcDf9994b70fdCd279c5;

    struct Args {
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

    // bytes32 public immutable id;

    event MetaverseNFTCreated(
        bytes32 indexed salt,
        string _name,
        string _symbol,
        uint256 maxSupply
    );

    constructor(Args memory args) // bool shouldUseJSONExtension
    {
        // id = keccak256(abi.encodePacked(msg.sender, _name, _symbol, block.timestamp));
        // bytes32 salt = keccak256(abi.encodePacked(msg.sender, _name, _symbol, block.timestamp));

        // emit MetaverseNFTCreated(salt, _name, _symbol, _maxSupply);

        Address.functionDelegateCall(
            proxyImplementation,
            abi.encodeWithSelector(
                MetaverseNFT.initialize.selector,
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
                    MetaverseNFT.setPostfixURI.selector,
                    ".json"
                )
            );
        }

        if (miscParams & (1 << 2) != 0) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(MetaverseNFT.startSale.selector)
            );
        }

        if (payoutReceiver != address(0)) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(
                    MetaverseNFT.setPayoutReceiver.selector,
                    (payoutReceiver)
                )
            );
        }

        if (miscParams & (1 << 3) != 0) {
            Address.functionDelegateCall(
                proxyImplementation,
                abi.encodeWithSelector(MetaverseNFT.lockPayoutChange.selector)
            );
        }
    }

    function implementation() public pure returns (address) {
        return address(proxyImplementation);
    }

    function _implementation() internal pure override returns (address) {
        return address(proxyImplementation);
    }
}
