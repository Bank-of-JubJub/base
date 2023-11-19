import * as fs from "fs";
import * as toml from "@iarna/toml";
import { type } from "os";

export type TomlKeyValue = {
  key: string;
  value: TomlValue;
};

type Point = {
  x: string | bigint;
  y: string | bigint;
};

type TomlValue = string | number | Uint8Array | Point;

export function createAndWriteToml(
  filePath: string,
  keyValues: Array<TomlKeyValue>
) {
  // each toml field index starts with the variable name

  let data: any;
  keyValues.map((item) => {
    // if (Object.getOwnPropertyNames(item.value).includes('x')) {
    data[item.key] = item.value;
    // } else {
    // }
  });

  const tomlContent = toml.stringify(data);
  fs.writeFileSync(filePath, tomlContent);
}
