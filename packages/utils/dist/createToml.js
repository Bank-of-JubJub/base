import * as fs from "fs";
import * as toml from "@iarna/toml";
import * as path from "path";
import { fileURLToPath } from 'url';
import { dirname } from 'path';
// Get the current file's directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
export function createAndWriteToml(nargoPackage, inputs) {
    const tomlContent = toml.stringify(inputs);
    // go to root
    const directoryPath = path.join(__dirname, "../../..", "circuits", nargoPackage);
    const filePath = path.join(directoryPath, "Test.toml");
    if (!fs.existsSync(directoryPath)) {
        fs.mkdirSync(directoryPath, { recursive: true });
    }
    fs.writeFileSync(filePath, tomlContent);
}
