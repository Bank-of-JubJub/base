import * as fs from "fs";
import * as toml from "@iarna/toml";
import * as path from "path";
export function createAndWriteToml(nargoPackage, inputs) {
    const tomlContent = toml.stringify(inputs);
    const directoryPath = path.join(__dirname, "circuits", nargoPackage);
    const filePath = path.join(directoryPath, "Test.toml");
    if (!fs.existsSync(directoryPath)) {
        fs.mkdirSync(directoryPath, { recursive: true });
    }
    fs.writeFileSync(filePath, tomlContent);
}
