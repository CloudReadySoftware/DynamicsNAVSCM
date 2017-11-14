import { QuickPickItem, QuickPickOptions, window } from 'vscode';
import { Settings } from './settings';

export class ExportOption implements QuickPickItem
{
    description: string;
    detail?: string;
    label: string;
    key: string;
}

function getObjects() 
{
    let modified: ExportOption = {
        description: 'Export using custom fields',
        label: 'Custom filters',
        detail: `Export using the filters set in the setting "dynamicsnav.filters"`,
        key: "filters"
    }
    let all: ExportOption = {
        description: 'Export all the compiled objects.',
        detail: 'No filters. Slow, 2 min +',
        label: 'All',
        key: "all"
    }
    return [modified, all];
}

export function selectItem(cb: Function) 
{
    let items = getObjects();
    let options: QuickPickOptions = {
        matchOnDescription: false,
        placeHolder: "What objects do you want to export?"
    }
    let quickpick = window.showQuickPick<ExportOption>(items, options);
    quickpick.then((item: ExportOption) => {
        if(item && cb){
            let filters :boolean = item.key === "filters";
            cb(filters);
        }
    });
}

function getExportFilters(key: string, currentVersionNumber: string, nextVersionNumber: string)
{
    switch(key)
    {
        case "all":
            return "Compiled=1";
        case "solution":
            return [`Version List=@*${currentVersionNumber}*|@*${nextVersionNumber}*;Compiled=1`, `Modified=1;Compiled=1`]
        default:
            return "";
    }
}