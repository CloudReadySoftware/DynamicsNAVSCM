import { OutputChannel, window } from 'vscode';
import * as formatduration from 'format-duration';
import * as timestamp from 'time-stamp';

export interface ILogger {
    LogOutput(data: string);
    LogError(data: string);
    LogStart(data: string);
    LogEnd(data: string, duration: number);
}

export class OutputLogger implements ILogger {
    private static instance: OutputLogger;
    private channel: OutputChannel = null;
    private static readonly channelName: string = 'NAV developer extension'; 
    
    static getInstance() {
        if(!this.instance) {
            this.instance = new OutputLogger();
        }
        return this.instance;
    }

    private constructor() {
        this.channel = window.createOutputChannel(OutputLogger.channelName);
    }
    LogOutput(data: string) {
        this.channel.appendLine(data);
    }
    LogError(data: string) {
        this.channel.appendLine(data);
    }
    LogStart(data: string) {
        this.channel.appendLine('Started function.');
    }
    LogEnd(data: string, duration: number) {
        let text = data + "\nDuration: " + formatduration(duration);
        this.channel.appendLine(text);
    }
}

export class ConsoleLogger implements ILogger {
    private static instance: ConsoleLogger;

    static getInstance() {
        if(!this.instance) {
            this.instance = new ConsoleLogger();
        }
        return this.instance;
    }
    
    LogOutput(data: string) {
        console.log(appendTimestamp(data));
    }
    LogError(data: string) {
        console.error(appendTimestamp(data));
    }
    LogStart(command: string) {
        console.log(appendTimestamp('Started function.\n\n' + command + '\n'));
    }
    LogEnd(data: string, duration: number) {
        let text = data + "\nDuration: " + formatduration(duration) + '\n' + '-'.repeat(30);
        console.log(appendTimestamp(data));
    }
}

function appendTimestamp(line: string) {
    return '[' + timestamp('HH:mm:ss') + '] ' + line;
}