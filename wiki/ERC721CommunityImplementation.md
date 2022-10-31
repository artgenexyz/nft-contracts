# ERC721CommunityImplementation









## Methods

### DEVELOPER

```solidity
function DEVELOPER() external pure returns (string _url)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _url | string | undefined |

### DEVELOPER_ADDRESS

```solidity
function DEVELOPER_ADDRESS() external pure returns (address payable _dev)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _dev | address payable | undefined |

### PROVENANCE_HASH

```solidity
function PROVENANCE_HASH() external view returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### addExtension

```solidity
function addExtension(address _extension) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _extension | address | undefined |

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```



*Gives permission to `to` to transfer `tokenId` token to another account. The approval is cleared when the token is transferred. Only a single account can be approved at a time, so approving the zero address clears previous approvals. Requirements: - The caller must own the token or be an approved operator. - `tokenId` must exist. Emits an {Approval} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| tokenId | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```



*Returns the number of tokens in `owner`&#39;s account.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### claim

```solidity
function claim(uint256 nTokens, address to) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |
| to | address | undefined |

### contractURI

```solidity
function contractURI() external view returns (string uri)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| uri | string | undefined |

### data

```solidity
function data(uint256) external view returns (bytes32)
```



*Additional data for each token that needs to be stored and accessed on-chain*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### extensions

```solidity
function extensions(uint256) external view returns (contract INFTExtension)
```



*List of connected extensions*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract INFTExtension | undefined |

### extensionsLength

```solidity
function extensionsLength() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### forceWithdrawBuildship

```solidity
function forceWithdrawBuildship() external nonpayable
```






### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```



*Returns the account approved for `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getPayoutReceiver

```solidity
function getPayoutReceiver() external view returns (address payable receiver)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| receiver | address payable | undefined |

### getRoyaltyReceiver

```solidity
function getRoyaltyReceiver() external view returns (address payable receiver)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| receiver | address payable | undefined |

### initialize

```solidity
function initialize(string _name, string _symbol, uint256 _maxSupply, uint256 _nReserved, bool _startAtOne, string _uri, MintConfig _config) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _name | string | undefined |
| _symbol | string | undefined |
| _maxSupply | uint256 | undefined |
| _nReserved | uint256 | undefined |
| _startAtOne | bool | undefined |
| _uri | string | undefined |
| _config | MintConfig | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```



*Override isApprovedForAll to allowlist user&#39;s OpenSea proxy accounts to enable gas-less listings. Taken from CryptoCoven: https://etherscan.io/address/0x5180db8f5c931aae63c74266b211f580155ecac8#code*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| operator | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### isExtensionAdded

```solidity
function isExtensionAdded(address _extension) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _extension | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### isPayoutChangeLocked

```solidity
function isPayoutChangeLocked() external view returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### lockPayoutReceiver

```solidity
function lockPayoutReceiver() external nonpayable
```






### maxPerMint

```solidity
function maxPerMint() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### maxPerWallet

```solidity
function maxPerWallet() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### maxSupply

```solidity
function maxSupply() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### mint

```solidity
function mint(uint256 nTokens) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |

### mintExternal

```solidity
function mintExternal(uint256 nTokens, address to, bytes32 extraData) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nTokens | uint256 | undefined |
| to | address | undefined |
| extraData | bytes32 | undefined |

### mintedBy

```solidity
function mintedBy(address) external view returns (uint256)
```



*Storing how many tokens each address has minted in public sale*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### name

```solidity
function name() external view returns (string)
```



*Returns the token collection name.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```



*Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### payoutReceiver

```solidity
function payoutReceiver() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### price

```solidity
function price() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### reduceMaxSupply

```solidity
function reduceMaxSupply(uint256 _maxSupply) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _maxSupply | uint256 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### reserved

```solidity
function reserved() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### revokeExtension

```solidity
function revokeExtension(address _extension) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _extension | address | undefined |

### royaltyFee

