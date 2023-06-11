// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import Base64
// import "@openzeppelin/contracts/utils/Strings.sol";

import "../interfaces/IERC721Community.sol";
import "../interfaces/INFTExtension.sol";
import "./base/NFTExtension.sol";
import "../interfaces/IRenderer.sol";

library Base64Converter {
    function bytesToBase64(
        bytes memory data
    ) public pure returns (string memory) {
        bytes
            memory base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        uint256 len = data.length;
        uint256 outputLen = 4 * ((len + 2) / 3);
        bytes memory result = new bytes(outputLen);

        uint256 resultIndex = 0;
        uint256 dataIndex = 0;

        uint256 paddingLen = len % 3;
        uint256 mainLen = len - paddingLen;

        for (dataIndex = 0; dataIndex < mainLen; dataIndex += 3) {
            uint256 temp = (uint256(uint8(data[dataIndex])) << 16) |
                (uint256(uint8(data[dataIndex + 1])) << 8) |
                uint256(uint8(data[dataIndex + 2]));
            result[resultIndex++] = base64Chars[(temp >> 18) & 0x3F];
            result[resultIndex++] = base64Chars[(temp >> 12) & 0x3F];
            result[resultIndex++] = base64Chars[(temp >> 6) & 0x3F];
            result[resultIndex++] = base64Chars[temp & 0x3F];
        }

        if (paddingLen == 1) {
            uint256 temp = (uint256(uint8(data[dataIndex])) << 16);
            result[resultIndex++] = base64Chars[(temp >> 18) & 0x3F];
            result[resultIndex++] = base64Chars[(temp >> 12) & 0x3F];
            result[resultIndex++] = "=";
            result[resultIndex++] = "=";
        } else if (paddingLen == 2) {
            uint256 temp = (uint256(uint8(data[dataIndex])) << 16) |
                (uint256(uint8(data[dataIndex + 1])) << 8);
            result[resultIndex++] = base64Chars[(temp >> 18) & 0x3F];
            result[resultIndex++] = base64Chars[(temp >> 12) & 0x3F];
            result[resultIndex++] = base64Chars[(temp >> 6) & 0x3F];
            result[resultIndex++] = "=";
        }

        return string(result);
    }
}

