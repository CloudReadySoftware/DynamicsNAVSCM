import * as fs from 'fs';
import * as path from 'path';

export function createFolderIfNotExist(Path: string){
    console.log(Path);
    if(!fs.existsSync(Path)) {
        fs.mkdirSync(Path);
    }
}

export function createGitIgnorefile(Workspacefolder: string) {
    let gitignorefile = path.join(Workspacefolder, '.gitignore');
    if(fs.existsSync(gitignorefile)){
        return
    }
    var gitignorecontent = `lastimportedgithash\ntemp`;
    fs.writeFile(gitignorefile, gitignorecontent);
}