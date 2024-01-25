import { JsonMap } from "@iarna/toml";
export type TomlKeyValue = {
    key: string;
    value: TomlValue;
};
type Point = {
    x: string | bigint;
    y: string | bigint;
};
type TomlValue = string | number | Point | number[] | Point[];
export declare function createAndWriteToml(nargoPackage: string, inputs: JsonMap): void;
export {};
