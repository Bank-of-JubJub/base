import { Args, Flags } from '@oclif/core'
import { BaseCommand } from '../base-command.js'
import { getContract } from 'viem'
import { abi as tokenAbi } from '../../../hardhat/artifacts/contracts/ERC20.sol/FunToken.json'
import { delay } from 'boj-utils'

export default class Approve extends BaseCommand<typeof Approve> {
    static description = 'approve an erc20'

    static examples = [
        '',
    ]

    static flags = {
        // flag with a value (-n, --name=VALUE)
        tokenAddress: Flags.string({ char: 't' }),
        bojAddress: Flags.string({ char: 'b' })
    }

    static args = {
        amount: Args.string({ description: 'amount to approve' }),
        spender: Args.string({ description: 'the spender account (should be the BoJ contract address)' })
    }

    public async run(): Promise<void> {
        const { args, flags } = await this.parse(Approve)

        const erc20Address = flags.tokenAddress ? flags.tokenAddress : this.userConfig.erc20Address
        const bojContractAddress = flags.bojAddress ? flags.bojAddress : this.userConfig.bojContractAddress

        let erc20 = await getContract({
            abi: tokenAbi,
            address: erc20Address as `0x${string}`,
            client: {
                public: this.publicClient,
                wallet: this.walletClient
            }
        });

        const hash = await erc20.write.approve([bojContractAddress, args.amount]);

        await delay(5000);

        const receipt = await this.publicClient.getTransactionReceipt({ hash });
        console.log(receipt);
    }
}
