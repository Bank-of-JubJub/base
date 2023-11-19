import * as fs from "fs";
import * as toml from "@iarna/toml";

export type TomlKeyValue = {
  key: string;
  value: TomlValue;
};

type Point = {
  x: string | bigint;
  y: string | bigint;
};

type TomlValue = string | number | Uint8Array | Point | number[];

export function createAndWriteToml(
  filePath: string,
  keyValues: Array<TomlKeyValue>
) {
  let data: any = {};
  keyValues.map((item) => {
    data[item.key] = item.value;
  });

  const tomlContent = toml.stringify(data);
  fs.writeFileSync(filePath, tomlContent);
}
