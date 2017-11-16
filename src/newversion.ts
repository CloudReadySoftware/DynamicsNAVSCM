import { InputBoxOptions, window } from 'vscode';
import { Settings } from './settings';
import { ConsoleLogger, OutputLogger } from './logging';

let consoleLogger = ConsoleLogger.getInstance();
let outputLogger = OutputLogger.getInstance();

function incrementVersionNumber(solutionname: string, currentversionNumber: string) {
    if(currentversionNumber === ""){
        currentversionNumber = "1";
    }
    solutionname = solutionname.toUpperCase();
    let result = currentversionNumber.match(/(\d+)\.?(\d*)\.?(\d*)\.?(\d*)/);
    let versionArray = [
        result[1],
        result[2],
        result[3],
        result[4]
    ];
    let versionNumberArray: number[] = [];
    for(let i = 0;i < 4;i++) {
        let integervalue = parseInt(versionArray[i]);
        if(isNaN(integervalue)){
            integervalue = 0;
        }
        versionNumberArray[i] = integervalue;
    }
    versionNumberArray[3] += 1;
    let versionnumber = versionNumberArray.join('.');
    return `${solutionname}${versionnumber}`;
}

function validateVersionNumber(versiontext: string, solutionname: string) {
    solutionname = solutionname.toUpperCase();
    let success = true;
    let errormsg = '';
    let match = versiontext.match(/^([a-zA-Z]+)\d+\.?\d*\.?\d*\.?\d*/);
    if(!match){
        errormsg = "Version not matching normal versioning.";
        success = false;
    }
    if(match[0] !== versiontext) {
        errormsg = "Contains illegal characters.";
        success = false;
    }
    if(match[1] !== solutionname) {
        errormsg = `Solutionname ${solutionname}`;
        success = false;
    }    
    outputLogger.LogError(errormsg);
    return success;
}

export function inputNewVersionNumber(settings: Object, cb?: Function) {
    let solutionName = settings[Settings.DATABASENAME];
    let lastversionNumber = settings[Settings.SOLUTIONVERSION];
    let versionNumber = incrementVersionNumber(solutionName, lastversionNumber);
    let options: InputBoxOptions = {
        password: false,
        placeHolder: 'Format: XXX11(.11.2.1), Fx: EVFOR11.2.3.4',
        prompt: 'The next versionnumber',
        value: versionNumber
    }
    consoleLogger.LogOutput(`Suggested versionnumber: '${versionNumber}'`);
    let inputBox = window.showInputBox(options);
    inputBox.then((newversionNumber: string) => {
        if(newversionNumber === "") {
            newversionNumber = incrementVersionNumber(solutionName, lastversionNumber);
        }
        if(!validateVersionNumber(newversionNumber, solutionName)) {
            consoleLogger.LogError(`'${newversionNumber}' didn't validate.`);
            return;
        }
        let newVersionOutput = `'${newversionNumber}' is the new version.`;
        consoleLogger.LogOutput(newVersionOutput);
        outputLogger.LogOutput(newVersionOutput);
        if(cb) {
            cb(settings, newversionNumber);
        }
    });
}