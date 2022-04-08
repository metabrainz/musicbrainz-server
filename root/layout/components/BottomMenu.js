/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../context.mjs';
import {VARTIST_GID} from '../../static/scripts/common/constants.js';
import {capitalize} from '../../static/scripts/common/utility/strings.js';
import {returnToCurrentPage} from '../../utility/returnUri.js';

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

type LanguageLinkPropsT = {
  language: ServerLanguageT,
};

const LanguageLink = ({
  language,
}: LanguageLinkPropsT) => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <a
      href={
        '/set-language/' + encodeURIComponent(language.name) +
        '?' + returnToCurrentPage($c)
      }
    >
      {languageName(language, false)}
    </a>
  );
};

type LanguageMenuProps = {
  +currentBCP47Language: string,
  +serverLanguages: $ReadOnlyArray<ServerLanguageT>,
};

const LanguageMenu = ({
  currentBCP47Language,
  serverLanguages,
}: LanguageMenuProps) => {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <li className="language-selector" tabIndex="-1">
      <span className="menu-header">
        {languageName(
          serverLanguages.find(x => x.name === currentBCP47Language),
          true,
        )}
      </span>
      <ul>
        {serverLanguages.map(function (language, index) {
          let inner: React$MixedElement =
            <LanguageLink language={language} />;

          if (language.name === currentBCP47Language) {
            inner = <strong>{inner}</strong>;
          }

          return <li key={index}>{inner}</li>;
        })}
        <li>
          <a href={'/set-language/unset?' + returnToCurrentPage($c)}>
            {l('(reset language)')}
          </a>
        </li>
        <li className="separator">
          <a href="https://translations.metabrainz.org/projects/musicbrainz/">
            {l('Help translate')}
          </a>
        </li>
      </ul>
    </li>
  );
};

