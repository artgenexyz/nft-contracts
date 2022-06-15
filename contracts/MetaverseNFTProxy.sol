// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title LICENSE REQUIREMENT
 * @dev This contract is licensed under the MIT license.
 * @dev You're not allowed to remove DEVELOPER() and DEVELOPER_ADDRESS() from contract
 */

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/INFTExtension.sol";
import "./interfaces/IMetaverseNFT.sol";
import "./utils/OpenseaProxy.sol";

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

contract CustomNFT is Proxy {
    address private constant proxyImplementation = 0xA43220565f2F47565C58bcDf9994b70fdCd279c5;

    bytes32 public immutable id;

    event ProxyCreated(bytes32 salt);

    constructor (bytes32 salt) {
        id = salt;

        emit ProxyCreated(salt);
    }

    /*
    function initialize (
        uint256 _startPrice,
        uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxTokensPerMint,
        uint256 _royaltyFee,
        string memory _uri,
        string memory _name,
        string memory _symbol,
        address payoutReceiver,
        bool shouldUseJSONExtension,
        uint16 miscParams
    ) public {

        Address.functionDelegateCall(
            proxyImplementation,
            abi.encodeWithSelector(
                MetaverseNFT.initialize.selector,
                _startPrice,
                _maxSupply,
                _nReserved,
                _maxTokensPerMint,
                _royaltyFee,
                _uri,
                _name,
                _symbol,
                miscParams & (1 << 1) != 0
            )
        );

        if (shouldUseJSONExtension) {
            Address.functionDelegateCall(proxyImplementation,abi.encodeWithSelector(
                MetaverseNFT.setPostfixURI.selector, ".json"
            ));
        }

        if (miscParams & (1 << 2) != 0) {
            Address.functionDelegateCall(proxyImplementation,abi.encodeWithSelector(
                MetaverseNFT.startSale.selector
            ));
        }

        if (payoutReceiver != address(0)) {
            Address.functionDelegateCall(proxyImplementation,abi.encodeWithSelector(
                MetaverseNFT.setPayoutReceiver.selector, (payoutReceiver)
            ));
        }

        if (miscParams & (1 << 3) != 0) {
            Address.functionDelegateCall(proxyImplementation,abi.encodeWithSelector(
                MetaverseNFT.lockPayoutChange.selector
            ));
        }
    }
    */

    function _implementation() internal override pure returns (address) {
        return address(proxyImplementation);
    }
}
