import { Args, Flags } from '@oclif/core'
import { BaseCommand } from '../base-command.js'
import { getContract } from 'viem'
import { abi as tokenAbi } from '../../../hardhat/artifacts/contracts/ERC20.sol/FunToken.json'
import { abi as bojAbi } from '../../../hardhat/artifacts/contracts/PrivateToken.sol/PrivateToken.json'
import { delay } from '../utils/utils.js'

export default class Deposit extends BaseCommand<typeof Deposit> {
  static description = 'deposit tokens in a bank of jubjub contract'

  static examples = [
    '',
  ]

  static flags = {
    // flag with a value (-n, --name=VALUE)
    tokenAddress: Flags.string({ char: 't' }),
    bojAddress: Flags.string({ char: 'b' })
  }

  static args = {
    amount: Args.string({ description: 'amount to deposit' }),
    to: Args.string({ description: 'Bank of jubjub account to send to' })
  }

  public async run(): Promise<void> {
    const { args, flags } = await this.parse(Deposit)

    let erc20 = await getContract({
      abi: tokenAbi,
      address: flags.tokenAddress as `0x${string}`,
      client: {
        public: this.publicClient,
        wallet: this.walletClient
      }
    });

    let privateToken = await getContract({
      abi: bojAbi,
      address: flags.bojAddress as `0x${string}`,
      client: {
        public: this.publicClient,
        wallet: this.walletClient
      }
    });

    await erc20.write.approve([flags.bojAddress, args.amount]);

    await delay(5000);

    const hash = await privateToken.write.deposit([
      BigInt(args.amount!),
      args.to,
      0,
    ]);

    await delay(5000);

    const receipt = await this.publicClient.getTransactionReceipt({ hash });
    console.log(receipt);
  }
}
