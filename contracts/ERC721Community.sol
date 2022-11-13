// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/IERC721Community.sol";

/**
 * @title made by buildship.xyz
 * @dev ERC721Community is extendable implementation of ERC721 based on ERC721A and ERC721CommunityImplementation.
 */

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

type StartFromTokenIdOne is bool;

contract ERC721Community is Proxy {
    address internal constant proxyImplementation =
        0xf3E07A5cBDFE6a257A7caa4Fcb3187A1C2Ec6a2E;

    StartFromTokenIdOne internal constant START_FROM_ONE = StartFromTokenIdOne.wrap(true);
    StartFromTokenIdOne internal constant START_FROM_ZERO = StartFromTokenIdOne.wrap(false);

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 nReserved,
        StartFromTokenIdOne startAtOne,
        string memory uri,
        MintConfig memory configValues
    ) {
        Address.functionDelegateCall(
            proxyImplementation,
            abi.encodeWithSelector(
                IERC721CommunityImplementation.initialize.selector,
                name,
                symbol,
                maxSupply,
                nReserved,
                startAtOne,
                uri,
                configValues
            )
        );
    }

    function implementation() public pure returns (address) {
        return _implementation();
    }

    function _implementation() internal pure override returns (address) {
        return address(proxyImplementation);
    }
}
