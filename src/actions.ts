import { Powershell } from './powershell';
import { Settings } from './settings';
import * as scripts from './scripts';
import * as modules from './modules';
import * as workspacefolder from './folders';
import { ConsoleLogger, OutputLogger } from './logging';
import { selectItem, ExportOption } from './exportselection'
import { inputNewVersionNumber } from './newversion';
import { createFolderIfNotExist, createGitIgnorefile } from './newenv';

let observers = [
    ConsoleLogger.getInstance(), 
    OutputLogger.getInstance()
    ];

export function copyDB() {
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.COPY_DB);
    ps.observers = observers;
    ps.modules = [
        'SQLPS',
        modules.COPY_DB
    ];
    ps.settings = {
        SourceDatabaseInstance: settings[Settings.REMOTEDBINSTANCE],
        SourceDatabaseName: settings[Settings.REMOTEDBNAME],
        CommonSQLLocation: settings[Settings.COMMONSQLLOCATION],
        DestinationDatabaseName: settings[Settings.SOLUTIONNAME]
    };
    ps.invoke();
}

export function exportNAV2GitOriginal() {
    let settings = Settings.GetAllSettings();
    selectItem(exportNAV2GitOriginalNoFilter, settings);
}

function exportNAV2GitOriginalNoFilter(settings: Object, key: string) {
    let ps = new Powershell(scripts.NAV2GIT);
    ps.observers = observers;
    ps.modules = [
        modules.COMMONFUNCTIONS,
        modules.EXPORT_OBJECTS,
        'SQLPS',
        settings[Settings.IDEMODULE],
        settings[Settings.MODELTOOLS]
    ];
    ps.settings = {
        DatabaseName: settings[Settings.SOLUTIONNAME],
        NAVIDE: settings[Settings.FINSQL],
        DestinationFolder: workspacefolder.ORIGINAL,
        NextVersionTag: settings[Settings.NEXTVERSIONNO],
        SolutionName: settings[Settings.SOLUTIONNAME],
        ExportOption: key
    };
    ps.invoke();
}

export function exportNAV2GitModified() {
    let settings = Settings.GetAllSettings();
    selectItem(exportNAV2GitModifiedWithFilter, settings);
}

function exportNAV2GitModifiedWithFilter(settings: Object, key: string) {
    let ps = new Powershell(scripts.NAV2GIT);
    ps.observers = observers;
    ps.modules = [
        modules.COMMONFUNCTIONS,
        modules.EXPORT_OBJECTS,
        modules.VERSION,
        'SQLPS',
        settings[Settings.IDEMODULE],
        settings[Settings.MODELTOOLS]
    ];
    ps.settings = {
        DatabaseName: settings[Settings.SOLUTIONNAME],
        NAVIDE: settings[Settings.FINSQL],
        DestinationFolder: workspacefolder.MODIFIED,
        NextVersionTag: settings[Settings.NEXTVERSIONNO],
        SolutionName: settings[Settings.SOLUTIONNAME],
        ExportOption: key
    };
    ps.invoke();
}

export function compileNAVObjects() {
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.COMPILE_OBJ);
    ps.observers = observers;
    ps.modules = [
        modules.COMPILE_OBJECTS,
        settings[Settings.IDEMODULE]
    ];
    ps.settings = {
        DatabaseName: settings[Settings.SOLUTIONNAME],
        NAVIDE: settings[Settings.FINSQL]
    }
    ps.invoke();
}

export function removeEnvironment() {
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.REMOVE_ENV);
    ps.observers = observers;
    ps.settings = {
        ServiceInstanceName: settings[Settings.SERVICENAME],
        BaseFolder: settings[Settings.BASEFOLDER]
    }
    ps.invoke();
}

export function newEnvironment() {
    console.log('hello world');
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.NEW_ENV);
    ps.observers = observers;
    ps.modules = [
        modules.COMMONFUNCTIONS,
        'SQLPS',
        settings[Settings.MANAGEMENTMODULE],
        modules.NEW_NAV
    ];
    ps.settings = {
        Zip: settings[Settings.ZIP],
        ServiceInstanceName:  settings[Settings.SOLUTIONNAME],
        NSTFolder: settings[Settings.NSTFOLDER],
        RTCFolder: settings[Settings.RTCFOLDER],
        Addinsfolder: workspacefolder.ADDIN,
        RTCAddinsFolder: settings[Settings.RTCADDINS],
        NSTAddinsFolder: settings[Settings.NSTADDINS],
        LicenseFile: settings[Settings.LICENSEFILE],
        DatabaseName: settings[Settings.SOLUTIONNAME],
        UIDOffset: settings[Settings.UIDOFFSET],
        NSTEXE: settings[Settings.NST]
    };
    ps.invoke();

}

export function startIDE() {
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.START_IDE);
    ps.observers = observers;
    ps.settings = {
        databasename: settings[Settings.SOLUTIONNAME],
        navide: settings[Settings.FINSQL]
    };
    ps.invoke();
}

export function versionObjects() {
    let settings = Settings.GetAllSettings();
    inputNewVersionNumber(settings)
}

export function startShell() {
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.START_SHELL);
    ps.observers = observers;
    let modulesToImport = [
        'SQLPS',
        settings[Settings.MANAGEMENTMODULE],
        settings[Settings.IDEMODULE],
        settings[Settings.MODELTOOLS]
    ]
    let variablesToDeclared = [
        Settings.FINSQL, settings[Settings.FINSQL],
        Settings.SERVICENAME, settings[Settings.SERVICENAME],
        Settings.RTC, settings[Settings.RTC],
        Settings.SOLUTIONNAME, settings[Settings.SOLUTIONNAME],
        Settings.BASEFOLDER, settings[Settings.BASEFOLDER],
        'repository', workspacefolder.WORKSPACE
    ];
    ps.settings = {
        Modules: ps.getArrayParameter(modulesToImport),
        Variables: ps.getArrayParameter(variablesToDeclared)
    };
    ps.invoke();
}

export function init_workspace() {
    let settings = Settings.GetAllSettings();
    createFolderIfNotExist(workspacefolder.ADDIN);
    createFolderIfNotExist(workspacefolder.ADDINRESOURCES);
    createFolderIfNotExist(workspacefolder.MODIFIED);
    createFolderIfNotExist(workspacefolder.ORIGINAL);
    createFolderIfNotExist(workspacefolder.DELTA);
    createFolderIfNotExist(workspacefolder.REPORTLAYOUTS);
    createFolderIfNotExist(workspacefolder.TEMP);
    createGitIgnorefile(workspacefolder.WORKSPACE);
    //CreateVSCodeSettingsFile();
}

export function importObjects() {
    let settings = Settings.GetAllSettings();
    let ps = new Powershell(scripts.GIT2NAV);
    ps.observers = observers;
    ps.modules = [
        modules.COMMONFUNCTIONS,
        settings[Settings.MODELTOOLS], 
        settings[Settings.IDEMODULE], 
        modules.IMPORT_OBJECTS
        ];
    ps.settings = { 
        ObjectsFolder: workspacefolder.MODIFIED,
        workspacefolder: workspacefolder.WORKSPACE,
        SolutionName: settings[Settings.SOLUTIONNAME],
        DatabaseName: settings[Settings.SOLUTIONNAME],
        LastImportGitHashFilepath: workspacefolder.LASTIMPORTEDGITHASH
    };
    ps.invoke();
}