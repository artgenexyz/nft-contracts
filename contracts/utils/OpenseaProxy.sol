// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

address constant OPENSEA_CONDUIT = 0x1E0049783F008A0085193E00003D00cd54003c71;

// These contract definitions are used to create a reference to the OpenSea
// ProxyRegistry contract by using the registry's address (see isApprovedForAll).
interface OwnableDelegateProxy {

}

interface ProxyRegistry {
    function proxies(address) external view returns (OwnableDelegateProxy);
}
