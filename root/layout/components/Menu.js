// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const React = require('react');

const EditorLink = require('../../static/scripts/common/components/EditorLink');
const {VARTIST_GID} = require('../../static/scripts/common/constants');
const {l, lp} = require('../../static/scripts/common/i18n');

function languageLink(language) {
  let {id, native_language, native_territory} = language[1];
  let text = `[${id}]`;

  if (native_language) {
    text = _.capitalize(native_language);

    if (native_territory) {
      text += ' (' + _.capitalize(native_territory) + ')';
    }
  }

  return <a href={$c.uri_for_action('/set_language', [language[0]])}>{text}</a>;
}

const LanguageMenu = () => (
  <li className="language-selector">
    {languageLink(_.find($c.stash.server_languages, l => l[0] === $c.stash.current_language))}
    <ul>
      {$c.stash.server_languages.map(function (l, index) {
        let inner = languageLink(l);

        if (l[0] === $c.stash.current_language) {
          inner = <strong>{inner}</strong>;
        }

        return <li key={index}>{inner}</li>;
      })}
      <li>
        <a href={$c.uri_for_action('/set_language', ['unset'])}>
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

const AccountMenu = () => (
  <li className="account">
    <EditorLink editor={$c.user} />
    <ul>
      <li>
        <a href={$c.uri_for('/account/edit')}>{l('Edit Profile')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/account/change_password')}>{l('Change Password')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/account/preferences')}>{l('Preferences')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/account/applications')}>{l('Applications')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/user/subscriptions/artist', [$c.user.name])}>
          {l('Subscriptions')}
        </a>
      </li>
      <li>
        <a href={$c.uri_for_action('/user/logout')}>{l('Log Out')}</a>
      </li>
    </ul>
  </li>
);

const DataMenu = () => {
  let userName = $c.user.name;

  return (
    <li className="data">
      <a href={$c.uri_for_action('/user/profile', [userName])}>{l('My Data')}</a>
      <ul>
        <li>
          <a href={$c.uri_for_action('/user/collections', [userName])}>{l('My Collections')}</a>
        </li>
        <li>
          <a href={$c.uri_for_action('/user/ratings', [userName])}>{l('My Ratings')}</a>
        </li>
        <li>
          <a href={$c.uri_for_action('/user/tags', [userName])}>{l('My Tags')}</a>
        </li>
        <li className="separator">
          <a href={$c.uri_for_action('/user/edits/open', [userName])}>{l('My Open Edits')}</a>
        </li>
        <li>
          <a href={$c.uri_for_action('/user/edits/all', [userName])}>{l('All My Edits')}</a>
        </li>
        <li>
          <a href={$c.uri_for_action('/edit/subscribed')}>{l('Edits for Subscribed Entities')}</a>
        </li>
        <li>
          <a href={$c.uri_for_action('/edit/subscribed_editors')}>{l('Edits by Subscribed Editors')}</a>
        </li>
        <li>
          <a href={$c.uri_for_action('/edit/notes_received')}>{l('Notes Left on My Edits')}</a>
        </li>
      </ul>
    </li>
  );
};

const AdminMenu = () => (
  <li className="admin">
    <a href={$c.uri_for_action('/admin/index')}>{l('Admin')}</a>
    <ul>
      {$c.user.is_location_editor &&
        <li>
          <a href={$c.uri_for('/area/create')}>{lp('Add Area', 'button/menu')}</a>
        </li>}

      {$c.user.is_relationship_editor && [
        <li key="1">
          <a href={$c.uri_for('/instrument/create')}>{lp('Add Instrument', 'button/menu')}</a>
        </li>,
        <li key="2">
          <a href={$c.uri_for_action('/relationship/linktype/index')}>{l('Edit Relationship Types')}</a>
        </li>]}

      {$c.user.is_wiki_transcluder &&
        <li>
          <a href={$c.uri_for_action('/admin/wikidoc/index')}>{l('Transclude WikiDocs')}</a>
        </li>}

      {$c.user.is_banner_editor &&
        <li>
          <a href={$c.uri_for_action('/admin/edit_banner')}>{l('Edit Banner Message')}</a>
        </li>}

      {$c.user.is_account_admin &&
        <li>
          <a href={$c.uri_for_action('/admin/attributes/index')}>{l('Edit Attributes')}</a>
        </li>}
    </ul>
  </li>
);

const AboutMenu = () => (
  <li className="about">
    <a href={doc_link('About')}>{l('About')}</a>
    <ul>
      <li>
        <a href="//metabrainz.org/doc/Sponsors">{l('Sponsors')}</a>
      </li>
      <li>
        <a href={doc_link('About/Team')}>{l('Team')}</a>
      </li>
      <li className="separator">
        <a href={doc_link('About/Data_License')}>{l('Data Licenses')}</a>
      </li>
      <li>
        <a href={doc_link('Social_Contract')}>{l('Social Contract')}</a>
      </li>
      <li>
        <a href={doc_link('Code_of_Conduct')}>{l('Code of Conduct')}</a>
      </li>
      <li>
        <a href={doc_link('About/Privacy_Policy')}>{l('Privacy Policy')}</a>
      </li>
      <li className="separator">
        <a href={$c.uri_for_action('/elections/index')}>{l('Auto-editor Elections')}</a>
      </li>
      <li>
        <a href={$c.uri_for('/privileged')}>{l('Privileged User Accounts')}</a>
      </li>
      <li>
        <a href={$c.uri_for('/statistics')}>{l('Statistics')}</a>
      </li>
      <li>
        <a href={$c.uri_for('/statistics/timeline')}>{l('Timeline Graph')}</a>
      </li>
    </ul>
  </li>
);

const BlogMenu = () => (
  <li className="blog">
    <a href="http://blog.musicbrainz.org" className="internal">
      {l('Blog')}
    </a>
  </li>
);

