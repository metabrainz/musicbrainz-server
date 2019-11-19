/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import _ from 'lodash';
import React from 'react';

import {VARTIST_GID} from '../../static/scripts/common/constants';

import MenuDropdown from './MenuDropdown';

function languageName(language) {
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
    text = _.capitalize(nativeLanguage);

    if (nativeTerritory) {
      text += ' (' + _.capitalize(nativeTerritory) + ')';
    }
  }

  return text;
}

type LanguageMenuProps = {
  +currentBCP47Language: string,
  +serverLanguages: $ReadOnlyArray<ServerLanguageT>,
};

const LanguageMenu = ({
  currentBCP47Language,
  serverLanguages,
}: LanguageMenuProps) => (
  <MenuDropdown
    className="language-selector"
    id="language-selector-menu-dropdown"
    label={languageName(
      _.find(serverLanguages, x => x.name === currentBCP47Language),
    )}
  >
    {serverLanguages.map(function (language) {
      let inner = languageName(language);

      if (language.name === currentBCP47Language) {
        inner = <strong>{inner}</strong>;
      }
      return (
        <a
          className="dropdown-item"
          href={'/set-language/' + encodeURIComponent(language.name)}
          key={language.name}
        >
          {inner}
        </a>
      );
    })}
    <a className="dropdown-item" href="/set-language/unset">
      {l('(reset language)')}
    </a>
    <div className="dropdown-divider" />
    <a
      className="dropdown-item"
      href="https://www.transifex.com/musicbrainz/musicbrainz/"
    >
      {l('Help Translate')}
    </a>
  </MenuDropdown>
);

