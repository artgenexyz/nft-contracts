// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// These contract definitions are used to create a reference to the OpenSea
// ProxyRegistry contract by using the registry's address (see isApprovedForAll).
interface OwnableDelegateProxy {

}

interface ProxyRegistry {
    function proxies(address) external view returns (OwnableDelegateProxy);
}

library SupportsOpensea {

    // Use like this:

    // if (isOpenSeaProxyActive && SupportsOpensea.isApprovedForAll(owner, operator)) {
    //     return true;
    // }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        // Get a reference to OpenSea's proxy registry contract by instantiating
        // the contract using the already existing address.
        ProxyRegistry proxyRegistry = ProxyRegistry(0xa5409ec958C83C3f309868babACA7c86DCB077c1);

        return address(proxyRegistry.proxies(owner)) == operator;
    }
}
