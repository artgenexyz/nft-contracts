// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import "solady/src/utils/Base64.sol";

import "./ArtgeneCodeStorage.sol";
import "./ArtgeneScript.sol";

abstract contract ScriptyOnchainArt is ArtgeneCodeStorage {
    IScriptyBuilder public immutable scriptyBuilder;
    address public immutable scriptyStorage;
    address public immutable ethfsFileStorage;

    string private constant ART_SCRIPT_NAME = "art-script.js.gz";

    constructor(
        address _nft,
        address _artgeneScriptAddress,
        address _ethfsFileStorageAddress,
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress
    ) ArtgeneCodeStorage(_nft, _artgeneScriptAddress) {
        ethfsFileStorage = _ethfsFileStorageAddress;
        scriptyStorage = _scriptyStorageAddress;
        scriptyBuilder = IScriptyBuilder(_scriptyBuilderAddress);
    }

    /* (minified, gunzipped, hex-encoded) */
    /// @dev (**required**) This is the main p5.js script that will be injected into the HTML
    function _getArtScript() internal pure virtual returns (bytes memory);

    /**
     * @dev Returns token metadata
     */
    function tokenURI(uint256) public pure override returns (string memory) {
        // Not used, metadata is generated off-chain
        return "";
    }

    /**
     * @dev Returns the html file for the token
     */
    function render(
        uint256,
        bytes memory
    ) public pure override returns (string memory) {
        // Not used, dna is generated off-chain
        return "";
    }

    /**
     * @dev Returns the html string for the token
     * @param tokenId Token id
     * @param dna Token DNA – provide offchain to see generated HTML
     */
    function tokenHTML(
        uint256 tokenId,
        bytes32 dna,
        bytes memory
    ) public view override returns (string memory) {
        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](5);

        requests[0].name = "p5-v1.5.0.min.js.gz";
        requests[0].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        requests[0].contractAddress = ethfsFileStorage;

        requests[1].name = "injected";
        requests[1].wrapType = 0; // <script>[SCRIPT]</script>
        requests[1].scriptContent = Artgene_js(script).getInjectScript(
            tokenId,
            dna
        );

        requests[2].name = "artgene.js.gz";
        requests[2].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        requests[2].scriptContent = Artgene_js(script).getBase64();

        requests[3].name = "art-script.js.gz";
        requests[3].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        requests[3].scriptContent = bytes(Base64.encode(_getArtScript()));

        requests[4].name = "gunzipScripts-0.0.1.js";
        requests[4].wrapType = 1; // <script src="data:text/javascript;base64,[script]"></script>
        requests[4].contractAddress = ethfsFileStorage;

        uint256 bufferSize = scriptyBuilder.getBufferSizeForHTMLWrapped(
            requests
        );

        bytes memory htmlFile = scriptyBuilder.getHTMLWrapped(
            requests,
            bufferSize
        );

        return string(htmlFile);
    }
}
