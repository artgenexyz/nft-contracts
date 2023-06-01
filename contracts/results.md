# Results


## DemoCollection

### Take 1.1

The deployment is estimated to cost 0.0476711065 ETH
The contract was deployed.
	The tx hash is 0x12f8311a0e10213754ddc6f70aef0c941172dfd12a719c15801f6e8cdc6d50f0.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 190684426			|
| gasUsed		| 121707112			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.030426778 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xEc8acBeB5553B4Ee517B4544759918F1047cd9bE	|
| --------------------- | ----------------------------- |


### Take 1.2

The deployment is estimated to cost 0.00246092675 ETH
The contract was deployed.
	The tx hash is 0x97b5eca2a345dba8426f33147b070a4221f4fe01cb7373e382db27167bf9d09c.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 9843707			|
| gasUsed		| 4379895			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00109497375 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xeCd90698A4E7D30Bf9D46E82FEb35b3985819E10	|
| --------------------- | ----------------------------- |

### Take 1.3

The deployment is estimated to cost 0.001814663 ETH
The contract was deployed.
	The tx hash is 0x3285ba7ccf19e5cb47fe3a2b8b333263dd5f0aceb6a5126e0d036e0703216eba.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 7258652			|
| gasUsed		| 3982514			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.0009956285 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xf64C325E630B06092A3d7d21A984c402a099b7c2	|
| --------------------- | ----------------------------- |


### Take 1.4

Deployer address: 0xe5cc6F5bbB3Eee408A1C022D235e6903656f2509
The deployment is estimated to cost 0.00170940525 ETH
The contract was deployed.
	The tx hash is **0x1bb8ceadd0f1aed5a2d2c3cfe3bea3fff2d25f7fb080efe065b339b3c259396c**.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 6925608			|
| gasUsed		| 3931318			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.0009828295 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x1092F8c47A5a4D3595B83D0985a818Ac7e5E42ed	|
| --------------------- | ----------------------------- |



### Take 2.1 (With different name and args)

```solidity
contract DemoCollectionNameName is Artgene721Base {
    constructor()
        Artgene721Base(
            "Generative Endless NFT version 2",
            "GEN",
            10_000,
            1,
            false,
            ...
        )
        {}
}
```

The contract was deployed.
	The tx hash is 0xcd0a162ae37c656c2cd572a059b82bcab59dd96bd3a209fbea9bd37d477096f9.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 84065955			|
| gasUsed		| 63534833			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.01588370825 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x09905264FaDF0277AA2F5752a5567e645d5E8593	|
| --------------------- | ----------------------------- |


### Take 2.2
The deployment is estimated to cost 0.001322396 ETH
The contract was deployed.
	The tx hash is 0xf8cc6cf80bd854c6225c793ac8742088fb2083a124d75be1988cc8ede061f2a3.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 5289584			|
| gasUsed		| 1891429			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00047285725 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xb0F496C003B42018181100Da1739402dF1388CF1	|
| --------------------- | ----------------------------- |


### Take 3.1 (Deploy same name without recompile but change costructor args)

```solidity
contract DemoCollectionNameName is Artgene721Base {
    constructor()
        Artgene721Base(
            "Generative Endless NFT version 3",
            "GEN",
            20_000,
            1,
            false,
            "ipfs://xxxxxxxxxxxxxxxx",
            ...
        )
        {}
}
```

Deployer address: 0xe5cc6F5bbB3Eee408A1C022D235e6903656f2509
The deployment is estimated to cost 0.0011480225 ETH
The contract was deployed.
	The tx hash is 0x1aa45ae5bb8b3fd0164a8927f8a0c62bb73d893eaa25bb6abd87a97b736d0d07.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 4498779			|
| gasUsed		| 1536308			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.000384077 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x61E4759BA8F38C502Ae6a9a6Aec130e00ABefE2f	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollectionNameName was deployed to 0x61E4759BA8F38C502Ae6a9a6Aec130e00ABefE2f

===
**Verification failed**

### Take 3.2 (Recompile without cleaning)

The deployment is estimated to cost 0.01447782375 ETH
The contract was deployed.
	The tx hash is 0x39ee011bcf0435bdd7075851d2ed8c28521a076f14fc2fe35b3ce9fe46e71f43.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 57911295			|
| gasUsed		| 36668685			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00916717125 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x984854Ffbccc121FA5a291195c79e63637559900	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollectionNameName was deployed to 0x984854Ffbccc121FA5a291195c79e63637559900
See the contract code on zkScan: https://goerli.explorer.zksync.io/address/0x984854Ff



### Take 3.3 (re-deploy again)


The deployment is estimated to cost 0.00093306775 ETH
The contract was deployed.
	The tx hash is 0x001cc87a5a0ef56d0c430f8e4b199a1266b1d70e0bee9764351d54ccf77a30c9.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 3732271			|
| gasUsed		| 1264063			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00031601575 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x717e7F4153D27D27fb2AE944706107c7B3969672	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x


### Take 4.1 (change name without changing arguments from last run)

