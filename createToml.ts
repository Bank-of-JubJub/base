import * as fs from "fs";
import * as toml from "@iarna/toml";
import * as path from "path";
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

export function createAndWriteToml(
  nargoPackage: string,
  inputs: JsonMap
) {
  const tomlContent = toml.stringify(inputs);

  const directoryPath = path.join(__dirname, "circuits", nargoPackage);
  const filePath = path.join(directoryPath, "Test.toml");
  if (!fs.existsSync(directoryPath)) {
    fs.mkdirSync(directoryPath, { recursive: true });
  }
  fs.writeFileSync(filePath, tomlContent);
}