contract OnchainArtStorageExtension is
    NFTExtension,
    INFTURIExtension,
    IRenderer
{
    string constant TOKEN_URI_TEMPLATE_START =
        'data:application/json;,{"name":"OnchainArt","description":"OnchainArt","animation_url":"';
    string constant TOKEN_URI_TEMPLATE_END = '"}';

    string constant HTML_BASE64_PREFIX = "data:text/html;base64,";
    // string constant HTML_BASE64_PREFIX = "data:text/html;";

    bytes private template_start =
        bytes(
            '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><script src="https://cdnjs.cloudflare.com/ajax/libs/pako/2.0.4/pako.min.js"></script><script id="hash-snippet">(()=>{let n=new URLSearchParams(window.location.search).get("dna");n||(n="0x"+Array(64).fill(0).map(n=>"0123456789abcdef"[16*Math.random()|0]).join("")),window.dna=n;let e={},o=function(n){for(var e=0,o=1779033703^n.length;e<n.length;e++)o=(o=Math.imul(o^n.charCodeAt(e),3432918353))<<13|o>>>19;return function(){return o=Math.imul((o=Math.imul(o^o>>>16,2246822507))^o>>>13,3266489909),(o^=o>>>16)>>>0}}(n);console.log("USING DNA:",n,", HASH:",o());let r=function(n,e,o,r){return function(){o|=0;var d=((n|=0)+(e|=0)|0)+(r|=0)|0;return r=r+1|0,n=e^e>>>9,e=o+(o<<3)|0,o=(o=o<<21|o>>>11)+d|0,(d>>>0)/4294967296}}(2654435769,608135816,3084996962,o());window.rendered=!1;let d=()=>{console.log("TRIGGER PREVIEW"),window.rendered=!0};window.rand=(n,e)=>void 0===n?r():void 0===e?r()*n:r()*(e-n)+n,window.preview=d,window.fxrand=rand,window.fxpreview=d,window.genome=[],e.evolve=(n,e)=>{let o=window.genome,r=o.find(e=>e.name===n);return r?r.value=e:o.push({name:n,value:e}),{name:n,value:e}},e.rand=rand,e.preview=d,e.genome=window.genome,window.Artgene=e})(window);</script><script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.6.0/p5.min.js"></script>'
            // '<script src="data:text/javascript;base64,eJzFU8FSwjAQvfcr9higQkgdRqdykQsHOTGj59imtENNmDRAq8O/u0mqrQ46cvJAE7Zv377dtw1KYSCVPA6CbC8TUygJlTD7HRnAWwCQaMGNWHB54BWZURoCPgYxvnnmyXaj1V6mJPKRRJVKr1QqyHJ9H0I0Q/SU9h4OVRmttuJJFJvckMiFpHpQCivaO2qBOay4ycdZqZQmWa051hjA0FK0JFIVlVgLkRLEY+TUk59qfmzV2+YqI3bIyGjcBnyuj9IxjbB1gMkEHoU2RcJLKAspKoxlSgOxGbVFxnjcwbFITW6vo7lj9nU8cTNFXE8uyV2TMGqRV+6MOzxDvMd0wdqSID30G3c9TIBZDtL+uR70ktgFSS4Ly2AHbhQE78NuKiFkmr+IBTpr+nFLyShyTakvjEU7CnYxxaf4BLW71emLd8tzg79b2vbp94YkH22jSag8xKmHKAVP5t6cWjeXShevSppzfjbezwb9bMeP9zOG1t8Nde7/6KdzwS/I151oLrTTLcZfk1xW07Pz/OztoH61s2F/oGD/YmdW77Q4FOJI/KcevANMH0pI"></script>',
        );

    bytes private template_end =
        bytes(
            // '<script id="decoder">const e=document.querySelectorAll("script[type=\'text/javascript+gzip\']");e.forEach(e=>{let t=e.src.split(",")[1];!function(e){let t=atob(e);console.log("ARR",t);let o=Uint8Array.from(t,e=>e.charCodeAt(0));console.log("DECODED",o);let l=pako.inflate(o);console.log("TEXT",l);let c=new TextDecoder("utf-8").decode(l);console.log("DECODED",c);let n=document.createElement("script");n.textContent=c,document.head.appendChild(n)}(t)});</script><meta name="viewport" content="width=device-width, initial-scale=1"><title>artgene.xyz</title><style>html,body{margin:0;padding:0}main{background-color:#dedede;width:100vw;height:100vh;display:flex}canvas{object-fit:contain;max-width:100%;max-height:100%;margin:auto;display:block}</style></head><body> <main></main>  </body></html>'
            '<script id="decoder">(()=>{let e=document.querySelectorAll("script[type=\'text/javascript+gzip\']");e.forEach(e=>{let t=e.src.split(",")[1];!function(e){let t=atob(e);console.log("ARR",t);let o=Uint8Array.from(t,e=>e.charCodeAt(0));console.log("DECODED",o);let l=pako.inflate(o);console.log("TEXT",l);let c=new TextDecoder("utf-8").decode(l);console.log("DECODED",c);let n=document.createElement("script");n.textContent=c,document.head.appendChild(n)}(t)})})(window);</script><meta name="viewport" content="width=device-width, initial-scale=1"><title>artgene.xyz</title><style>html,body{margin:0;padding:0}main{background-color:#dedede;width:100vw;height:100vh;display:flex}canvas{object-fit:contain;max-width:100%;max-height:100%;margin:auto;display:block}</style></head><body> <main></main>  </body></html>'
        );

    // base64 encoded gunzipped script
    bytes private artScript =
        bytes(
            // full html
            // "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"
            // js midlines
            // "eJzFU8FSwjAQvfcr9higQkgdRqdykQsHOTGj59imtENNmDRAq8O/u0mqrQ46cvJAE7Zv377dtw1KYSCVPA6CbC8TUygJlTD7HRnAWwCQaMGNWHB54BWZURoCPgYxvnnmyXaj1V6mJPKRRJVKr1QqyHJ9H0I0Q/SU9h4OVRmttuJJFJvckMiFpHpQCivaO2qBOay4ycdZqZQmWa051hjA0FK0JFIVlVgLkRLEY+TUk59qfmzV2+YqI3bIyGjcBnyuj9IxjbB1gMkEHoU2RcJLKAspKoxlSgOxGbVFxnjcwbFITW6vo7lj9nU8cTNFXE8uyV2TMGqRV+6MOzxDvMd0wdqSID30G3c9TIBZDtL+uR70ktgFSS4Ly2AHbhQE78NuKiFkmr+IBTpr+nFLyShyTakvjEU7CnYxxaf4BLW71emLd8tzg79b2vbp94YkH22jSag8xKmHKAVP5t6cWjeXShevSppzfjbezwb9bMeP9zOG1t8Nde7/6KdzwS/I151oLrTTLcZfk1xW07Pz/OztoH61s2F/oGD/YmdW77Q4FOJI/KcevANMH0pI"
            // r1b2
            "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"

        );

    constructor(address _nft, string memory) NFTExtension(_nft) {
        // generativeArt = _art;
    }

    function updateArt(string calldata _generativeArt) external {
        // generativeArt = _generativeArt;
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(INFTURIExtension, IRenderer)
        returns (string memory)
    {
        return "";

        // return
        //     string.concat(
        //         TOKEN_URI_TEMPLATE_START,
        //         tokenHTML(tokenId, bytes32(0), bytes("")),
        //         TOKEN_URI_TEMPLATE_END
        //     );
    }

    function render(
        uint256 tokenId,
        bytes memory optional
    ) public view returns (string memory) {
        return tokenHTML(tokenId, bytes32(0), optional);
    }

    function tokenHTML(
        uint256,
        bytes32,
        bytes memory
    ) public view override returns (string memory) {
        return
            string.concat(
                HTML_BASE64_PREFIX,
                Base64Converter.bytesToBase64(
                    abi.encodePacked(
                        string(template_start),
                        '<script type="text/javascript+gzip" src="data:text/javascript;base64,',
                        string(artScript),
                        '"></script>',
                        string(template_end)
                    )
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(IERC165, NFTExtension) returns (bool) {
        return
            interfaceId == type(INFTURIExtension).interfaceId ||
            interfaceId == type(IRenderer).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
