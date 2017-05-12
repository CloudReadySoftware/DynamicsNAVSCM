import { QuickPickItem, QuickPickOptions, window } from 'vscode';
import { Settings } from './settings';

export class ExportOption implements QuickPickItem
{
    description: string;
    detail?: string;
    label: string;
    key: string;
}

function getObjects(solutionName: string, nextVersionNo: string) 
{
    let modified: ExportOption = {
        description: 'Export the solution objects.',
        label: 'Solution',
        detail: `2 exports: Version List=@*${solutionName}*|@*${nextVersionNo}*, Modified=True`,
        key: 'solution'
    }
    let all: ExportOption = {
        description: 'Export all the objects.',
        detail: 'No filters. Slow, 2 min +',
        label: 'All',
        key: 'all'
    }
    return [modified, all];
}

export function selectItem(cb: Function, settings: Object) 
{
    let items = getObjects(settings[Settings.SOLUTIONNAME], settings[Settings.NEXTVERSIONNO]);
    let options: QuickPickOptions = {
        matchOnDescription: false,
        placeHolder: "What objects do you want to export?"
    }
    let quickpick = window.showQuickPick<ExportOption>(items, options);
    quickpick.then((item: ExportOption) => {
        if(item && cb){
            cb(settings, item.key);
        }
    });
}