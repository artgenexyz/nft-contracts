function addExtension(address extension) public onlyOwner {
    require(!extensionExists[extension], "M:EXTENSION_ALREADY_ADDED");
    require(extension != address(this), "M:EXTENSION_CAN_NOT_BE_THIS");
    require(extension != address(0), "M:EXTENSION_CAN_NOT_BE_ZERO");
    require(
        INFTExtension(extension).extensionType() != bytes32(0),
        "M:EXTENSION_IS_NOT_NFT_EXTENSION"
    );
    uint256 id = _extensions.add(extension);
    extensionExists[extension] = true;
    emit ExtensionAdded(extension, id);
}