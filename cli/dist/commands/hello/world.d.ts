import { Command } from '@oclif/core';
export default class World extends Command {
    static args: {};
    static description: string;
    static examples: string[];
    static flags: {};
    run(): Promise<void>;
}
