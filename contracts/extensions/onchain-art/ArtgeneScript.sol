// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "solady/src/utils/Base64.sol";

// Using https://github.com/artgenexyz/app/blob/08516e28b392a021237aca0792f0bc0f6d48b740/components/code-editor/iframe/renderHTML.ts
// ((window) => {
//     let dna =
//         new URLSearchParams(window.location.search).get("dna") ||
//         window.dna;

//     if (!dna) {
//         // example: 0xde4b0d963091d3b0a9c9604784c0d9df49e4261df639643cc07185e78bb930ab
//         // random 64 chars of abcd...1234 in hex
//         dna =
//             "0x" +
//             Array(64)
//                 .fill(0)
//                 .map(() => "0123456789abcdef"[(Math.random() * 16) | 0])
//                 .join("");
//     }

//     // Read about random generators:
//     // https://stackoverflow.com/questions/521295/seeding-the-random-number-generator-in-javascript
//     function xmur3(str) {
//         for (var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
//             h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
//             h = (h << 13) | (h >>> 19);
//         }
//         return function () {
//             h = Math.imul(h ^ (h >>> 16), 2246822507);
//             h = Math.imul(h ^ (h >>> 13), 3266489909);
//             return (h ^= h >>> 16) >>> 0;
//         };
//     }

//     function sfc32(a, b, c, d) {
//         return function () {
//             a |= 0;
//             b |= 0;
//             c |= 0;
//             d |= 0;
//             var t = (((a + b) | 0) + d) | 0;
//             d = (d + 1) | 0;
//             a = b ^ (b >>> 9);
//             b = (c + (c << 3)) | 0;
//             c = (c << 21) | (c >>> 11);
//             c = (c + t) | 0;
//             return (t >>> 0) / 4294967296;
//         };
//     }

//     const hash = xmur3(dna);

//     // Pad seed with Phi, Pi and E.
//     // https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
//     const _rand = sfc32(0x9e3779b9, 0x243f6a88, 0xb7e15162, hash());

//     window.rendered = false;
//     const preview = () => {
//         window.rendered = true;
//     };

//     // rand(a) returns [0, a); rand(a, b) returns [a, b)
//     const rand = (a, b) => {
//         if (Array.isArray(a) && b === undefined) {
//             return a[Math.floor(_rand() * a.length)];
//         }
//         if (a === undefined) {
//             return _rand();
//         } else if (b === undefined) {
//             return _rand() * a;
//         } else {
//             return _rand() * (b - a) + a;
//         }
//     };

//     window.rand = rand;
//     window.preview = preview;

//     // for compatibility
//     window.fxrand = rand;
//     window.fxpreview = preview;

//     window.genome = [];

//     const evolve = (name, value) => {
//         const genome = window.genome;
//         const gene = genome.find((g) => g.name === name);

//         if (!gene) {
//             genome.push({
//                 name,
//                 value,
//             });
//         } else {
//             gene.value = value;
//         }

//         return {
//             name,
//             value,
//         };
//     };

//     window.dna = dna;

//     window.Artgene = {
//         dna,
//         genome: window.genome,
//         rand,
//         preview,
//         evolve,
//     };
// })(window);

// ((document) => {
//     // <title>artgene.xyz</title>
//     // <style>
//     //   html,
//     //   body {
//     //     margin: 0;
//     //     padding: 0;
//     //   }

//     //   main {
//     //     width: 100vw;
//     //     height: 100vh;
//     //     display: flex;
//     //   }

//     //   canvas {
//     //     display: block;
//     //     margin: auto;
//     //     max-width: 100%;
//     //     max-height: 100%;
//     //     /* for canvases bigger than screen size */
//     //     object-fit: contain;
//     //   }
//     // </style>

//     // Create the title element
//     var title = document.createElement("title");
//     title.textContent = "artgene.xyz";
//     document.head.appendChild(title);

