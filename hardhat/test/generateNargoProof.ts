import { exec } from "child_process";

export async function runNargoProve(circuitPackage: string, tomlFile: string) {
  // turn this into a promise that resolves when complete

  exec(
    `nargo prove --package ${circuitPackage} -p ${tomlFile}`,
    (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        return;
      }
      if (stdout) {
        console.log(`stdout: ${stdout}`);
      }
      if (stderr) {
        console.error(`stderr: ${stderr}`);
      }
    }
  );
}
