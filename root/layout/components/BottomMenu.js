/*
 * @flow strict-local
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context';
import {VARTIST_GID} from '../../static/scripts/common/constants';
import {capitalize} from '../../static/scripts/common/utility/strings';
import {returnToCurrentPage} from '../../utility/returnUri';

function languageName(language, selected) {
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

const LanguageLink = ({$c, language}) => (
  <a
    href={
      '/set-language/' + encodeURIComponent(language.name) +
      '?' + returnToCurrentPage($c)
    }
  >
    {languageName(language, false)}
  </a>
);

type LanguageMenuProps = {
  +$c: CatalystContextT,
  +currentBCP47Language: string,
  +serverLanguages: $ReadOnlyArray<ServerLanguageT>,
};

const LanguageMenu = ({
  $c,
  currentBCP47Language,
  serverLanguages,
}: LanguageMenuProps) => (
  <li className="language-selector" tabIndex="-1">
    <span className="menu-header">
      {languageName(
        serverLanguages.find(x => x.name === currentBCP47Language),
        true,
      )}
    </span>
    <ul>
      {serverLanguages.map(function (language, index) {
        let inner = <LanguageLink $c={$c} language={language} />;

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
        <a href="https://www.transifex.com/musicbrainz/musicbrainz/">
          {l('Help Translate')}
        </a>
      </li>
    </ul>
  </li>
);

const AboutMenu = () => (
  <li className="about" tabIndex="-1">
    <span className="menu-header">
      {l('About Us')}
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
        <a href="https://metabrainz.org/contact">{l('Contact Us')}</a>
      </li>
      <li className="separator">
        <a href="/doc/About/Data_License">{l('Data Licenses')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/social-contract">{l('Social Contract')}</a>
      </li>
      <li>
        <a href="/doc/Code_of_Conduct">{l('Code of Conduct')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/privacy">{l('Privacy Policy')}</a>
      </li>
      <li>
        <a href="https://metabrainz.org/gdpr">{l('GDPR Compliance')}</a>
      </li>
      <li>
        <a href="/doc/Data_Removal_Policy">{l('Data Removal Policy')}</a>
      </li>
      <li className="separator">
        <a href="/elections">{l('Auto-editor Elections')}</a>
      </li>
      <li>
        <a href="/privileged">{l('Privileged User Accounts')}</a>
      </li>
      <li>
        <a href="/statistics">{l('Statistics')}</a>
      </li>
      <li>
        <a href="/statistics/timeline">{l('Timeline Graph')}</a>
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
        <a href="/doc/Developer_Resources">{l('Developer Resources')}</a>
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
        <a href="/search">{l('Advanced Search (entities)')}</a>
      </li>
      <li>
        <a href="/search/edits">{l('Advanced Search (edits)')}</a>
      </li>
      <li>
        <a href="/tags">{l('Tags')}</a>
      </li>
      <li>
        <a href="/cdstub/browse">{l('Top CD Stubs')}</a>
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
        <a href="/artist/create">{lp('Add Artist', 'button/menu')}</a>
      </li>
      <li>
        <a href="/label/create">{lp('Add Label', 'button/menu')}</a>
      </li>
      <li>
        <a href="/release-group/create">
          {lp('Add Release Group', 'button/menu')}
        </a>
      </li>
      <li>
        <a href="/release/add">{lp('Add Release', 'button/menu')}</a>
      </li>
      <li>
        <a href={'/release/add?artist=' + encodeURIComponent(VARTIST_GID)}>
          {l('Add Various Artists Release')}
        </a>
      </li>
      <li>
        <a href="/recording/create">
          {lp('Add Standalone Recording', 'button/menu')}
        </a>
      </li>
      <li>
        <a href="/work/create">{lp('Add Work', 'button/menu')}</a>
      </li>
      <li>
        <a href="/place/create">{lp('Add Place', 'button/menu')}</a>
      </li>
      <li>
        <a href="/series/create">{lp('Add Series', 'button/menu')}</a>
      </li>
      <li>
        <a href="/event/create">{lp('Add Event', 'button/menu')}</a>
      </li>
      <li className="separator">
        <a href="/vote">{l('Vote on Edits')}</a>
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
        <a href="/doc/Beginners_Guide">{l('Beginners Guide')}</a>
      </li>
      <li>
        <a href="/doc/Style">{l('Style Guidelines')}</a>
      </li>
      <li>
        <a href="/doc/How_To">{l('How Tos')}</a>
      </li>
      <li>
        <a href="/doc/Frequently_Asked_Questions">{l('FAQs')}</a>
      </li>
      <li>
        <a href="/doc/MusicBrainz_Documentation">
          {l('Documentation Index')}
        </a>
      </li>
      <li className="separator">
        <a href="/doc/Edit_Types">{l('Edit Types')}</a>
      </li>
      <li>
        <a href="/relationships">{l('Relationship Types')}</a>
      </li>
      <li>
        <a href="/instruments">{l('Instrument List')}</a>
      </li>
      <li>
        <a href="/genres">{l('Genre List')}</a>
      </li>
      <li className="separator">
        <a href="/doc/Development">{l('Development')}</a>
      </li>
    </ul>
  </li>
);

const BottomMenu = (): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);
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
            $c={$c}
            currentBCP47Language={$c.stash.current_language.replace('_', '-')}
            serverLanguages={serverLanguages}
          />
        ) : null}
      </ul>
    </div>
  );
};

export default BottomMenu;
