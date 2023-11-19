import { exec } from "child_process";

export async function runNargoProve(circuitPackage: string, tomlFile: string) {
  return new Promise((resolve, reject) => {
    exec(
      `nargo prove --package ${circuitPackage} -p ${tomlFile}`,
      (error, stdout, stderr) => {
        if (error) {
          reject(`exec error: ${error}`);
          return;
        }
        if (stderr) {
          reject(`stderr: ${stderr}`);
        }
        if (stdout) {
          console.log(`stdout: ${stdout}`);
          resolve(stdout);
        }
      }
    );
  });
}
