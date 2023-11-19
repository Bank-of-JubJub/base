import { exec } from "child_process";

export function runNargoProve(circuitPackage: string, tomlFile: string) {
  exec(
    `nargo prove --package ${circuitPackage} -p ${tomlFile}`,
    (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        return;
      }
      console.log(`stdout: ${stdout}`);
      console.error(`stderr: ${stderr}`);
    }
  );
}