const AboutMenu = () => (
  <li className="about" tabIndex="-1">
    <span className="menu-header">
      {l('About us')}
      {'\xA0\u25BE'}
    </span>
    <ul>
      <li>
        <a href="/doc/About">{l('About MusicBrainz')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/sponsors">{l('Sponsors')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/team">{l('Team')}</a>
      </li>
      <li>
        <a href="https://www.redbubble.com/people/metabrainz/shop">{l('Shop')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/contact">{l('Contact us')}</a>
      </li>
      <li className="separator">
        <a href="/doc/About/Data_License">{l('Data licenses')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/social-contract">{l('Social contract')}</a>
      </li>
      <li>
        <a href="/doc/Code_of_Conduct">{l('Code of conduct')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/privacy">{l('Privacy policy')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/gdpr">{l('GDPR compliance')}</a>
      </li>
      <li>
        <a href="/doc/Data_Removal_Policy">{l('Data removal policy')}</a>
      </li>
      <li className="separator">
        <a href="/elections">{l('Auto-editor elections')}</a>
      </li>
      <li>
        <a href="/privileged">{l('Privileged user accounts')}</a>
      </li>
      <li>
        <a href="/statistics">{l('Statistics')}</a>
      </li>
      <li>
        <a href="/statistics/timeline">{l('Timeline graph')}</a>
      </li>
      <li>
        <a href="/history">{l('MusicBrainz history')}</a>
      </li>
    </ul>
  </li>
);

const ProductsMenu = () => (
  <li className="products" tabIndex="-1">
    <span className="menu-header">
      {l('Products')}
      {'\xA0\u25BE'}
    </span>
    <ul>
      <li>
        <a href="//picard.musicbrainz.org">{l('MusicBrainz Picard')}</a>
      </li>
      <li>
        <a href="/doc/AudioRanger">{l('AudioRanger')}</a>
      </li>
      <li>
        <a href="/doc/Mp3tag">{l('Mp3tag')}</a>
      </li>
      <li>
        <a href="/doc/Yate_Music_Tagger">{l('Yate Music Tagger')}</a>
      </li>
      <li className="separator">
        <a href="/doc/MusicBrainz_for_Android">
          {l('MusicBrainz for Android')}
        </a>
      </li>
      <li className="separator">
        <a href="/doc/MusicBrainz_Server">{l('MusicBrainz Server')}</a>
      </li>
      <li>
        <a href="/doc/MusicBrainz_Database">{l('MusicBrainz Database')}</a>
      </li>
      <li className="separator">
        <a href="/doc/Developer_Resources">{l('Developer resources')}</a>
      </li>
      <li>
        <a href="/doc/MusicBrainz_API">{l('MusicBrainz API')}</a>
      </li>
      <li>
        <a href="/doc/Live_Data_Feed">{l('Live Data Feed')}</a>
      </li>
    </ul>
  </li>
);

const SearchMenu = () => (
  <li className="search" tabIndex="-1">
    <span className="menu-header">
      {l('Search')}
      {'\xA0\u25BE'}
    </span>
    <ul>
      <li>
        <a href="/search">{l('Advanced search')}</a>
      </li>
      <li>
        <a href="/search/edits">{l('Edit search')}</a>
      </li>
      <li>
        <a href="/tags">{lp('Tag cloud', 'folksonomy')}</a>
      </li>
      <li>
        <a href="/cdstub/browse">{l('Top CD stubs')}</a>
      </li>
    </ul>
  </li>
);

const EditingMenu = () => (
  <li className="editing" tabIndex="-1">
    <span className="menu-header">
      {l('Editing')}
      {'\xA0\u25BE'}
    </span>
    <ul>
      <li>
        <a href="/artist/create">{lp('Add artist', 'interactive')}</a>
      </li>
      <li>
        <a href="/label/create">{lp('Add label', 'interactive')}</a>
      </li>
      <li>
        <a href="/release-group/create">
          {lp('Add release group', 'interactive')}
        </a>
      </li>
      <li>
        <a href="/release/add">{lp('Add release', 'interactive')}</a>
      </li>
      <li>
        <a href={'/release/add?artist=' + encodeURIComponent(VARTIST_GID)}>
          {lp('Add Various Artists release', 'interactive')}
        </a>
      </li>
      <li>
        <a href="/recording/create">
          {lp('Add standalone recording', 'interactive')}
        </a>
      </li>
      <li>
        <a href="/work/create">{lp('Add work', 'interactive')}</a>
      </li>
      <li>
        <a href="/place/create">{lp('Add place', 'interactive')}</a>
      </li>
      <li>
        <a href="/series/create">
          {lp('Add series', 'singular, interactive')}
        </a>
      </li>
      <li>
        <a href="/event/create">{lp('Add event', 'interactive')}</a>
      </li>
      <li className="separator">
        <a href="/vote">{l('Vote on edits')}</a>
      </li>
      <li>
        <a href="/reports">{l('Reports')}</a>
      </li>
    </ul>
  </li>
);

const DocumentationMenu = () => (
  <li className="documentation" tabIndex="-1">
    <span className="menu-header">
      {l('Documentation')}
      {'\xA0\u25BE'}
    </span>
    <ul>
      <li>
        <a href="/doc/Beginners_Guide">{l('Beginners guide')}</a>
      </li>
      <li>
        <a href="/doc/Style">{l('Style guidelines')}</a>
      </li>
      <li>
        <a href="/doc/How_To">{l('How tos')}</a>
      </li>
      <li>
        <a href="/doc/Frequently_Asked_Questions">{l('FAQs')}</a>
      </li>
      <li>
        <a href="/doc/MusicBrainz_Documentation">
          {l('Documentation index')}
        </a>
      </li>
      <li className="separator">
        <a href="/doc/Edit_Types">{lp('Edit types', 'noun')}</a>
      </li>
      <li>
        <a href="/relationships">{l('Relationship types')}</a>
      </li>
      <li>
        <a href="/admin/attributes">{l('Entity attributes')}</a>
      </li>
      <li>
        <a href="/instruments">{l('Instrument list')}</a>
      </li>
      <li>
        <a href="/genres">{l('Genre list')}</a>
      </li>
      <li className="separator">
        <a href="/doc/Development">{l('Development')}</a>
      </li>
    </ul>
  </li>
);

const BottomMenu = (): React$Element<'div'> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const serverLanguages = $c.stash.server_languages;
  return (
    <div className="bottom">
      <ul className="menu">
        <AboutMenu />
        <ProductsMenu />
        <SearchMenu />
        {$c.user ? <EditingMenu /> : null}
        <DocumentationMenu />
        {serverLanguages && serverLanguages.length > 1 ? (
          <LanguageMenu
            currentBCP47Language={$c.stash.current_language.replace('_', '-')}
            serverLanguages={serverLanguages}
          />
        ) : null}
      </ul>
    </div>
  );
};

export default BottomMenu;
