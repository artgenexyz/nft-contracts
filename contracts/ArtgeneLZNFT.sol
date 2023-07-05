// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";

import "./Artgene721Base.sol";

// import "../lib/solidity-examples/contracts/token/onft/ONFT721Core.sol";
// import "../lib/solidity-examples/contracts/token/onft/extension/ONFT721A.sol";

contract ArtgeneLZNFT is Artgene721Base, NonblockingLzApp {
    address l1Address;
    uint16 dstChainId = 10121;

    constructor(
        address _layerZeroEndpoint
    )
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
        NonblockingLzApp(_layerZeroEndpoint)
    {
        // // init crosschain
        // bytes memory _path = abi.encodePacked(address(this), l1Address);

        // NonblockingLzApp(address(this)).setTrustedRemote(dstChainId, _path);
    }

    function withdrawViaLZ(uint256 _tokenId, address _l1Receiver) external {
        require(ownerOf(_tokenId) == msg.sender, "not owner");

        _burn(_tokenId);

        // send message using LayerZero

        bytes memory message = abi.encodePacked(_l1Receiver, _tokenId);

        // TODO: not finished

        bytes memory destination = abi.encodePacked(address(this), l1Address);

        ILayerZeroEndpoint(lzEndpoint).send(
            dstChainId, // zksync testnet
            destination,
            message,
            payable(msg.sender),
            address(0),
            ""
        );
    }

    // function _debitFrom(
    //     address _from,
    //     uint16 _dstChainId,
    //     bytes memory _toAddress,
    //     uint _tokenId
    // ) internal virtual override {
    //     _burn(_tokenId);

    //     emit Debited(_from, _dstChainId, _toAddress, _tokenId); // fixed
    // }

    // function _creditTo(
    //     uint16 _srcChainId,
    //     address _toAddress,
    //     uint _tokenId
    // ) internal virtual override {
    //     _mint(_toAddress, _tokenId);
    //     emit Credited(_srcChainId, _toAddress, _tokenId);
    // }

    // event Credited(uint16 srcChainId, address toAddress, uint tokenId);
    // event Debited(
    //     address from,
    //     uint16 dstChainId,
    //     bytes toAddress,
    //     uint tokenId
    // );

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal virtual override {

        (address _l1Receiver, uint256 _tokenId) = abi.decode(
            _payload,
            (address, uint256)
        );

        // mint token
        _mint(_l1Receiver, _tokenId);
    }
}
