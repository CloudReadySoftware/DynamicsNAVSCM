import { ExtensionContext, commands } from 'vscode';
import * as customActions from './actions';

export function activate(context: ExtensionContext) {
    console.log('Extension "vscode-dynamics-nav" activated');
    let commandList = [
        commands.registerCommand('dynamicsnav.compile_obj', customActions.compileNAVObjects),
        commands.registerCommand('dynamicsnav.copy_db', customActions.copyDB),
        commands.registerCommand('dynamicsnav.git2nav', customActions.importObjects),
        commands.registerCommand('dynamicsnav.nav2git', customActions.pickFilesExport),
        commands.registerCommand('dynamicsnav.new_env', customActions.newEnvironment),
        commands.registerCommand('dynamicsnav.new_remote', null),
        commands.registerCommand('dynamicsnav.remove_env', customActions.removeEnvironment),
        commands.registerCommand('dynamicsnav.remove_remote', null),
        commands.registerCommand('dynamicsnav.start_ide', customActions.startIDE),
        commands.registerCommand('dynamicsnav.start_remote', null),
        commands.registerCommand('dynamicsnav.start_rtc', null),
        commands.registerCommand('dynamicsnav.start_shell', customActions.startShell),
        commands.registerCommand('dynamicsnav.initialize_workspace', customActions.init_workspace),
        commands.registerCommand('dynamicsnav.cleannavdatabase', null)
    ];
    context.subscriptions.concat(commandList);
}

export function deactivate() {
}
