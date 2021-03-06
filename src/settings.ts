import { WorkspaceConfiguration, workspace } from 'vscode';
import { join } from 'path';
import Helpers from './shared/helpers'

export class Settings {
    static readonly ZIP = 'zip';
    static readonly ORIGINALOBJECTS = 'originalobjects';
    static readonly DATABASENAME = 'databasename';
    static readonly REMOTEDBNAME = 'remotedbname';
    static readonly SOLUTIONVERSION = 'solutionVersion';
    static readonly ORIGNALPATH = 'originalpath';
    static readonly MODIFIEDPATH = 'modifiedpath';
    static readonly TARGETPATH = 'targetpath';
    static readonly RESULTPATH = 'resultpath';
    static readonly VERSIONS = 'versions';
    static readonly INSTALLPATH = 'installpath';
    static readonly REMOTEDBINSTANCE = 'remotedbinstance';
    static readonly LICENSEFILE = 'licensefile';
    static readonly COMMONSQLLOCATION = 'commonsqllocation';
    static readonly UIDOFFSET = 'uidoffset';
    static readonly BASEFOLDER = 'basefolder';
    static readonly RTCFOLDER = 'rtcfolder';
    static readonly NSTFOLDER = 'nstfolder';
    static readonly FINSQL = 'finsql';
    static readonly RTC = 'rtc';
    static readonly NST = 'nst';
    static readonly RTCADDINS = 'rtcaddins';
    static readonly NSTADDINS = 'nstaddins';
    static readonly MODELTOOLS = 'modeltools';
    static readonly IDEMODULE = 'idemodule';
    static readonly MANAGEMENTMODULE = 'managementmodule';
    static readonly NEXTVERSIONNO = 'nextversionno';
    static readonly SERVICENAME = 'servicename';
    static readonly DEFAULTNAVBUILDFOLDER = 'defaultNAVBuildFolder';
    static readonly NSTPATH = 'nstpath';
    static readonly RTCPATH = 'rtcpath';
    static readonly FILTERS = 'filters'
    static readonly DATEMODIFICATION = 'datemodification'
    private static WORKSPACEKEY: string = 'dynamicsnav';

    private static config: WorkspaceConfiguration;

    private static readonly FINSQLEXE = 'finsql.exe';
    private static readonly RTCEXE = 'Microsoft.Dynamics.Nav.Client.exe';
    private static readonly NSTEXE = 'Microsoft.Dynamics.Nav.Server.exe';
    private static readonly RTCFOLDERNAME = 'RTC';
    private static readonly NSTFOLDERNAME = 'NST';
    private static readonly MODELTOOLSDLL = 'Microsoft.Dynamics.Nav.Model.Tools.dll';
    private static readonly IDEPSM = 'Microsoft.Dynamics.Nav.Ide.psm1';
    private static readonly MANAGEMENTDLL = 'Microsoft.Dynamics.Nav.Management.dll';
    private static readonly ADDIN = 'Add-ins';
    private static readonly NSTSERVICENAME = 'MicrosoftDynamicsNavServer$'
    private static readonly WORKSPACESETTINGS = [Settings.DATABASENAME];

    private static getSetting(key: string)
    {
        if(!this.config.has(key))
        {
            return null;
        }
        if(!(this.WORKSPACESETTINGS.includes(key)))
        {
            return this.config.get(key);
        };
        let inspection = this.config.inspect(key);
        let workspaceValue = inspection.workspaceValue;
        if(!workspaceValue)
        {
            Helpers.throwError(`Workspace key '${key}' needed in your setup.`);
        }
        return workspaceValue;
    }
    private static getSettings(){
        let result = {};
        let nstpath = this.getSetting(this.NSTPATH);
        let rtcpath = this.getSetting(this.RTCPATH);

        result[this.ZIP] = this.getSetting(this.ZIP);
        result[this.ORIGINALOBJECTS] = this.getSetting(this.ORIGINALOBJECTS);
        result[this.DATABASENAME] = this.getSetting(this.DATABASENAME);
        result[this.REMOTEDBNAME] = this.getSetting(this.REMOTEDBNAME);
        result[this.SOLUTIONVERSION] = this.getSetting(this.SOLUTIONVERSION);
        result[this.ORIGNALPATH] = this.getSetting(this.ORIGNALPATH);
        result[this.MODIFIEDPATH] = this.getSetting(this.MODIFIEDPATH);
        result[this.TARGETPATH] = this.getSetting(this.TARGETPATH);
        result[this.RESULTPATH] = this.getSetting(this.RESULTPATH);
        result[this.VERSIONS] = this.getSetting(this.VERSIONS);
        result[this.INSTALLPATH] = this.getSetting(this.INSTALLPATH);
        result[this.REMOTEDBINSTANCE] = this.getSetting(this.REMOTEDBINSTANCE);
        result[this.LICENSEFILE] = this.getSetting(this.LICENSEFILE);
        result[this.COMMONSQLLOCATION] = this.getSetting(this.COMMONSQLLOCATION);
        result[this.UIDOFFSET] = this.getSetting(this.UIDOFFSET);
        result[this.BASEFOLDER] = this.joinPaths([result[this.INSTALLPATH], result[this.DATABASENAME]]);
        result[this.RTCFOLDER] = rtcpath ? rtcpath : this.joinPaths([result[this.BASEFOLDER], this.RTCFOLDERNAME]);
        result[this.NSTFOLDER] = nstpath ? nstpath : this.joinPaths([result[this.BASEFOLDER], this.NSTFOLDERNAME]);
        result[this.FINSQL] = this.joinPaths([result[this.RTCFOLDER], this.FINSQLEXE]);
        result[this.RTC] = this.joinPaths([result[this.RTCFOLDER], this.RTCEXE]);
        result[this.NST] = this.joinPaths([result[this.NSTFOLDER], this.NSTEXE]);
        result[this.RTCADDINS] = this.joinPaths([result[this.RTCFOLDER], this.ADDIN, result[this.DATABASENAME]]);
        result[this.NSTADDINS] = this.joinPaths([result[this.NSTFOLDER], this.ADDIN, result[this.DATABASENAME]]);
        result[this.MODELTOOLS] = this.joinPaths([result[this.RTCFOLDER], this.MODELTOOLSDLL]);
        result[this.IDEMODULE] = this.joinPaths([result[this.RTCFOLDER], this.IDEPSM]);
        result[this.MANAGEMENTMODULE] = this.joinPaths([result[this.NSTFOLDER], this.MANAGEMENTDLL]);
        result[this.NEXTVERSIONNO] = `${result[this.DATABASENAME]}_DEV`;
        result[this.SERVICENAME] = `${this.NSTSERVICENAME}${result[this.DATABASENAME]}`;
        result[this.DEFAULTNAVBUILDFOLDER] = this.getSetting(this.DEFAULTNAVBUILDFOLDER);
        result[this.FILTERS] = this.getSetting(this.FILTERS);
        result[this.DATEMODIFICATION] = this.getSetting(this.DATEMODIFICATION);
            
        return result;
    }

    private static joinPaths(paths: string[]) {
        for(let i = 0; i < paths.length; i++)
        {
            if(!paths[i] || paths[i] === "")
                return null;
        }
        return join.apply(null, paths);
    }

    public static GetAllSettings() {
        this.config = workspace.getConfiguration(this.WORKSPACEKEY);
        return this.getSettings();
    }
}