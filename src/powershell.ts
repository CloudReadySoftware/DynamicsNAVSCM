import { ILogger } from './logging';
import * as PowerShellRunner from 'powershell';

const enum MessageLevel {
    Start,
    End,
    Output,
    Error        
}

export class Powershell {
    
    private startTime: Date; 
    private endTime: Date;
    private path: string;
    modules: string[];
    settings: Object;
    observers: ILogger[];

    constructor(path: string) {
        this.path = path;
    }

    getArrayParameter(array: string[]) {
        let result = null;
        if(array){
            let parameterString = array.join("','");
            result = `'${parameterString}'`;
        }
        return result;
    }

    private getModuleString() {
        let modulestring = this.getArrayParameter(this.modules);
        if(modulestring) {
            return `-Modules ${modulestring}`
        }
    }

    private addQuotes(parameter: string) {
        if(parameter.startsWith("'")){
            return parameter;
        }
        return `'${parameter}'`; 
    }

    private getParameterString() {
        let result = null;
        if(this.settings) {
            let settingsarray = [];
            let keys = Object.keys(this.settings);
            for(let i = 0;i < keys.length; i++) {
                let currentKey = keys[i];
                let parameterString = this.addQuotes(this.settings[currentKey]);
                settingsarray.push(`-${currentKey} ${parameterString}`);
            }
            result = settingsarray.join(' ');
        }
        return result;
    }

    private getScriptString() {
        let result = "$ErrorActionPreference = 'Stop'\n";
        let moduleString = this.getModuleString();
        let settingsString = this.getParameterString();
        result += `$DebugPreference = 'Continue'\n`;
        result += this.path;
        if(moduleString)
            result += ` ${moduleString}`
        if(settingsString)
            result += ` ${settingsString}`
        return result;
    }

    public invoke() {
        let command = this.getScriptString();
        this.runPowershell(command);
    }

    private runPowershell(command: string) {
        this.startTime = new Date();
        let ps = new PowerShellRunner(command);

        this.LogStart(command);

        ps.on(['error', 'error-output'], data => {
            this.LogError(data);
        });
        ps.on('output', data => {
            this.LogOutput(data);
        });
        ps.on("end", data => {
            this.endTime = new Date();
            this.LogEnd(data, this.endTime.valueOf() - this.startTime.valueOf());
        });
    }

    private FormatProcessOutput(data: string) {
        return data.split(/\n/);
    }

    private LogStart(command: string) {
        if(this.observers) {
            this.observers.forEach(observer => {
                observer.LogStart(command);
            });
        }
    }
    private LogEnd(data: string, duration: number) {
        if(this.observers) {
            this.observers.forEach(observer => {
                observer.LogEnd(data, duration);
            });
        }
    }
    private LogError(data: string) {
        if(this.observers) {
            let dataArray: string[] = this.FormatProcessOutput(data);
            this.observers.forEach(observer => {
                dataArray.forEach(line => {
                    observer.LogError(line);
                });
            });
        }
    }
    private LogOutput(data: string) {
        if(this.observers) {
            let dataArray: string[] = this.FormatProcessOutput(data); 
            this.observers.forEach(observer => {
                dataArray.forEach(line => {
                    observer.LogOutput(line);
                });
            });
        }
    }
}