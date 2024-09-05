/*
 * @flow
 * Copyright (C) 2009 Oliver Charles
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as constants from './constants.js';
import linkedEntities from './linkedEntities.mjs';

// Namespaces
const MB: {[namespace: string]: {...}, ...} = {
  // Classes, common controls used throughout MusicBrainz
  Control: {},

  // Exposes internal data structures for userscripts.
  linkedEntities,
  relationshipEditor: {},

  // Utility functions
  utility: {},

  // Hold translated text strings
  text: {},

  // Hold constants for knockout templates that depend on globals.
  constants,
};

// $FlowIgnore[cannot-write]
globalThis.MB = MB;

export default MB;
