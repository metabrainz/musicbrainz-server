// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

function getCurrentScript() {
  let currentScript = document.currentScript;

  // IE11. Likely doesn't work with async or defer.
  if (!currentScript) {
    const scripts = document.getElementsByTagName('script');
    currentScript = scripts[scripts.length - 1];
  }

  return currentScript;
}

function getScriptArgs() {
  const args = getCurrentScript().getAttribute('data-args');
  if (args) {
    return JSON.parse(args);
  }
  return {};
}

module.exports = getScriptArgs;
