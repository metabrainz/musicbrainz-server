/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */


import * as React from 'react';

import {SanitizedCatalystContext} from '../../../context.mjs';
import {returnToCurrentPage} from '../../../utility/returnUri.js';
import languageIcon from '../../images/homepage/language-icon.svg';
import {l} from '../common/i18n.js';
import {capitalize} from '../common/utility/strings.js';

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
        aria-expanded="false"
        className={
          `dropdown-toggle align-items-center
          dropdown-toggle-no-caret`
        }
        data-bs-toggle="dropdown"
        href="#"
        role="button"
        title={l('Language')}
      >
        <img alt="Language" height={40} src={languageIcon} width={40} />
      </a>
      <ul className="dropdown-menu">
        {serverLanguages?.map((language) => {
          const isSelected = language.name === currentLanguage;
          return (
            <li key={language.name}>
              <a
                className={`dropdown-item ${isSelected ? 'active' : ''}`}
                href={`/set-language/${encodeURIComponent(
                  language.name,
                )}?${returnToCurrentPage($c)}`}
                title={languageName(language, isSelected)}
              >
                {languageName(language, isSelected)}
              </a>
            </li>
          );
        })}
        <li>
          <a
            className="dropdown-item"
            href={`/set-language/unset?${returnToCurrentPage($c)}`}
            title={l('reset language')}
          >
            {l('(reset language)')}
          </a>
        </li>
        <li className="dropdown-divider" />
        <li>
          <a
            className="dropdown-item"
            href="https://translations.metabrainz.org/projects/musicbrainz/"
            title={l('Help translate')}
          >
            {l('Help translate')}
          </a>
        </li>
      </ul>
    </>
  );
}

export default LanguageSelector;
