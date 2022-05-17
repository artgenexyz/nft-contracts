// Adapted from https://github.com/0xleung/hardhat-etherscan/blob/b3d905ddc268ca106682ec2195862f3bd45c5180/src/solc/version.ts

const COMPILERS_LIST_URL = "https://solc-bin.ethereum.org/bin/list.json";

// Non-exhaustive interface for the official compiler list.
export interface CompilersList {
    releases: {
        [version: string]: string;
    };
    latestRelease: string;
}

// TODO: this could be retrieved from the hardhat config instead.
export async function getLongVersion(shortVersion: string): Promise<string> {
    const versions = await getVersions();
    const fullVersion = versions.releases[shortVersion];

    if (fullVersion === undefined || fullVersion === "") {
        throw new Error(
            "Given solc version doesn't exist"
        );
    }

    return fullVersion.replace(/(soljson-)(.*)(.js)/, "$2");
}

export async function getVersions(): Promise<CompilersList> {
    try {
        const { default: fetch } = await import("node-fetch");
        // It would be better to query an etherscan API to get this list but there's no such API yet.
        const response = await fetch(COMPILERS_LIST_URL);

        if (!response.ok) {
            const responseText = await response.text();
            throw new Error(
                `HTTP response is not ok. Status code: ${response.status} Response text: ${responseText}`
            );
        }

        return await response.json();
    } catch (error: any) {
        throw new Error(
            `Failed to obtain list of solc versions. Reason: ${error.message}`
        );
    }
}