```solidity
contract DemoCollection is Artgene721Base {
    constructor()
        Artgene721Base(
            "Generative Endless NFT version 3",
            "GEN",
            20_000,
            1,
            false,
            "ipfs://xxxxxxxxxxxxxxxx",
                ...
        )
        {}
}
```


The deployment is estimated to cost 0.01421948625 ETH
The contract was deployed.
	The tx hash is 0x3e5201e3017872b44e240238a35b183b01c266a51d500fb0a4241029c6a15f14.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 56877945			|
| gasUsed		| 36359015			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00908975375 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x5BDbAD956669788d1a808688D716bb7452C23AA8	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollection was deployed to 0x5BDbAD956669788d1a808688D716bb7452C23AA8



### Take 4.2

The contract was deployed.
	The tx hash is 0x536b8b102a0ac4f8252ac42ace8a8acd95a0e6abd5e4deb11ecf7d527f1c923c.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 3685719			|
| gasUsed		| 1192254			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.0002980635 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x7f71420Dd5Bd59b83957D043Ad08E2F42Eb31e2a	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollection was deployed to 0x7f71420Dd5Bd59b83957D043Ad08E2F42Eb31e2a


### Take 5.1 (revert back to a state that have already been deployed)

```solidity
contract DemoCollection is Artgene721Base {
    constructor()
        Artgene721Base(
            "Generative Endless NFT",
            "GEN",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION,
            1,
            false,
            "https://metadata.artgene.xyz/api/g/goerli/midline/",
                ...
        )
        {}
}
```

The deployment is estimated to cost 0.0010416435 ETH
The contract was deployed.
	The tx hash is 0x0e651ba13648b0923807a64265d1f8293904b4741a02915c0a49c6dc1945d9d1.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 4189530			|
| gasUsed		| 1296492			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.000324123 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x8574ceC2e0085e9fE59f49EB671A1F2a4ba4663e	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollection was deployed to 0x8574ceC2e0085e9fE59f49EB671A1F2a4ba4663e



### Take 6.1 (change name but keep code the same)

Deployer address: 0xe5cc6F5bbB3Eee408A1C022D235e6903656f2509
The deployment is estimated to cost 0.02039594975 ETH
The contract was deployed.
	The tx hash is 0x1c34eef365c4d39b8dd9e26b53ea8488d9d833c270ac9d4b8558fd6b7ffb3ec7.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 81583799			|
| gasUsed		| 60615932			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.015153983 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0x1b50Eb3BD672E75e92D3f9eB36683471aab7Ef91	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollection1 was deployed to 0x1b50Eb3BD672E75e92D3f9eB36683471aab7Ef91


## DemoCollectionShallow


### Take One

The contract was deployed.
	The tx hash is 0x0d4feffffc1518a53748d581b772a4b8c4e66e4af28d5a3619a4579c129597a8.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 5635733			|
| gasUsed		| 2028333			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00050708325 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xD621D77cE5408C5Dba0Dc43758E6238ACcC7388C	|
| --------------------- | ----------------------------- |



### Take Two

The contract was deployed.
	The tx hash is 0xa91cc44cec7e106fc424a0ecd35552801ba377dd3015fca8693ec3edfaddf302.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 5302762			|
| gasUsed		| 1846662			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.0004616655 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xd823b7557Dc31988190183816C2721beF3A38524	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollectionShallow was deployed to 0xd823b7557Dc31988190183816C2721beF3A38524


### Take 3 (after recompile but code not changed)

The contract was deployed.
	The tx hash is 0xf94e0a537c232b736f8f9553e28671166c4603d518fd09d3659c63e1bd10563b.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 4287686			|
| gasUsed		| 1403789			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00035094725 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xeb089f3a9107BdB3Cd81De7919F013F275292089	|
| --------------------- | ----------------------------- |


### Take 2.1 (change arguments)
The deployment is estimated to cost 0.002805274 ETH
The contract was deployed.
	The tx hash is 0x34ac6f82c7af4d32963c9d9b54dd934ecc2d963ce7a1edce4265fcad9a2e76e5.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 11221096			|
| gasUsed		| 5777104			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.001444276 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xE71490727F3D146c988D7419FABa8a92902C06e0	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollectionShallow was deployed to 0xE71490727F3D146c988D7419FABa8a92902C06e0



### Take 2.2

The deployment is estimated to cost 0.0010692085 ETH
The contract was deployed.
	The tx hash is 0x31663fd3925760f6cf1f994edd7661461d830207f74548cdabb77eb7a1cb827f.
	Waiting for confirmation...
| Key			| Value			|
| --------------------- | ----------------------------- |
| gasPerPubdata		| 50000				|
| gasLimit		| 4276834			|
| gasUsed		| 1379201			|
| maxPriorityFeePerGas	| 250000000			|
| maxFeePerGas		| 250000000			|
| totalCost		| 0.00034480025 ETH		|
| --------------------- | ----------------------------- |
| contractAddress	| 0xFaBe0966349040B02837F29936E757742B8EDba2	|
| --------------------- | ----------------------------- |
Deployed with constructor args: 0x
DemoCollectionShallow was deployed to 0xFaBe0966349040B02837F29936E757742B8EDba2



