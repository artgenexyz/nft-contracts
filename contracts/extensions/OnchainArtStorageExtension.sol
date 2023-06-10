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
            '<script id="decoder">const e=document.querySelectorAll("script[type=\'text/javascript+gzip\']");e.forEach(e=>{let t=e.src.split(",")[1];!function(e){let t=atob(e);console.log("ARR",t);let o=Uint8Array.from(t,e=>e.charCodeAt(0));console.log("DECODED",o);let l=pako.inflate(o);console.log("TEXT",l);let c=new TextDecoder("utf-8").decode(l);console.log("DECODED",c);let n=document.createElement("script");n.textContent=c,document.head.appendChild(n)}(t)});</script><meta name="viewport" content="width=device-width, initial-scale=1"><title>artgene.xyz</title><style>html,body{margin:0;padding:0}main{background-color:#dedede;width:100vw;height:100vh;display:flex}canvas{object-fit:contain;max-width:100%;max-height:100%;margin:auto;display:block}</style></head><body> <main></main>  </body></html>'
        );

    // base64 encoded gunzipped script
    bytes private artScript =
        bytes(
            // "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"

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
        return
            string.concat(
                TOKEN_URI_TEMPLATE_START,
                tokenHTML(tokenId, bytes32(0), bytes("")),
                TOKEN_URI_TEMPLATE_END
            );
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
