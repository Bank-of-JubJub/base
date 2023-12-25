import hre from "hardhat"
import { getContract } from "../utils/utils";
import { parseAbi } from "viem";

async function main() {
    const publicClient = await hre.viem.getPublicClient();

    const unwatch = publicClient.watchEvent({
        address: (await getContract("PrivateToken")).address,
        events: parseAbi([
            'event Deposit(address from, bytes32 to, uint256 amount, uint256 processFee)',
            'event Transfer(bytes32 indexed to, bytes32 indexed from, EncryptedAmount amount)'
        ]),
        onLogs: logs => console.log(logs)
    })

}



main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});