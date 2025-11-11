/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */


import * as React from "react";
import languageIcon from '../../images/homepage/language-icon.svg';
import { SanitizedCatalystContext } from '../../../context.mjs';
import { returnToCurrentPage } from '../../../utility/returnUri.js';
import { capitalize } from '../common/utility/strings.js';

function languageName(
  language: ?ServerLanguageT,
  selected: boolean,
) {
  if (!language) {
    return '';
  }

  const {
    id,
    native_language: nativeLanguage,
    native_territory: nativeTerritory,
  } = language;

  let text = `[${id}]`;

  if (nativeLanguage) {
    text = capitalize(nativeLanguage);

    if (nativeTerritory) {
      text += ' (' + capitalize(nativeTerritory) + ')';
    }
  }

  if (selected) {
    text += ' \u25be';
  }

  return text;
}

component LanguageSelector() {
  const $c = React.useContext(SanitizedCatalystContext);
  const serverLanguages = $c.stash.server_languages;
  const currentLanguage = $c.stash.current_language.replace('_', '-');

  return (
    <>
      <a
        className="dropdown-toggle align-items-center dropdown-toggle-no-caret"
        href="#"
        role="button"
        data-bs-toggle="dropdown"
        aria-expanded="false"
      >
        <img src={languageIcon} alt="Language" width={40} height={40} />
      </a>
      <ul className="dropdown-menu">
        {serverLanguages?.map((language) => {
          const isSelected = language.name === currentLanguage;
          return (
            <li key={language.name}>
              <a
                href={`/set-language/${encodeURIComponent(language.name)}?${returnToCurrentPage($c)}`}
                className={`dropdown-item ${isSelected ? 'active' : ''}`}
              >
                {languageName(language, isSelected)}
              </a>
            </li>
          );
        })}
        <li>
          <a href={`/set-language/unset?${returnToCurrentPage($c)}`} className="dropdown-item">{l('(reset language)')}</a>
        </li>
        <li className="dropdown-divider" />
        <li>
          <a href="https://translations.metabrainz.org/projects/musicbrainz/" className="dropdown-item">{l('Help translate')}</a>
        </li>
      </ul>
    </>
  )
}

export default LanguageSelector;
