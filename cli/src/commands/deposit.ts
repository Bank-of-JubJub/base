import { Args, Command, Flags } from '@oclif/core'
import { BaseCommand } from '../base-command.js'
import * as viem from "viem"
import { readDeploymentData } from '../utils/readDeploymentData.js'
// TODO: import ABIs for token and private token

export default class Deposit extends BaseCommand<typeof Deposit> {
  static description = 'deposit tokens in a bank of jubjub contract'

  static examples = [
    '',
  ]

  static flags = {
    // flag with a value (-n, --name=VALUE)
    // amount: Flags.string({ char: 'a', description: 'amount to deposit' }),
  }

  static args = {
    amount: Args.string({ description: 'amount to deposit' }),
  }

  public async run(): Promise<void> {
    const { args, flags } = await this.parse(Deposit)

    const { data: erc20data } = readDeploymentData("FunToken");
    const { data: privateTokenData } = readDeploymentData("PrivateToken");


    // TODO: update getContract to take abis, addresses and clients

    let erc20 = await viem.getContract(
      "FunToken",
      erc20data[this.network].address
    );
    let privateToken = await viem.getContract(
      "PrivateToken",
      privateTokenData[this.network].address
    );

    await erc20.write.approve([privateTokenData[network].address, params.amount], { account: sender.account });

    await delay(5000);

    const hash = await privateToken.write.deposit([
      BigInt(params.amount),
      params.to,
      0,
    ], {
      account: sender.account
    });

    await delay(5000);

    const receipt = await publicClient.getTransactionReceipt({ hash });
    console.log(receipt);
  }
}
