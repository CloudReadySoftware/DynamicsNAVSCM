import { window } from 'vscode';

export default class Helpers
{
  public static throwError(error: string) {
    window.showErrorMessage(error);
  }
  public static showInformation(message: string) {
    window.showInformationMessage(message);
  }
  
}