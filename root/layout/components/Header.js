/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import returnUri, {returnToCurrentPage} from '../../utility/returnUri';
import {
  isAccountAdmin, isAdmin,
  isBannerEditor,
  isLocationEditor,
  isRelationshipEditor,
  isWikiTranscluder,
} from '../../static/scripts/common/utility/privileges';
import {CatalystContext} from '../../context';
import RequestLogin from '../../components/RequestLogin';
import {VARTIST_GID} from '../../static/scripts/common/constants';
import headerLogoSvgUrl from '../../static/images/layout/header-logo.svg';

import Search from './Search';

function userLink(userName, path) {
  return `/user/${encodeURIComponent(userName)}${path}`;
}

type UserProp = {+user: UnsanitizedEditorT};

const AccountMenu = ({
  $c,
  user,
}: {
  +$c: CatalystContextT,
  +user: UnsanitizedEditorT,
}) => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="account-dropdown"
      role="button"
    >
      {user.name}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="account-dropdown" className="dropdown-menu">
      <li className="nav-item fs-6">
        <a className="dropdown-item" href={userLink(user.name, '')}>
          {l('Profile')}
        </a>
      </li>

      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href={userLink(user.name, '/collections')}
        >
          {l('Collections')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href={userLink(user.name, '/ratings')}>
          {l('Ratings')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href={userLink(user.name, '/tags')}
        >
          {l('Tags')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a
          className="dropdown-item"
          href={userLink(user.name, '/edits/open')}
        >
          {l('Open Edits')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href={userLink(user.name, '/edits')}>
          {l('All Edits')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/edit/subscribed">
          {l('Edits for Subscribed Entities')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/edit/subscribed_editors">
          {l('Edits by Subscribed Editors')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/edit/notes-received">
          {l('Notes Left on Edits')}
        </a>
      </li>

      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/account/applications">
          {l('Applications')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href={userLink(user.name, '/subscriptions/artist')}
        >
          {l('Subscriptions')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href={
            '/logout' + (
              $c.stash.current_action_requires_auth === true
                ? ''
                : ('?' + returnToCurrentPage($c))
            )
          }
        >
          {l('Log Out')}
        </a>
      </li>
    </ul>
  </li>
);

const AdminMenu = ({user}: UserProp) => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="admin-dropdown"
      role="button"
    >
      {l('Admin')}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="admin-dropdown" className="dropdown-menu">
      {isLocationEditor(user) ? (
        <li className="nav-item fs-6">
          <a className="dropdown-item" href="/area/create">
            {lp('Add Area', 'button/menu')}
          </a>
        </li>
      ) : null}

      {isRelationshipEditor(user) ? (
        <>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/instrument/create">
              {lp('Add Instrument', 'button/menu')}
            </a>
          </li>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/genre/create">
              {lp('Add Genre', 'button/menu')}
            </a>
          </li>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/relationships">
              {l('Edit Relationship Types')}
            </a>
          </li>
        </>
      ) : null}

      {isWikiTranscluder(user) ? (
        <li className="nav-item fs-6">
          <a className="dropdown-item" href="/admin/wikidoc">
            {l('Transclude WikiDocs')}
          </a>
        </li>
      ) : null}

      {isBannerEditor(user) ? (
        <li className="nav-item fs-6">
          <a className="dropdown-item" href="/admin/banner/edit">
            {l('Edit Banner Message')}
          </a>
        </li>
      ) : null}

      {isAccountAdmin(user) ? (
        <>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/admin/attributes">
              {l('Edit Attributes')}
            </a>
          </li>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/admin/statistics-events">
              {l('Edit Statistics Events')}
            </a>
          </li>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/admin/email-search">
              {l('Email Search')}
            </a>
          </li>
          <li className="nav-item fs-6">
            <a className="dropdown-item" href="/admin/privilege-search">
              {l('Privilege Search')}
            </a>
          </li>
          <li className="nav-item fs-6">
            <a
              className="dropdown-item"
              href="/admin/locked-usernames/search"
            >
              {l('Locked Username Search')}
            </a>
          </li>
        </>
      ) : null}
    </ul>
  </li>
);

const UserMenu = () => {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      {$c.user ? (
        <>
          <AccountMenu $c={$c} user={$c.user} />
          {isAdmin($c.user) ? <AdminMenu user={$c.user} /> : null}
        </>
      ) : (
        <>
          <li className="nav-item fs-6">
            <RequestLogin $c={$c} text={l('Log In')} />
          </li>
          <li className="nav-item fs-6">
            <a className="nav-link" href={returnUri($c, '/register')}>
              {l('Create Account')}
            </a>
          </li>
        </>
      )}
    </>
  );
};

const AboutMenu = () => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="about-dropdown"
      role="button"
    >
      {l('About Us')}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="about-dropdown" className="dropdown-menu">
      <li className="nav-item dropdown fs-6">
        <a className="dropdown-item" href="/doc/About">
          {l('About MusicBrainz')}
        </a>
      </li>
      <li className="nav-item dropdown fs-6">
        <a className="dropdown-item" href="https://metabrainz.org/sponsors">{l('Sponsors')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="https://metabrainz.org/team">{l('Team')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="https://www.redbubble.com/people/metabrainz/shop">{l('Shop')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="https://metabrainz.org/contact">{l('Contact Us')}</a>
      </li>
      <li className="separator nav-item fs-6">
        <a
          className="dropdown-item"
          href="/doc/About/Data_License"
        >
          {l('Data Licenses')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href="https://metabrainz.org/social-contract"
        >
          {l('Social Contract')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/Code_of_Conduct">
          {l('Code of Conduct')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="https://metabrainz.org/privacy">{l('Privacy Policy')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="https://metabrainz.org/gdpr">
          {l('GDPR Compliance')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/Data_Removal_Policy">
          {l('Data Removal Policy')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/elections">
          {l('Auto-editor Elections')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/privileged">
          {l('Privileged User Accounts')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/statistics">{l('Statistics')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/statistics/timeline">
          {l('Timeline Graph')}
        </a>
      </li>
    </ul>
  </li>
);

const ProductsMenu = () => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="products-dropdown"
      role="button"
    >
      {l('Products')}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="products-dropdown" className="dropdown-menu">
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="//picard.musicbrainz.org">
          {l('MusicBrainz Picard')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/AudioRanger">
          {l('AudioRanger')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/Mp3tag">{l('Mp3tag')}</a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href="/doc/Yate_Music_Tagger"
        >
          {l('Yate Music Tagger')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/doc/MusicBrainz_for_Android">
          {l('MusicBrainz for Android')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/doc/MusicBrainz_Server">
          {l('MusicBrainz Server')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/MusicBrainz_Database">
          {l('MusicBrainz Database')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/doc/Developer_Resources">
          {l('Developer Resources')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/MusicBrainz_API">
          {l('MusicBrainz API')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/Live_Data_Feed">
          {l('Live Data Feed')}
        </a>
      </li>
    </ul>
  </li>
);

const SearchMenu = () => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="search-dropdown"
      role="button"
    >
      {l('Search')}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="search-dropdown" className="dropdown-menu">
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/search">{l('Search Entities')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/search/edits">
          {l('Search Edits')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/tags">{l('Tags')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/cdstub/browse">
          {l('Top CD Stubs')}
        </a>
      </li>
    </ul>
  </li>
);

const EditingMenu = () => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="editing-dropdown"
      role="button"
    >
      {l('Editing')}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="editing-dropdown" className="dropdown-menu">
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/artist/create">
          {lp('Add Artist', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/label/create">
          {lp('Add Label', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/release-group/create">
          {lp('Add Release Group', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/release/add">
          {lp('Add Release', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href={'/release/add?artist=' + encodeURIComponent(VARTIST_GID)}
        >
          {l('Add Various Artists Release')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/recording/create">
          {lp('Add Standalone Recording', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/work/create">
          {lp('Add Work', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/place/create">
          {lp('Add Place', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/series/create">
          {lp('Add Series', 'button/menu')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/event/create">
          {lp('Add Event', 'button/menu')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/vote">{l('Vote on Edits')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/reports">{l('Reports')}</a>
      </li>
    </ul>
  </li>
);

const DocumentationMenu = () => (
  <li className="nav-item dropdown list-unstyled" tabIndex="-1">
    <a
      aria-expanded="false"
      className="nav-link"
      data-bs-toggle="dropdown"
      href="#"
      id="documentation-dropdown"
      role="button"
    >
      {l('Documentation')}
      {'\xA0\u25BE'}
    </a>
    <ul aria-labelledby="documentation-dropdown" className="dropdown-menu">
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href="/doc/Beginners_Guide"
        >
          {l('Beginners Guide')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a
          className="dropdown-item"
          href="/doc/Style"
        >
          {l('Style Guidelines')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/How_To">{l('How Tos')}</a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/Frequently_Asked_Questions">
          {l('FAQs')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/doc/MusicBrainz_Documentation">
          {l('Documentation Index')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/doc/Edit_Types">
          {l('Edit Types')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/relationships">
          {l('Relationship Types')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/instruments">
          {l('Instrument List')}
        </a>
      </li>
      <li className="nav-item fs-6">
        <a className="dropdown-item" href="/genres">
          {l('Genre List')}
        </a>
      </li>
      <li className="separator nav-item fs-6">
        <a className="dropdown-item" href="/doc/Development">
          {l('Development')}
        </a>
      </li>
    </ul>
  </li>
);

const Header = (): React.Element<'nav'> => {
  const $c = React.useContext(CatalystContext);
  return (
    <nav className="navbar navbar-expand-md navbar-light bg-light">
      <div className="container-fluid" style={{width: '100%'}}>
        <a className="navbar-brand ms-4" href="/" title="MusicBrainz">
          <img
            alt="MusicBrainz"
            height="30px"
            src={headerLogoSvgUrl}
            width="190px"
          />
        </a>
        <button
          aria-controls="navbarToggle"
          aria-expanded="false"
          aria-label="Toggle navigation"
          className="navbar-toggler me-4"
          data-bs-target="#navbarToggle"
          data-bs-toggle="collapse"
          type="button"
        >
          <span className="navbar-toggler-icon" />
        </button>
        <div className="collapse navbar-collapse" id="navbarToggle">
          <ul className="navbar-nav ms-4 me-auto fs-6">
            <UserMenu />
            <AboutMenu />
            <ProductsMenu />
            <SearchMenu />
            {$c.user ? <EditingMenu /> : null}
            <DocumentationMenu />
          </ul>
          <Search />
        </div>
      </div>
    </nav>
  );
};

export default Header;
