// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import "erc721a/contracts/IERC721A.sol";

import "../interfaces/IERC721Community.sol";
import "../interfaces/INFTExtension.sol";
import "./base/NFTExtension.sol";

contract GenerativeArtURIExtension is NFTExtension, INFTURIExtension {

    string public slug;
    string public name;

    string public description;
    string public animation_url;
    string public external_url;

    string public code;

    mapping(uint256 => bytes32) public gene;

    constructor(
        address _nft,
        // string memory _name,
        string memory _slug,
        string memory _description,
        string memory _animation_url,
        string memory _external_url,
        string memory _code
    ) NFTExtension(_nft) {
        name = IERC721Metadata(address(nft)).name();
        // slug = IERC721Metadata(address(nft)).symbol();
        slug = _slug;

        description = _description;
        external_url = _external_url;
        animation_url = _animation_url;

        code = _code;
    }

    function mint() external payable {
        nft.mintExternal{value: msg.value}(1, msg.sender, bytes32(0));

        uint256 mintedTokenId = IERC721A(address(nft)).totalSupply();

        gene[mintedTokenId] = keccak256(
            abi.encodePacked(
                name,
                code,
                block.difficulty,
                block.timestamp,
                mintedTokenId
            )
        );
    }

    function genom(uint256 id) public view returns (string memory) {
        bytes32 random = gene[id];
        // return hex string of gene
        return string(abi.encodePacked("0x", toHexString(random)));
    }

    // prettier-ignore
    function tokenURI(uint256 id) public view returns (string memory uri) {
        string memory _gene = genom(id); // id to gene;

        string memory image = string(
            abi.encodePacked(
                "https://media.artgene.xyz/",
                slug,
                "/",
                _gene,
                ".png"
            )
        );

        string memory animation_url_ = string(
            abi.encodePacked(
                animation_url, "?seed=", _gene
            )
        );

        // abi.encodePacked(
        //     "{",
        //         '"name": "', name, '",',
        //         '"image": "', image, '",',
        //         '"animation_url": "', animation_url_, '",',
        //         '"description": "', description, '",',
        //         '"external_url": "', external_url, '"',
        //     "}"
        // )

        string memory json = string(
            abi.encodePacked(
                "{",
                    '"name": "', name, '",',

                    '"image": "', image, '",',
                    '"animation_url": "', animation_url_, '",',

                    '"description": "', description, '",',
                    '"external_url": "', external_url, '"',
                "}"
            )
        );

        uri = string(abi.encodePacked("data:application/json,", json));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(bytes32 _bytes)
        internal
        pure
        returns (string memory)
    {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint8(_bytes[i] >> 4)];
            str[1 + i * 2] = alphabet[uint8(_bytes[i] & 0x0f)];
        }
        return string(str);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(IERC165, NFTExtension) returns (bool) {
        return
            interfaceId == type(INFTURIExtension).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
