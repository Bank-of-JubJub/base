import * as fs from "fs";
import * as toml from "@iarna/toml";
import * as path from "path";

export type TomlKeyValue = {
  key: string;
  value: TomlValue;
};

type Point = {
  x: string | bigint;
  y: string | bigint;
};

type TomlValue = string | number | Point | number[];

export function createAndWriteToml(
  nargoPackage: string,
  keyValues: Array<TomlKeyValue>
) {
  let data: any = {};
  keyValues.map((item) => {
    data[item.key] = item.value;
  });

  const tomlContent = toml.stringify(data);

  const directoryPath = path.join(__dirname, "circuits", nargoPackage);
  const filePath = path.join(directoryPath, "Test.toml");
  if (!fs.existsSync(directoryPath)) {
    fs.mkdirSync(directoryPath, { recursive: true });
  }
  fs.writeFileSync(filePath, tomlContent);
}
