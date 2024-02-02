import { exec } from "child_process";
export async function runNargoProve(circuitPackage, tomlFile) {
    return new Promise((resolve, reject) => {
        exec(`nargo prove --package ${circuitPackage} -p ${tomlFile}`, (error, stdout, stderr) => {
            if (error) {
                reject(`exec error: ${error}`);
            }
            if (stderr) {
                reject(`stderr: ${stderr}`);
            }
            resolve(stdout);
        });
    });
}
