# MerkleProof







*These functions deal with verification of Merkle Tree proofs. The proofs can be generated using the JavaScript library https://github.com/miguelmota/merkletreejs[merkletreejs]. Note: the hashing algorithm should be keccak256 and pair sorting should be enabled. See `test/utils/cryptography/MerkleProof.test.js` for some examples. WARNING: You should avoid using leaf values that are 64 bytes long prior to hashing, or use a hash function other than keccak256 for hashing leaves. This is because the concatenation of a sorted pair of internal nodes in the merkle tree could be reinterpreted as a leaf value.*