const ProductsMenu = () => (
  <li className="products">
    <a href={doc_link('Products')}>{l('Products')}</a>
    <ul>
      <li>
        <a href="//picard.musicbrainz.org">{l('MusicBrainz Picard')}</a>
      </li>
      <li>
        <a href={doc_link('Magic_MP3_Tagger')}>{l('Magic MP3 Tagger')}</a>
      </li>
      <li>
        <a href={doc_link('Yate_Music_Tagger')}>{l('Yate Music Tagger')}</a>
      </li>
      <li className="separator">
        <a href={doc_link('MusicBrainz_for_Android')}>{l('MusicBrainz for Android')}</a>
      </li>
      <li className="separator">
        <a href={doc_link('MusicBrainz_Server')}>{l('MusicBrainz Server')}</a>
      </li>
      <li>
        <a href={doc_link('MusicBrainz_Database')}>{l('MusicBrainz Database')}</a>
      </li>
      <li className="separator">
        <a href={doc_link('Developer_Resources')}>{l('Developer Resources')}</a>
      </li>
      <li>
        <a href={doc_link('XML_Web_Service')}>{l('XML Web Service')}</a>
      </li>
      <li>
        <a href={doc_link('Live_Data_Feed')}>{l('Live Data Feed')}</a>
      </li>
      <li className="separator">
        <a href={doc_link('FreeDB_Gateway')}>{l('FreeDB Gateway')}</a>
      </li>
    </ul>
  </li>
);

const SearchMenu = () => (
  <li className="search">
    <a href="/search">{l('Search')}</a>
    <ul>
      {$c.user &&
        <li>
          <a href={$c.uri_for_action('/edit/search')}>{l('Search Edits')}</a>
        </li>}
      <li>
        <a href={$c.uri_for('/tags')}>{l('Tags')}</a>
      </li>
      <li>
        <a href={$c.uri_for('/cdstub/browse')}>{l('Top CD Stubs')}</a>
      </li>
    </ul>
  </li>
);

const EditingMenu = () => (
  <li className="editing">
    <a href={doc_link('How_Editing_Works')}>{l('Editing')}</a>
    <ul>
      <li>
        <a href={$c.uri_for('/artist/create')}>{lp('Add Artist', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for('/label/create')}>{lp('Add Label', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/release_group/create')}>{lp('Add Release Group', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/release_editor/add')}>{lp('Add Release', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/release_editor/add', {artist: VARTIST_GID})}>
          {l('Add Various Artists Release')}
        </a>
      </li>
      <li>
        <a href={$c.uri_for_action('/recording/create')}>{lp('Add Standalone Recording', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/work/create')}>{lp('Add Work', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/place/create')}>{lp('Add Place', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/series/create')}>{lp('Add Series', 'button/menu')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/event/create')}>{lp('Add Event', 'button/menu')}</a>
      </li>
      <li className="separator">
        <a href={$c.uri_for('/edit/open')}>{l('Vote on Edits')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/report/index')}>{l('Reports')}</a>
      </li>
    </ul>
  </li>
);

const DocumentationMenu = () => (
  <li className="documentation">
    <a href={doc_link('MusicBrainz_Documentation')}>{l('Documentation')}</a>
    <ul>
      <li>
        <a href={doc_link('Beginners_Guide')}>{l('Beginners Guide')}</a>
      </li>
      <li>
        <a href={doc_link('Style')}>{l('Style Guidelines')}</a>
      </li>
      <li>
        <a href={doc_link('How_To')}>{l('How Tos')}</a>
      </li>
      <li>
        <a href={doc_link('Frequently_Asked_Questions')}>{l('FAQs')}</a>
      </li>
      <li className="separator">
        <a href={$c.uri_for_action('/edit/edit_types')}>{l('Edit Types')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/relationship/linktype/index')}>{l('Relationship Types')}</a>
      </li>
      <li>
        <a href={$c.uri_for_action('/instrument/list')}>{l('Instrument List')}</a>
      </li>
      <li className="separator">
        <a href={doc_link('Development')}>{l('Development')}</a>
      </li>
    </ul>
  </li>
);

const ContactMenu = () => (
  <li className="contact">
    <a href="https://metabrainz.org/contact">{l('Contact Us')}</a>
    <ul>
      <li>
        <a href="http://forums.musicbrainz.org" className="internal">
          {l('Forums')}
        </a>
      </li>
      <li>
        <a href="http://tickets.musicbrainz.org" className="internal">
          {l('Report a Bug')}
        </a>
      </li>
    </ul>
  </li>
);

const LeftMenu = () => (
  <ul>
    <AboutMenu />
    <BlogMenu />
    <ProductsMenu />
    <SearchMenu />
    {$c.user && <EditingMenu />}
    <DocumentationMenu />
    <ContactMenu />
  </ul>
);

const RightMenu = (props) => (
  <ul className="r">
    {$c.stash.server_languages.length > 1 && <LanguageMenu />}

    {$c.user && [
      <AccountMenu key={1} />,
      <DataMenu key={2} />,
      $c.user.is_admin && <AdminMenu key={3} />
    ]}

    {!$c.user && [
      <li key={4}>
        <a href={$c.uri_for_action('/user/login', {uri: $c.req.query_params.uri || $c.relative_uri})}>
          {l('Log In')}
        </a>
      </li>,
      <li key={5}>
        <a href={$c.uri_for_action('/account/register', {uri: $c.req.query_params.uri || $c.relative_uri})}>
          {l('Create Account')}
        </a>
      </li>
    ]}
  </ul>
);

const Menu = () => (
  <div id="header-menu">
    <div>
      <RightMenu />
      <LeftMenu />
    </div>
  </div>
);

module.exports = Menu;
