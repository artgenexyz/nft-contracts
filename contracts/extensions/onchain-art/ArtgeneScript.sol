// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import "solady/src/utils/Base64.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/IERC721Community.sol";
import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IRenderer.sol";
import "../base/NFTExtension.sol";

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
    using Strings for uint256;
    using Base64 for bytes;

    bytes private constant _SCRIPT =
        // compressed non minified
        // hex'789c85566d4fe34610fe2bd37c5a83e3f82d4e4c08126ad11d528b10f4da0f88a2b5bd8e7de79774bd0e411cffbd33eb4d08d754fd921dcffb333b331bc62c585ec02b544241d6705842239ee1cbddaff782cbb4b8e592d71d7b2e9bac7d76aa36e5aa6c1ba7d342cb5909c5466836b21650e6c07e42da426f9313105b5eaf2b7106ee361361e2667114b8b1970589cbe3348edc70360f53646779188bd08fbc2c8f82380a83347567de7c2a66f324890397277032218f926312354421a405971db439f024cd1cc7f1fc2084b281426c4977c03172b72338854b29f90b8b420b9cbcac2ae62251f335634f1af9c825e369349bc7e44ce4237860bf7155384338accf09789105dfc17d44d3af6dd9b011e17d035395211cfe2e206d9b4e6148b5128d40e6ebdb82326f782dba354f8541d2157d9e5765b382b2e62bd1d9d00991412e11de2f3797d02949c241b9506add9d4d269de2e9b77623645e61d0b4ad277ff7a2a3ebe82653dff3e3e984bca0e15815623ca43f6efa3a11724cf948ae5a392e9bf157bee15d2acbb5a21079dfa4e405b6752f0386b1e906f35602db700925c2706d28f0f066b3d80d82991bc05f94a3538966a50abc7a38fff87d7a4a3ec84697b2acfb8a15c6882eefe73613978a95960d4118f8b1370fa601d6942c50f1fc1cbc804a8ef4c5c50578b1aeb714aa97cd7bc2ec78909d5184de7d3f8ce6be3f7567c6fb71d58012f1a3289cc7b14bc14c28525ac2de9f3e5d4c85b2d9a7d1e569e0336e4362436a4346591d4d95c3f7259927e64ccd999993caada8028c71ecdc44379d8554a629524461860ccf30a8f112c291e8d428f3847452d4c11fac636019d574e023cbd7d6486b549eb5979d8232ca3bf86a406cc104423f0ee368e6c791c13ff47ac13b2aebd03b34fdc310b495c06db162a32ff7d7379fa8a9cf4636cd880d787ebebcff4cdf64cc2c4bcfc82dcf8629782e5501b74569c36d09d8c470e5fc3009a2719ecb6fe51a9b9d3bad5c4de86b72d3aa829abf5f8feb97715709b1114f43fb93fd90ee138d05e63bdc99bb8d45804d9dc436ae293f0cf288cfe7442733e14dbdc83fc8d14cbb144d26a4202739af3ab11bfab5149b1257e712762bf5431d7ebfbbfef4e9ea0e6eefaefeb8befa7374d4a192bdd0d535db8ee132ed8ab6afb2dd8d3cb8367f5c18a19dfc4b8cbc4742bbf33da0d5cd69b2a2358d6db35c428f71f3b211870dabebc3f4b40904a7b593ffd3c60dc9f7164784e8610c9c1a59abbdeda1bfd7cc501a39ad1e5c6f6b7c6a92b22ad5cb01a07c6b20d1b178e71ef16464b8f9da9a76f1c3e3eeaac4a6ad36c462b4986d9cbbaa170797a6606ff4c1c9e25d4ab28189af0ac2642b6dbf72c8a3ae1711bb57910ca86cc662dd634bbdc241701bdeac830a92bea30518469f07ebef4743dd30e6c971f6d006e25df0a16c3be691aaed44ff5501f3f9fec4196af166997f09d6e21f425487aa';
        // '(() => { let dna = new URLSearchParams(window.location.search).get("dna"); if (!dna) { /* example: 0xde4b0d963091d3b0a9c9604784c0d9df49e4261df639643cc07185e78bb930ab */ /* random 64 chars of abcd...1234 in hex */ dna = "0x" + Array(64) .fill(0) .map((_) => "0123456789abcdef" [(Math.random() * 16) | 0]) .join(""); } window.dna = dna; const Artgene = {}; /* namespace */ /* shuffling images, seed from DNA string */ /* https://stackoverflow.com/questions/521295/seeding-the-random-number-generator-in-javascript */ function xmur3(str) { for (var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) { h = Math.imul(h ^ str.charCodeAt(i), 3432918353); h = (h << 13) | (h >>> 19); } return function () { h = Math.imul(h ^ (h >>> 16), 2246822507); h = Math.imul(h ^ (h >>> 13), 3266489909); return (h ^= h >>> 16) >>> 0; }; } function sfc32(a, b, c, d) { return function () { a |= 0; b |= 0; c |= 0; d |= 0; var t = (((a + b) | 0) + d) | 0; d = (d + 1) | 0; a = b ^ (b >>> 9); b = (c + (c << 3)) | 0; c = (c << 21) | (c >>> 11); c = (c + t) | 0; return (t >>> 0) / 4294967296; }; } const hash = xmur3(dna); console.log("USING DNA:", dna, ", HASH:", hash()); /* Pad seed with Phi, Pi and E. */ /* https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number */ const _rand = sfc32(0x9e3779b9, 0x243f6a88, 0xb7e15162, hash()); window.rendered = false; const preview = () => { console.log("TRIGGER PREVIEW"); window.rendered = true; }; /* rand(a) should return [0,a]; rand(a,b) should return [a,b] */ window.rand = (a, b) => { if (a === undefined) { return _rand(); } else if (b === undefined) { return _rand() * a; } else { return _rand() * (b - a) + a; } }; window.preview = preview; /* for compatibility */ window.fxrand = rand; window.fxpreview = preview; window.genome = []; const evolve = (name, value) => { const genome = window.genome; const gene = genome.find((g) => g.name === name); if (!gene) { genome.push({ name, value, }); } else { gene.value = value; } return { name, value, }; }; Artgene.evolve = evolve; Artgene.rand = rand; Artgene.preview = preview; Artgene.genome = window.genome; window.Artgene = Artgene;})(window);';
        // minified
        // '(()=>{let n=new URLSearchParams(window.location.search).get("dna");if(!n){n="0x"+Array(64).fill(0).map((n=>"0123456789abcdef"[Math.random()*16|0])).join("")}window.dna=n;const e={};function o(n){for(var e=0,o=1779033703^n.length;e<n.length;e++){o=Math.imul(o^n.charCodeAt(e),3432918353);o=o<<13|o>>>19}return function(){o=Math.imul(o^o>>>16,2246822507);o=Math.imul(o^o>>>13,3266489909);return(o^=o>>>16)>>>0}}function r(n,e,o,r){return function(){n|=0;e|=0;o|=0;r|=0;var i=(n+e|0)+r|0;r=r+1|0;n=e^e>>>9;e=o+(o<<3)|0;o=o<<21|o>>>11;o=o+i|0;return(i>>>0)/4294967296}}const i=o(n);console.log("USING DNA:",n,", HASH:",i());const d=r(2654435769,608135816,3084996962,i());window.rendered=false;const t=()=>{console.log("TRIGGER PREVIEW");window.rendered=true};window.rand=(n,e)=>{if(n===undefined){return d()}else if(e===undefined){return d()*n}else{return d()*(e-n)+n}};window.preview=t;window.fxrand=rand;window.fxpreview=t;window.genome=[];const a=(n,e)=>{const o=window.genome;const r=o.find((e=>e.name===n));if(!r){o.push({name:n,value:e})}else{r.value=e}return{name:n,value:e}};e.evolve=a;e.rand=rand;e.preview=t;e.genome=window.genome;window.Artgene=e})(window);';
        // hex encoded
        // hex'2828293d3e7b6c6574206e3d6e65772055524c536561726368506172616d732877696e646f772e6c6f636174696f6e2e736561726368292e6765742822646e6122293b696628216e297b6e3d223078222b4172726179283634292e66696c6c2830292e6d617028286e3d3e2230313233343536373839616263646566225b4d6174682e72616e646f6d28292a31367c305d29292e6a6f696e282222297d77696e646f772e646e613d6e3b636f6e737420653d7b7d3b66756e6374696f6e206f286e297b666f722876617220653d302c6f3d313737393033333730335e6e2e6c656e6774683b653c6e2e6c656e6774683b652b2b297b6f3d4d6174682e696d756c286f5e6e2e63686172436f646541742865292c33343332393138333533293b6f3d6f3c3c31337c6f3e3e3e31397d72657475726e2066756e6374696f6e28297b6f3d4d6174682e696d756c286f5e6f3e3e3e31362c32323436383232353037293b6f3d4d6174682e696d756c286f5e6f3e3e3e31332c33323636343839393039293b72657475726e286f5e3d6f3e3e3e3136293e3e3e307d7d66756e6374696f6e2072286e2c652c6f2c72297b72657475726e2066756e6374696f6e28297b6e7c3d303b657c3d303b6f7c3d303b727c3d303b76617220693d286e2b657c30292b727c303b723d722b317c303b6e3d655e653e3e3e393b653d6f2b286f3c3c33297c303b6f3d6f3c3c32317c6f3e3e3e31313b6f3d6f2b697c303b72657475726e28693e3e3e30292f343239343936373239367d7d636f6e737420693d6f286e293b636f6e736f6c652e6c6f6728225553494e4720444e413a222c6e2c222c20484153483a222c692829293b636f6e737420643d7228323635343433353736392c3630383133353831362c333038343939363936322c692829293b77696e646f772e72656e64657265643d66616c73653b636f6e737420743d28293d3e7b636f6e736f6c652e6c6f67282254524947474552205052455649455722293b77696e646f772e72656e64657265643d747275657d3b77696e646f772e72616e643d286e2c65293d3e7b6966286e3d3d3d756e646566696e6564297b72657475726e206428297d656c736520696628653d3d3d756e646566696e6564297b72657475726e206428292a6e7d656c73657b72657475726e206428292a28652d6e292b6e7d7d3b77696e646f772e707265766965773d743b77696e646f772e667872616e643d72616e643b77696e646f772e6678707265766965773d743b77696e646f772e67656e6f6d653d5b5d3b636f6e737420613d286e2c65293d3e7b636f6e7374206f3d77696e646f772e67656e6f6d653b636f6e737420723d6f2e66696e642828653d3e652e6e616d653d3d3d6e29293b6966282172297b6f2e70757368287b6e616d653a6e2c76616c75653a657d297d656c73657b722e76616c75653d657d72657475726e7b6e616d653a6e2c76616c75653a657d7d3b652e65766f6c76653d613b652e72616e643d72616e643b652e707265766965773d743b652e67656e6f6d653d77696e646f772e67656e6f6d653b77696e646f772e41727467656e653d657d292877696e646f77293b';
        // compressed script
        // hex'1f8b0808ff678764000361727467656e652e6d696e2e6a730075546d6f9b3010fe2b8c4ff6600c302171a923455bd556daaa2a5db70f552b79e14898c8b97248d229e1bfcf069abe44fb72d8778fef79ee7c86102ac6bb0a6a0705c2d6b99d7ebb01a9678b6ba9e57245b625e66a1b546a26eb5261b06a833498434ddc1ca54bb3b2201f90ee50b8e193eb4db4967f499ad0a028ab8a843458ca4742508cdd308a59324887232e7fcf7228dcbbefb25e045a1a8a25a11fa3741fde531afc512512d7a54d4f6e6804663385abda01b16bb2628d33abc651c410174a938dd42614fa4a44c3210f191b86ec01830a705e2f32387d597a1edd29d11297cb75459481cd16527f51394c6a02d467098b79346203463325d4e969c4f66a3c1e47bcd150af353acffce47daa1696fa719ca4a3381e84439be108c07c16a76932e23ce434eb729a98e84e5363c3a639d4a809fae02b5fd3dd313dee45988135ca1a6d8ded4529087ab00fa9a7f7c62db417992f0a7800939e672094474c698c1a775b641c75454676eb95f65427acb47ae8e724e6094f87314f9ba6bb8a52d8f6b7f7a22a30233227eeedcde5d5b9f3f56a72e2fae8bbbe7331b9b930eb9250dadf602e3489d34192b0c130e57e1a8e22361899aeb17094709ef234eee0fded6bc01c34e4a290d50afa24b568e7f60df78fe9e5f9f9d9d4b99e9efdbc3cfbe51e67a8f51a9a83d78c9db0bdb589cc0ca310626d804589901f7a9d13da80e1750c02fe87f8882de6b587c027a41e3607ba470d9b12b6a27e76144fad026b5e5c47a839a05a82b8bbef0b9707c9dd5e8937c01ea58532cf0f7362348f2140b9b4da91768fd54c920a1ed7ab05d9d9c809fa1b59ade1041adad711b40e01fdc0bf87351904b051d5068434cb973ae05599f0acfdadc07e37d1b571580adaff6368f60f0436c5998c040000';
        // compressed script base64 encoded
        // hex'483473494346317168325141413246796447646c626d557562576c754c6d707a4148565562572b624d42442b4b347850396d414d4d43467871534e465739565732716f7158626350565374350a34556959794c6c79534e497034622f504270712b525074793248655037336e75664959514b736137436d6f4842634c57755a312b757747705a347472716556795262596c356d6f6256476f6d0a36314a68734771444e4a6844546477637055757a736941666b4f3551754f4754363032306c6e394a6d7443674b4b754b68445259796b644355497a644d49705a4d6b69484979352f7a33496f0a334c7676736c34455768714b4a6145666f335166336c4d612f46456c4574656c545539756141526d4d3457723267477861374a696a544f72786c48454542644b6b3433554a685436536b54440a4951385a4734627341594d4b634634764d6a683957586f6533536e524570664c6455575567633057556e39524f5578714174526e435974354e474944526a4d6c314f6c7078505a71504235480a764e4651727a55367a2f7a6b66616f576c7670786e4b536a4f42364551357668434d4238467164704d75493835445472637071593645355459384f6d4f64536f436672674b312f54335445390a376b57596754584b476d324e375555704348717744366d6e393859747442655a4c777034414a4f655a794355523078706a427033573251636455564764757556396c516e724c5236364f636b0a35676c50687a46506d366137696c4c59397266336f696f77497a496e3775334e35645735382f567163754c36364c752b637a4735755444726b6c4461333241754e496e54515a4b777754446c0a6668714f496a59596d613678634a52776e76493037754439375776414844546b6f70445643766f6b74576a6e396733336a2b6e6c2b666e5a314c6d656e7632385050766c486d656f395271610a6739654d6e62433974596e4d444b4d51596d324152596d5148337164453971413458554d417636482b496774357257487743656b486a5948756b634e6d784b326f6e353246452b74416d74650a5845656f4f614261677269373777755842386e64586f6b337742366c68544c5044334e694e493868514c6d30327046326a39564d6b676f653136734632646e4943666f6257613368424272610a3178473044674839774c2b484e526b4573464856426f5130793563363446575a384b7a397263422b4e3947316356674b3276396a61505950424462466d5977454141413d0a';
        // raw base64
        // "H4sICF1qh2QAA2FydGdlbmUubWluLmpzAHVUbW+bMBD+K4xP9mAMMCFxqSNFW9VW2qoqXbcPVSt54UiYyLlySNIp4b/PBpq+RPty2HeP73nufIYQKsa7CmoHBcLWuZ1+uwGpZ4trqeVyRbYl5mobVGom61JhsGqDNJhDTdwcpUuzsiAfkO5QuOGT6020ln9JmtCgKKuKhDRYykdCUIzdMIpZMkiHIy5/z3Io3Lvvsl4EWhqKJaEfo3Qf3lMa/FElEtelTU9uaARmM4Wr2gGxa7JijTOrxlHEEBdKk43UJhT6SkTDIQ8ZG4bsAYMKcF4vMjh9WXoe3SnREpfLdUWUgc0WUn9ROUxqAtRnCYt5NGIDRjMl1OlpxPZqPB5HvNFQrzU6z/zkfaoWlvpxnKSjOB6EQ5vhCMB8FqdpMuI85DTrcpqY6E5TY8OmOdSoCfrgK1/T3TE97kWYgTXKGm2N7UUpCHqwD6mn98YttBeZLwp4AJOeZyCUR0xpjBp3W2QcdUVGduuV9lQnrLR66Ock5glPhzFPm6a7ilLY9rf3oiowIzIn7u3N5dW58/VqcuL66Lu+czG5uTDrklDa32AuNInTQZKwwTDlfhqOIjYYma6xcJRwnvI07uD97WvAHDTkopDVCvoktWjn9g33j+nl+fnZ1Lmenv28PPvlHmeo9Rqag9eMnbC9tYnMDKMQYm2ARYmQH3qdE9qA4XUMAv6H+Igt5rWHwCekHjYHukcNmxK2on52FE+tAmteXEeoOaBagri77wuXB8ndXok3wB6lhTLPD3NiNI8hQLm02pF2j9VMkgoe16sF2dnICfobWa3hBBra1xG0DgH9wL+HNRkEsFHVBoQ0y5c64FWZ8Kz9rcB+N9G1cVgK2v9jaPYPBDbFmYwEAAA=";
        // compressed script + style css
        hex'1f8b08085f908764000361727467656e652e6d696e2e6a73006d54db6ee33610fd1557c02ec84a5175b36c49a18120e85b0b142dfab4c862196b64692b91063dbe55d6bf7728d949bac90b450e8767ce191d928158f52de04c0905c7d9df7ffef61748b3aeff9046763b067eabd7121badfcdd18e7fe069039a5920ebf5cc0a749d154ec27c57b259ce0e4b80fc6c8334b13ee574ddbb280fb9ddc32c6b858394118c5c93c5d2c33f9bc2ea172befc2eb1f68d54a5ee18ff394c2fc113e7fe77dd28e6387ca8f66a6dabcf9001ef2b6dd8411ae21a7828c2c5220be27811c45f8926a80dd685ba7f9dba2eef518c059a6edf32a4b4752dcda32ee10199e25e9cc451162ee379cc0b14787f1fc6175cad56613618c0bd51b35b7df623d498967a5194a4cb289a070b8bf02e21f6e2284d93659605192f264cda13d3694e6330bc6a940c3ce5a12779ffbe3c5c4450283ba01da41d6c2f8c60e0aa4bc05d79a1b0906e485f10eaab22f8ac50025d46d2624ee15164144e2243bb740d85afc48ce5c37f49a22cc9d24594a5c3b0d66a8754c3b6ab98168d902c4ae74912cf1769e6a5c1328ce74bea451c2c932c4bb334f20ce3bc00df802ac140292ad9eee07abe14d60afd9b5d347b18aebb5ad826d80472d56825bfd94d9602fef9b31242ece958d528285fda04938daa5693411af2d1cd04fc692018f8f010e50d40b46694f131ec8834e6bc8d307507dc8561b002c9b842d3646be0d0c0519434af4e2fe1eaf47663034a7720be3c5db5b682d1efb65aa7b514b79ce2d677499748958c24acc057b2b35214f5d65e39c37be96ff7bb9af5762757de41b67bc871e057d2fe18107875f38f695601dd5fa1e8fb60904a83e8294029138dfcc6c7b38a72ed5dd5e4a50707dd1e206f8781b32351d4475e5896fd743fe9a6199008bfb6d081a207031b6cc1e185f2114ef8a815525838722aeb9fceff3ac4a20659fa72bb25673cd64d5b5ad759407c0fb8c3f30888ff03fc5663d77acfba3cf79d349b46e541b19565d9a84d1e0c9d6c547f6c4aacf330080ec7a2866653e3b8a88bb2d96d5b79ceab164ec35aaa83dcf5b7d8333d83ff145748b9474df3d3dd0bd4a771f98af6a9d0cfdf618d77558339fd4ba4c2c3b78f0422a706967abdb7aa78f11f70fed8eb8f050000';

    function version () external pure returns (string memory) {
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

    function getInjected(uint256 tokenId, bytes32 dna) public pure returns (bytes memory) {
        // window.dna = "$dna"; window.tokenId = "$tokenId";
        return bytes(string.concat(
            'window.dna = "',
            Strings.toHexString(uint256(dna), 32),
            '";',
            'window.tokenId = "',
            Strings.toString(tokenId),
            '";'
        ));
    }

}

