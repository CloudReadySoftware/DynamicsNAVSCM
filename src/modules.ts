import { join } from 'path';
import { POWERSHELLPATH } from './scripts';

const MODULESPATH                   = join(POWERSHELLPATH, 'modules');
export const COMPILE_OBJECTS        = join(MODULESPATH, 'compile_objects.psm1');
export const COPY_DB                = join(MODULESPATH, 'copy_db.psm1');
export const EXPORT_OBJECTS         = join(MODULESPATH, 'export_objects.psm1');
export const IMPORT_OBJECTS         = join(MODULESPATH, 'import_objects.psm1');
export const NEW_NAV                = join(MODULESPATH, 'new_nav.psm1');
export const SERVICE_ADMINISTRATION = join(MODULESPATH, 'service_administration.psm1');
export const COMMON_DIALOGS         = join(MODULESPATH, 'commonDialogs.psm1');
export const VERSION                = join(MODULESPATH, 'version.psm1');
export const COMMONFUNCTIONS        = join(MODULESPATH, 'commonFunctions.psm1');