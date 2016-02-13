// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const React = require('react');

const {VARTIST_GID} = require('../../static/scripts/common/constants');
const {l, lp} = require('../../static/scripts/common/i18n');

function languageName(language, selected) {
  let {id, native_language, native_territory} = language[1];
  let text = `[${id}]`;

  if (native_language) {
    text = _.capitalize(native_language);

    if (native_territory) {
      text += ' (' + _.capitalize(native_territory) + ')';
    }
  }

  if (selected) {
    text += ' \u25be';
  }

  return text;
}

function languageLink(language) {
  return (
    <a href={"/set-language/" + encodeURIComponent(language[0])}>
      {languageName(language, false)}
    </a>
  );
}

const LanguageMenu = () => (
  <li className="language-selector">
    <span className="menu-header">
      {languageName(_.find($c.stash.server_languages, l => l[0] === $c.stash.current_language), true)}
    </span>
    <ul>
      {$c.stash.server_languages.map(function (l, index) {
        let inner = languageLink(l);

        if (l[0] === $c.stash.current_language) {
          inner = <strong>{inner}</strong>;
        }

        return <li key={index}>{inner}</li>;
      })}
      <li>
        <a href="/set-language/unset">
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
  <li className="about">
    <span className="menu-header">{l('About Us')}{'\xA0\u25BE'}</span>
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
        <a href="https://metabrainz.org/contact">{l('Contact Us')}</a>
      </li>
      <li className="separator">
        <a href="/doc/About/Data_License">{l('Data Licenses')}</a>
      </li>
      <li>
        <a href="/doc/Social_Contract">{l('Social Contract')}</a>
      </li>
      <li>
        <a href="/doc/Code_of_Conduct">{l('Code of Conduct')}</a>
      </li>
      <li>
        <a href="/doc/About/Privacy_Policy">{l('Privacy Policy')}</a>
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
  <li className="products">
    <span className="menu-header">{l('Products')}{'\xA0\u25BE'}</span>
    <ul>
      <li>
        <a href="//picard.musicbrainz.org">{l('MusicBrainz Picard')}</a>
      </li>
      <li>
        <a href="/doc/Magic_MP3_Tagger">{l('Magic MP3 Tagger')}</a>
      </li>
      <li>
        <a href="/doc/Yate_Music_Tagger">{l('Yate Music Tagger')}</a>
      </li>
      <li className="separator">
        <a href="/doc/MusicBrainz_for_Android">{l('MusicBrainz for Android')}</a>
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
        <a href="/doc/XML_Web_Service">{l('XML Web Service')}</a>
      </li>
      <li>
        <a href="/doc/Live_Data_Feed">{l('Live Data Feed')}</a>
      </li>
      <li className="separator">
        <a href="/doc/FreeDB_Gateway">{l('FreeDB Gateway')}</a>
      </li>
    </ul>
  </li>
);

const SearchMenu = () => (
  <li className="search">
    <span className="menu-header">{l('Search')}{'\xA0\u25BE'}</span>
    <ul>
      <li>
        <a href="/search">{l('Search Entities')}</a>
      </li>
      {$c.user &&
        <li>
          <a href="/search/edits">{l('Search Edits')}</a>
        </li>}
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
  <li className="editing">
    <span className="menu-header">{l('Editing')}{'\xA0\u25BE'}</span>
    <ul>
      <li>
        <a href="/artist/create">{lp('Add Artist', 'button/menu')}</a>
      </li>
      <li>
        <a href="/label/create">{lp('Add Label', 'button/menu')}</a>
      </li>
      <li>
        <a href="/release-group/create">{lp('Add Release Group', 'button/menu')}</a>
      </li>
      <li>
        <a href="/release/add">{lp('Add Release', 'button/menu')}</a>
      </li>
      <li>
        <a href={"/release/add?artist=" + encodeURIComponent(VARTIST_GID)}>
          {l('Add Various Artists Release')}
        </a>
      </li>
      <li>
        <a href="/recording/create">{lp('Add Standalone Recording', 'button/menu')}</a>
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
        <a href="/edit/open">{l('Vote on Edits')}</a>
      </li>
      <li>
        <a href="/reports">{l('Reports')}</a>
      </li>
    </ul>
  </li>
);

const DocumentationMenu = () => (
  <li className="documentation">
    <span className="menu-header">{l('Documentation')}{'\xA0\u25BE'}</span>
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
        <a href="/doc/MusicBrainz_Documentation">{l('Documentation Index')}</a>
      </li>
      <li className="separator">
        <a href='/doc/Edit_Types'>{l('Edit Types')}</a>
      </li>
      <li>
        <a href="/relationships">{l('Relationship Types')}</a>
      </li>
      <li>
        <a href="/instruments">{l('Instrument List')}</a>
      </li>
      <li className="separator">
        <a href="/doc/Development">{l('Development')}</a>
      </li>
    </ul>
  </li>
);

const BottomMenu = () => (
  <div className="bottom">
    <ul className="menu">
      <AboutMenu />
      <ProductsMenu />
      <SearchMenu />
      {$c.user && <EditingMenu />}
      <DocumentationMenu />
      {$c.stash.server_languages.length > 1 && <LanguageMenu />}
    </ul>
  </div>
);

module.exports = BottomMenu;
