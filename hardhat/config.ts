import { createPublicClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { hardhat } from "viem/chains";

// JSON-RPC Account
// hardhat acct 1
export const [account] = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

export const publicClient = createPublicClient({
  chain: hardhat,
  transport: http(),
});
