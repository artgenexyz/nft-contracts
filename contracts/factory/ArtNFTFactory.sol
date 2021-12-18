// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

// TODO: support Foundation format
contract ArtNFT is ERC721Upgradeable, OwnableUpgradeable {

    string private baseURI;

    function initialize(
        string memory _uri,
        string memory _name, string memory _symbol
    ) public initializer {
        __ERC721_init(_name, _symbol);
        // __ERC721Burnable_init();
        // __ReentrancyGuard_init();
        __Ownable_init();

        baseURI = _uri;
    }

    // This constructor ensures that this contract can only be used as a master copy
    // Marking constructor as initializer makes sure that real initializer cannot be called
    // Thus, as the owner of the contract is 0x0, no one can do anything with the contract
    // on the other hand, it's impossible to call this function in proxy,
    // so the real initializer is the only initializer
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mint(address _to, uint256 _tokenId) public onlyOwner {
        _mint(_to, _tokenId);
    }

    // TODO: mint via extension, add extension etc
}

contract ArtNFTFactory is Ownable {

    address public immutable proxyImplementation;

    event NFTCreated(address deployedAddress);

    constructor() {
        proxyImplementation = address(new ERC721Upgradeable());
    }

    function createNFT(
        // uint256 _startPrice,
        // uint256 _maxSupply,
        // uint256 _nReserved,
        // uint256 _maxTokensPerMint,
        string memory _uri,
        string memory _name, string memory _symbol
    ) external payable {
        require(msg.value >= cost(), "Not enough payment");

        address clone = Clones.clone(proxyImplementation);

        ArtNFT(clone).initialize(
            // _startPrice,
            // _maxSupply,
            // _nReserved,
            // _maxTokensPerMint,
            _uri,
            _name, _symbol
        );

        ArtNFT(clone).transferOwnership(msg.sender);

        emit NFTCreated(clone);

        Address.sendValue(payable(msg.sender), msg.value - cost());
    }

    function cost() public view returns (uint256) {

        // we aim to be 10 times cheaper than deploying your own smart-contract
        uint approxDeployCost = 5_000_000 * block.basefee;

        // we ignore priority_fee

        // uint gasCost = 334_044; // TODO: record estimation
        // uint gasCost = 314_132;

        // so we charge 500_000 gas on top of 330_000 gas you pay for the deploy

        return approxDeployCost / 10;
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;

        Address.sendValue(payable(msg.sender), balance);
    }

}
