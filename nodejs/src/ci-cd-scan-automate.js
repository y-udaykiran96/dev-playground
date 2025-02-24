const xlsx = require('xlsx');
const { execSync } = require('child_process');
const fs = require('fs');
const l = require('lodash')

// Load the Excel file
const filePath = __dirname + '/../input/ci-cd-scan-input.xlsx'; // Change this to your actual file
const outputFilePath = __dirname + '/../output/ci-cd-scan-output.xlsx';
const workbook = xlsx.readFile(filePath);
const sheetName = workbook.SheetNames[0]; // Read the first sheet
const worksheet = workbook.Sheets[sheetName];

async function main() {
    // Convert Excel data to JSON
    let data = xlsx.utils.sheet_to_json(worksheet);
    let output = []
    for (let row of data) {
        output.push(await scanImage(row))
    }
    const newWorksheet = xlsx.utils.json_to_sheet(output);
    workbook.Sheets[sheetName] = newWorksheet;

    // Write back to Excel file

    xlsx.writeFile(workbook, outputFilePath);

    console.log(`Updated Excel file saved as ${outputFilePath}`);

}

async function scanImage(row) {
    // Construct the Docker command using column names as flags

    const args = [
        l.isEmpty(row.host) ? '' : `--host "${row.host}"`,
        l.isEmpty(row.token) ? '' : `--token "${row.token}"`,
        l.isEmpty(row.local) || l.isEqual(row.local, 'no') ? '' : `--local`,
        l.isEmpty(row.registry) ? '' : `--registry "${row.registry}"`,
        l.isEmpty(row.register) || l.isEqual(row.register, 'no') ? '' : `--register`
    ]
    const dockerCommand = `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp ${row.scanner} scan ${row.image} ` + args.join(' ')

    // Execute the command and get the output
    const commandOutput = runDockerCommand(dockerCommand);

    // Update row with executed Docker command and output
    return {
        ...row,
        command: dockerCommand,
        'json-output': commandOutput,
    };
}



// Function to execute Docker command and get output
const runDockerCommand = (command) => {
    try {
        console.log(`Executing: ${command}`)
        return execSync(command, { encoding: 'utf8' }).trim();
    } catch (error) {
        console.log("Error: ", error)
        return `Error: ${error.message}`;
    }
};


main()