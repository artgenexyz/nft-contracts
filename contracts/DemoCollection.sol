// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721XYZ.sol";

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
contract DemoCollection is ERC721XYZ {
    constructor()
        ERC721XYZ(
            "DemoCollection",
            "DC",
            1337,
            1,
            true, // should start at one
            "ipfs://QmABABABABABABABABABABABABABA/",
            init(
                0.1 ether, // public price
                5, // maxTokensPerMint,
                5, // maxTokensPerWallet,
                500, // basis points royalty fee
                msg.sender, // payout receiver
                false, // should start sale
                false, // should lock payout receiver
                true // should use json extension
            )
        )
    {}
}