const AboutMenu = () => (
  <MenuDropdown
    className="about"
    id="about-menu-dropdown"
    label={l('About Us')}
  >
    <a className="dropdown-item" href="/doc/About">
      {l('About MusicBrainz')}
    </a>
    <a className="dropdown-item" href="https://metabrainz.org/sponsors">
      {l('Sponsors')}
    </a>
    <a className="dropdown-item" href="https://metabrainz.org/team">
      {l('Team')}
    </a>
    <a className="dropdown-item" href="https://www.redbubble.com/people/metabrainz/shop">
      {l('Shop')}
    </a>
    <a className="dropdown-item" href="https://metabrainz.org/contact">
      {l('Contact Us')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/About/Data_License">
      {l('Data Licenses')}
    </a>
    <a className="dropdown-item" href="https://metabrainz.org/social-contract">
      {l('Social Contract')}
    </a>
    <a className="dropdown-item" href="/doc/Code_of_Conduct">
      {l('Code of Conduct')}
    </a>
    <a className="dropdown-item" href="https://metabrainz.org/privacy">
      {l('Privacy Policy')}
    </a>
    <a className="dropdown-item" href="https://metabrainz.org/gdpr">
      {l('GDPR Compliance')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/elections">
      {l('Auto-editor Elections')}
    </a>
    <a className="dropdown-item" href="/privileged">
      {l('Privileged User Accounts')}
    </a>
    <a className="dropdown-item" href="/statistics">
      {l('Statistics')}
    </a>
    <a className="dropdown-item" href="/statistics/timeline">
      {l('Timeline Graph')}
    </a>
  </MenuDropdown>
);

const ProductsMenu = () => (
  <MenuDropdown
    className="products"
    id="products-menu-dropdown"
    label={l('Products')}
  >
    <a className="dropdown-item" href="//picard.musicbrainz.org">
      {l('MusicBrainz Picard')}
    </a>
    <a className="dropdown-item" href="/doc/Magic_MP3_Tagger">
      {l('Magic MP3 Tagger')}
    </a>
    <a className="dropdown-item" href="/doc/Yate_Music_Tagger">
      {l('Yate Music Tagger')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/MusicBrainz_for_Android">
      {l('MusicBrainz for Android')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/MusicBrainz_Server">
      {l('MusicBrainz Server')}
    </a>
    <a className="dropdown-item" href="/doc/MusicBrainz_Database">
      {l('MusicBrainz Database')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/Developer_Resources">
      {l('Developer Resources')}
    </a>
    <a className="dropdown-item" href="/doc/XML_Web_Service">
      {l('XML Web Service')}
    </a>
    <a className="dropdown-item" href="/doc/Live_Data_Feed">
      {l('Live Data Feed')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/FreeDB_Gateway">
      {l('FreeDB Gateway')}
    </a>
  </MenuDropdown>
);

const SearchMenu = ({$c}: {+$c: CatalystContextT}) => (
  <MenuDropdown
    className="search"
    id="search-menu-dropdown"
    label={l('Search')}
  >
    <a className="dropdown-item" href="/search">{l('Search Entities')}</a>
    {$c.user_exists ? (
      <a className="dropdown-item" href="/search/edits">{l('Search Edits')}</a>
    ) : null}
    <a className="dropdown-item" href="/tags">{l('Tags')}</a>
    <a className="dropdown-item" href="/cdstub/browse">{l('Top CD Stubs')}</a>
  </MenuDropdown>
);

const EditingMenu = () => (
  <MenuDropdown
    className="editing"
    id="editing-menu-dropdown"
    label={l('Editing')}
  >
    <a className="dropdown-item" href="/artist/create">
      {lp('Add Artist', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/label/create">
      {lp('Add Label', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/release-group/create">
      {lp('Add Release Group', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/release/add">
      {lp('Add Release', 'button/menu')}
    </a>
    <a className="dropdown-item" href={'/release/add?artist=' + encodeURIComponent(VARTIST_GID)}>
      {l('Add Various Artists Release')}
    </a>
    <a className="dropdown-item" href="/recording/create">
      {lp('Add Standalone Recording', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/work/create">
      {lp('Add Work', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/place/create">
      {lp('Add Place', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/series/create">
      {lp('Add Series', 'button/menu')}
    </a>
    <a className="dropdown-item" href="/event/create">
      {lp('Add Event', 'button/menu')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/vote">
      {l('Vote on Edits')}
    </a>
    <a className="dropdown-item" href="/reports">
      {l('Reports')}
    </a>
  </MenuDropdown>
);

const DocumentationMenu = () => (
  <MenuDropdown
    className="documentation"
    id="documentation-menu-dropdown"
    label={l('Documentation')}
  >
    <a className="dropdown-item" href="/doc/Beginners_Guide">
      {l('Beginners Guide')}
    </a>
    <a className="dropdown-item" href="/doc/Style">
      {l('Style Guidelines')}
    </a>
    <a className="dropdown-item" href="/doc/How_To">
      {l('How Tos')}
    </a>
    <a className="dropdown-item" href="/doc/Frequently_Asked_Questions">
      {l('FAQs')}
    </a>
    <a className="dropdown-item" href="/doc/MusicBrainz_Documentation">
      {l('Documentation Index')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/Edit_Types">
      {l('Edit Types')}
    </a>
    <a className="dropdown-item" href="/relationships">
      {l('Relationship Types')}
    </a>
    <a className="dropdown-item" href="/instruments">
      {l('Instrument List')}
    </a>
    <a className="dropdown-item" href="/genres">
      {l('Genre List')}
    </a>
    <div className="dropdown-divider" />
    <a className="dropdown-item" href="/doc/Development">
      {l('Development')}
    </a>
  </MenuDropdown>
);

type Props = {
  +$c: CatalystContextT,
  +currentLanguage: string,
  +serverLanguages: ?$ReadOnlyArray<ServerLanguageT>,
};

const BottomMenu = ({
  $c,
  currentLanguage,
  serverLanguages,
}: Props) => (
  <ul className="navbar-nav mr-auto mt-0" style={{width: '100%'}}>
    <AboutMenu />
    <ProductsMenu />
    <SearchMenu $c={$c} />
    {$c.user_exists ? <EditingMenu /> : null}
    <DocumentationMenu />
    {serverLanguages && serverLanguages.length > 1 ? (
      <>
        <li style={{flexGrow: 2}} />
        <LanguageMenu
          currentBCP47Language={currentLanguage.replace('_', '-')}
          serverLanguages={serverLanguages}
        />
      </>
    ) : null}
  </ul>
);

export default BottomMenu;
