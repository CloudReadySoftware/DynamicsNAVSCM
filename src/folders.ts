import { workspace } from 'vscode';
import { join } from 'path';


export const WORKSPACE           = workspace.rootPath;
export const ADDIN               = WORKSPACE ? join(WORKSPACE, 'addin/') : null;
export const REPORTLAYOUTS       = WORKSPACE ? join(WORKSPACE, 'reportlayouts/') : null;
export const ADDINRESOURCES      = WORKSPACE ? join(WORKSPACE, 'addinresources/') : null;
export const SOURCE              = WORKSPACE ? join(WORKSPACE, 'src/') : null;
export const LASTIMPORTEDGITHASH = WORKSPACE ? join(WORKSPACE, 'lastimportedgithash') : null;
export const TEMP                = WORKSPACE ? join(WORKSPACE, 'temp/') : null;