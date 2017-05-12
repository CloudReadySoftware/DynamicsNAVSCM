Issue 1:
Rename "objects" folder to "modified"

Issue 2: 
Create a "Delta" folder for delta between "original" and "modified"

Issue 3: 
I split the command NAV_Git in 2. One for the Original and one for the Modified. Also renamed it to NAV2Git. What I am missing it to figure out how to create an extra parameter for the Original folder and export to this one. Let's discuss what is needed.

Issue 4:
Added suggested Icon file. Not yet used. To be agreed on and discussed.

Issue 5:
updategitdelta.ps1 was added but the code needs the correct parameters. These needs to be added.

Issue 6:
updategitmodified.ps1 was added but the code needs the correct parameters. These nees to be added.

Issue 7:
Folder.ts Added "Original", "modified" and "delta", but we should get rid of "objects"

Issue 8:
All users of the repository has to use the same "language for non-Unicode programs"

Issue 9:
No way to clean database of modifed objects (Think clean objects).

Issue 10:
Import currently only works for commited changes to the repo. Should this be changed?

Issue 11:
If there are no `lastimportedgithash`-file in the workspace. What should then be imported? Solution? All objects?

Issue 12:
Changed RTC to Windows Client as it is officially called.
Also added Web, Tablet & Phone Client, but we still need the code behind this. Right now they all open the Windows Client.