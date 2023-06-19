// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Artgene721.sol";
import "./Artgene721Base.sol";

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
contract DemoCollection is Artgene721Base {
    constructor()
        Artgene721Base(
            "Generative Endless NFT",
            "GEN",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION,
            1,
            false,
            "https://metadata.artgene.xyz/api/g/goerli/midline/",
            // optionally, use defaultConfig()
            MintConfig(
                0.1 ether, // public price
                5, // maxTokensPerMint,
                5, // maxTokensPerWallet,
                500, // basis points royalty fee
                msg.sender, // payout receiver
                false, // should lock payout receiver
                1684290476, // startTimestamp
                1684390476 // endTimestamp
            )
        )
    {}

    // empty config
    // MintConfig(
    //     0, // public price
    //     0, // maxTokensPerMint,
    //     0, // maxTokensPerWallet,
    //     0, // basis points royalty fee
    //     address(0), // payout receiver
    //     false, // should lock payout receiver
    //     false, // should start sale
    //     false // should use json extension
    // )

    // default config
    // MintConfig(
    //     0, // public price
    //     50, // maxTokensPerMint,
    //     0, // maxTokensPerWallet,
    //     500, // basis points royalty fee
    //     msg.sender, // payout receiver
    //     false, // should lock payout receiver
    //     false, // should start sale
    //     false // should use json extension
    // );
}
