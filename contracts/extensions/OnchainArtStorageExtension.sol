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

pragma solidity ^0.8.0;

pragma solidity ^0.8.0;

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


// contract ArtgeneHTMLTemplate {

contract OnchainArtStorageExtension is
    NFTExtension,
    INFTURIExtension,
    IRenderer
{
    string constant TOKEN_URI_TEMPLATE_START =
        'data:application/json;{"name":"OnchainArt","description":"OnchainArt","image":"';
    string constant TOKEN_URI_TEMPLATE_END = '"}';

    string constant HTML_BASE64_PREFIX = "data:text/html;base64,";

    string public generativeArt = "HELLO WORLD";

    bytes private art =
        bytes(
            "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"
        );

    constructor(address _nft, string memory _art) NFTExtension(_nft) {
        generativeArt = _art;
    }

    function updateArt(string calldata _generativeArt) external {
        generativeArt = _generativeArt;
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
                string(art),
                TOKEN_URI_TEMPLATE_END
            );
    }

    function render(
        uint256 tokenId,
        bytes memory optional
    ) external view returns (string memory) {
        return string.concat(
            HTML_BASE64_PREFIX,
            string(art)
        );
    }

    function tokenHTML(
        uint256 tokenId,
        bytes32 dna,
        bytes calldata optional
    ) external view override returns (string memory) {
        return string.concat(
            HTML_BASE64_PREFIX,
            string(art)
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, NFTExtension)
        returns (bool)
    {
        return
            interfaceId == type(INFTURIExtension).interfaceId ||
            interfaceId == type(IRenderer).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