```solidity
function royaltyFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### royaltyInfo

```solidity
function royaltyInfo(uint256, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |
| salePrice | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |
| royaltyAmount | uint256 | undefined |

### royaltyReceiver

```solidity
function royaltyReceiver() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*Equivalent to `safeTransferFrom(from, to, tokenId, &#39;&#39;)`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) external nonpayable
```



*Safely transfers `tokenId` token from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |
| _data | bytes | undefined |

### saleStarted

```solidity
function saleStarted() external view returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*Approve or remove `operator` as an operator for the caller. Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller. Requirements: - The `operator` cannot be the caller. Emits an {ApprovalForAll} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### setBaseURI

```solidity
function setBaseURI(string uri) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| uri | string | undefined |

### setContractURI

```solidity
function setContractURI(string uri) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| uri | string | undefined |

### setExtensionTokenURI

```solidity
function setExtensionTokenURI(address extension) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extension | address | undefined |

### setIsOpenSeaProxyActive

```solidity
function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _isOpenSeaProxyActive | bool | undefined |

### setPayoutReceiver

```solidity
function setPayoutReceiver(address _receiver) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _receiver | address | undefined |

### setPostfixURI

```solidity
function setPostfixURI(string postfix) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| postfix | string | undefined |

### setPrice

```solidity
function setPrice(uint256 _price) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _price | uint256 | undefined |

### setProvenanceHash

```solidity
function setProvenanceHash(string provenanceHash) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| provenanceHash | string | undefined |

### setRoyaltyFee

```solidity
function setRoyaltyFee(uint256 _royaltyFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _royaltyFee | uint256 | undefined |

### setRoyaltyReceiver

```solidity
function setRoyaltyReceiver(address _receiver) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _receiver | address | undefined |

### startSale

```solidity
function startSale() external nonpayable
```






### startTimestamp

```solidity
function startTimestamp() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### startTokenId

```solidity
function startTokenId() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### stopSale

```solidity
function stopSale() external nonpayable
```






### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified) to learn more about how these ids are created. This function call must use less than 30000 gas.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### symbol

```solidity
function symbol() external view returns (string)
```



*Returns the token collection symbol.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```



*Returns the Uniform Resource Identifier (URI) for `tokenId` token.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*Returns the total number of tokens in existence. Burned tokens will reduce the count. To get the total number of tokens minted, please see {_totalMinted}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*Transfers `tokenId` from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### updateMaxPerMint

```solidity
function updateMaxPerMint(uint256 _maxPerMint) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _maxPerMint | uint256 | undefined |

### updateMaxPerWallet

```solidity
function updateMaxPerWallet(uint256 _maxPerWallet) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _maxPerWallet | uint256 | undefined |

### updateStartTimestamp

```solidity
function updateStartTimestamp(uint256 _startTimestamp) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _startTimestamp | uint256 | undefined |

### uriExtension

```solidity
function uriExtension() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### withdraw

```solidity
function withdraw() external nonpayable
```






### withdrawToken

```solidity
function withdrawToken(contract IERC20 token) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| token | contract IERC20 | undefined |



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| approved `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### ConsecutiveTransfer

```solidity
event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fromTokenId `indexed` | uint256 | undefined |
| toTokenId  | uint256 | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |

### ExtensionAdded

```solidity
event ExtensionAdded(address indexed extensionAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extensionAddress `indexed` | address | undefined |

### ExtensionRevoked

```solidity
event ExtensionRevoked(address indexed extensionAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extensionAddress `indexed` | address | undefined |

### ExtensionURIAdded

```solidity
event ExtensionURIAdded(address indexed extensionAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extensionAddress `indexed` | address | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |



## Errors

### ApprovalCallerNotOwnerNorApproved

```solidity
error ApprovalCallerNotOwnerNorApproved()
```

The caller must own the token or be an approved operator.




### ApprovalQueryForNonexistentToken

```solidity
error ApprovalQueryForNonexistentToken()
```

The token does not exist.




### ApproveToCaller

```solidity
error ApproveToCaller()
```

The caller cannot approve to their own address.




### BalanceQueryForZeroAddress

```solidity
error BalanceQueryForZeroAddress()
```

Cannot query the balance for the zero address.




### MintERC2309QuantityExceedsLimit

```solidity
error MintERC2309QuantityExceedsLimit()
```

The `quantity` minted with ERC2309 exceeds the safety limit.




### MintToZeroAddress

```solidity
error MintToZeroAddress()
```

Cannot mint to the zero address.




### MintZeroQuantity

```solidity
error MintZeroQuantity()
```

The quantity of tokens minted must be more than zero.




### OwnerQueryForNonexistentToken

```solidity
error OwnerQueryForNonexistentToken()
```

The token does not exist.




### OwnershipNotInitializedForExtraData

```solidity
error OwnershipNotInitializedForExtraData()
```

The `extraData` cannot be set on an unintialized ownership slot.




### TransferCallerNotOwnerNorApproved

```solidity
error TransferCallerNotOwnerNorApproved()
```

The caller must own the token or be an approved operator.




### TransferFromIncorrectOwner

```solidity
error TransferFromIncorrectOwner()
```

The token must be owned by `from`.




### TransferToNonERC721ReceiverImplementer

```solidity
error TransferToNonERC721ReceiverImplementer()
```

Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.




### TransferToZeroAddress

```solidity
error TransferToZeroAddress()
```

Cannot transfer to the zero address.




### URIQueryForNonexistentToken

```solidity
error URIQueryForNonexistentToken()
```

The token does not exist.