//     // Create the style element
//     var style = document.createElement("style");
//     style.textContent = `html,body{margin:0;padding:0}main{width:100vw;height:100vh;display:flex}canvas{display:block;margin:auto;max-width:100%;max-height:100%;object-fit:contain}`;
//     document.head.appendChild(style);
// })(document);

contract ArtgeneScript {
    bytes private constant _SCRIPT =
        hex"1f8b08085f908764000361727467656e652e6d696e2e6a73006d54db6ee33610fd1557c02ec84a5175b36c49a18120e85b0b142dfab4c862196b64692b91063dbe55d6bf7728d949bac90b450e8767ce191d928158f52de04c0905c7d9df7ffef61748b3aeff9046763b067eabd7121badfcdd18e7fe069039a5920ebf5cc0a749d154ec27c57b259ce0e4b80fc6c8334b13ee574ddbb280fb9ddc32c6b858394118c5c93c5d2c33f9bc2ea172befc2eb1f68d54a5ee18ff394c2fc113e7fe77dd28e6387ca8f66a6dabcf9001ef2b6dd8411ae21a7828c2c5220be27811c45f8926a80dd685ba7f9dba2eef518c059a6edf32a4b4752dcda32ee10199e25e9cc451162ee379cc0b14787f1fc6175cad56613618c0bd51b35b7df623d498967a5194a4cb289a070b8bf02e21f6e2284d93659605192f264cda13d3694e6330bc6a940c3ce5a12779ffbe3c5c4450283ba01da41d6c2f8c60e0aa4bc05d79a1b0906e485f10eaab22f8ac50025d46d2624ee15164144e2243bb740d85afc48ce5c37f49a22cc9d24594a5c3b0d66a8754c3b6ab98168d902c4ae74912cf1769e6a5c1328ce74bea451c2c932c4bb334f20ce3bc00df802ac140292ad9eee07abe14d60afd9b5d347b18aebb5ad826d80472d56825bfd94d9602fef9b31242ece958d528285fda04938daa5693411af2d1cd04fc692018f8f010e50d40b46694f131ec8834e6bc8d307507dc8561b002c9b842d3646be0d0c0519434af4e2fe1eaf47663034a7720be3c5db5b682d1efb65aa7b514b79ce2d677499748958c24acc057b2b35214f5d65e39c37be96ff7bb9af5762757de41b67bc871e057d2fe18107875f38f695601dd5fa1e8fb60904a83e8294029138dfcc6c7b38a72ed5dd5e4a50707dd1e206f8781b32351d4475e5896fd743fe9a6199008bfb6d081a207031b6cc1e185f2114ef8a815525838722aeb9fceff3ac4a20659fa72bb25673cd64d5b5ad759407c0fb8c3f30888ff03fc5663d77acfba3cf79d349b46e541b19565d9a84d1e0c9d6c547f6c4aacf330080ec7a2866653e3b8a88bb2d96d5b79ceab164ec35aaa83dcf5b7d8333d83ff145748b9474df3d3dd0bd4a771f98af6a9d0cfdf618d77558339fd4ba4c2c3b78f0422a706967abdb7aa78f11f70fed8eb8f050000";

    function version() external pure returns (string memory) {
        return "0.1.0";
    }

    function getScriptBase64() public pure returns (bytes memory) {
        return bytes(Base64.encode(_SCRIPT));
    }

    function getScriptHex() public pure returns (bytes memory) {
        return _SCRIPT;
    }

    function getScriptString() public pure returns (string memory) {
        return string(_SCRIPT);
    }

    function getInjected(
        uint256 tokenId,
        bytes32 dna
    ) public pure returns (bytes memory) {
        // window.dna = "$dna"; window.tokenId = "$tokenId";
        return
            bytes(
                string.concat(
                    'window.dna = "',
                    Strings.toHexString(uint256(dna), 32),
                    '";',
                    'window.tokenId = "',
                    Strings.toString(tokenId),
                    '";'
                )
            );
    }
}
