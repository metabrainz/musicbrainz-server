/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  faChevronLeft,
  faChevronRight,
  faMagnifyingGlass,
} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../context.mjs';
import {returnToCurrentPage} from '../../../utility/returnUri.js';
import advancedSearchIcon from '../../images/homepage/advanced_search.svg';
import languageIcon from '../../images/homepage/language-icon.svg';
import magnifyingGlass from '../../images/icons/magnifying-glass.svg';
import magnifyingGlassTheme
  from '../../images/icons/magnifying-glass-theme.svg';
import musicbrainzLogoIcon
  from '../../images/meb-logos/MusicBrainz_logo_icon.svg';
import musicbrainzLogo
  from '../../images/meb-logos/MusicBrainz_logo_mini.svg';
import {capitalize} from '../common/utility/strings.js';

import LanguageSelector from './language.js';
import MobileSearchPopup from './mobile-search-popup.js';
import entities from './utils.js';

type DropdownMenuItem = {
  context?: string,
  href: string,
  label: N_l_T,
};

const aboutGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: '/doc/About', label: N_l('About MusicBrainz')},
    {href: 'https://metabrainz.org/sponsors', label: N_l('Sponsors')},
    {href: 'https://metabrainz.org/team', label: N_l('Team')},
    {
      href: 'https://www.redbubble.com/people/metabrainz/shop',
      label: N_l('Shop'),
    },
    {href: 'https://metabrainz.org/contact', label: N_l('Contact us')},
  ],
  [
    {href: '/doc/About/Data_License', label: N_l('Data licenses')},
    {
      href: 'https://metabrainz.org/social-contract',
      label: N_l('Social contract'),
    },
    {href: '/doc/Code_of_Conduct', label: N_l('Code of Conduct')},
    {href: 'https://metabrainz.org/privacy', label: N_l('Privacy policy')},
    {href: 'https://metabrainz.org/gdpr', label: N_l('GDPR compliance')},
    {
      href: '/doc/Copyright_and_DMCA_Compliance',
      label: N_l('Copyright and DMCA compliance'),
    },
    {href: '/doc/Data_Removal_Policy', label: N_l('Data removal policy')},
  ],
  [
    {href: '/elections', label: N_l('Auto-editor elections')},
    {href: '/privileged', label: N_l('Privileged user accounts')},
    {href: '/statistics', label: N_l('Statistics')},
    {href: '/statistics/timeline', label: N_l('Timeline graph')},
    {href: '/history', label: N_l('MusicBrainz history')},
  ],
];

const productGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: '//picard.musicbrainz.org', label: N_l('MusicBrainz Picard')},
    {href: '/doc/AudioRanger', label: N_l('AudioRanger')},
    {href: '/doc/Mp3tag', label: N_l('Mp3tag')},
    {href: '/doc/Yate_Music_Tagger', label: N_l('Yate Music Tagger')},
  ],
  [
    {
      href: '/doc/MusicBrainz_for_Android',
      label: N_l('MusicBrainz for Android'),
    },
  ],
  [
    {href: '/doc/MusicBrainz_Server', label: N_l('MusicBrainz Server')},
    {href: '/doc/MusicBrainz_Database', label: N_l('MusicBrainz Database')},
  ],
  [
    {href: '/doc/Developer_Resources', label: N_l('Developer resources')},
    {href: '/doc/MusicBrainz_API', label: N_l('MusicBrainz API')},
    {href: '/doc/Live_Data_Feed', label: N_l('Live Data Feed')},
  ],
];

const searchGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: '/search', label: N_l('Advanced search')},
    {href: '/search/edits', label: N_l('Edit search')},
    {href: '/tags', label: N_lp('Tag cloud', 'folksonomy')},
    {href: '/cdstub/browse', label: N_l('Top CD stubs')},
  ],
];

const communityGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: 'https://community.metabrainz.org/', label: N_l('Forums')},
    {href: '/doc/Communication/ChatBrainz', label: N_l('Chat')},
    {href: 'https://bsky.app/profile/musicbrainz.org', label: N_l('Bluesky')},
    {href: 'https://mastodon.social/@musicbrainz', label: N_l('Mastodon')},
    {href: 'https://www.reddit.com/r/MusicBrainz/', label: N_l('Reddit')},
    {href: 'https://discord.gg/R4hBw972QA', label: N_l('Discord')},
  ],
];

type DropdownSectionT = {
  +groups: Array<Array<DropdownMenuItem>>,
  +key: string,
  +label: N_l_T,
};

type LanguageDropdownSectionT = {
  +key: 'language',
};

const dropdownSections: $ReadOnlyArray<DropdownSectionT> = [
  {groups: aboutGroups, key: 'about', label: N_l('About')},
  {groups: communityGroups, key: 'community', label: N_l('Community')},
  {groups: productGroups, key: 'products', label: N_l('Products')},
  {groups: searchGroups, key: 'search', label: N_l('Search')},
];

component DropDownMenu(
  section: DropdownSectionT,
) {
  return (
    <li className="nav-item dropdown d-flex align-items-center">
      <a
        aria-expanded="false"
        className="nav-link dropdown-toggle"
        data-bs-toggle="dropdown"
        href="#"
        role="button"
      >
        {section.label()}
      </a>
      <ul className="dropdown-menu">
        {section.groups.map((group, gIdx) => (
          <React.Fragment key={gIdx}>

            {group.map((item, idx) => {
              const itemLabel = item.label();

              return (
                <li key={idx}>
                  <a
                    className="dropdown-item"
                    href={item.href}
                    title={itemLabel}
                  >
                    {itemLabel}
                  </a>
                </li>
              );
            })}

            {gIdx !== section.groups.length - 1 && (
              <li>
                <hr className="dropdown-divider" />
              </li>
            )}
          </React.Fragment>
        ))}
      </ul>
    </li>
  );
}

component MobileSidebar(
  isOpen: boolean,
  onClose: () => void,
  section: DropdownSectionT | LanguageDropdownSectionT | null,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const groups = section && section.key !== 'language'
    ? section.groups
    : [];
  const isLanguage = section ? section.key === 'language' : false;

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

  const serverLanguages = isLanguage ? $c.stash.server_languages : null;
  const currentLanguage = isLanguage
    ? $c.stash.current_language.replace('_', '-')
    : null;

  return (
    <>
      <div
        className={`mobile-sidebar-backdrop ${isOpen ? 'open' : ''}`}
        onClick={onClose}
      />
      <div className={`mobile-sidebar ${isOpen ? 'open' : ''}`}>
        <div className="offcanvas-body">
          {isLanguage ? (
            <ul className="list-unstyled mb-0">
              {serverLanguages?.map((language) => {
                const isSelected = language.name === currentLanguage;
                return (
                  <li className="border-bottom" key={language.name}>
                    <a
                      className={`d-block bg-transparent
                        text-decoration-none ${
                        isSelected ? 'active' : ''
                      }`}
                      href={`/set-language/${encodeURIComponent(
                        language.name,
                      )}?${returnToCurrentPage($c)}`}
                      onClick={onClose}
                    >
                      {languageName(language, isSelected)}
                    </a>
                  </li>
                );
              })}
              <li className="border-bottom">
                <a
                  className="d-block bg-transparent text-decoration-none"
                  href={`/set-language/unset?${returnToCurrentPage($c)}`}
                  onClick={onClose}
                >
                  {l('(reset language)')}
                </a>
              </li>
              <li className="border-bottom">
                <a
                  className="d-block bg-transparent text-decoration-none"
                  href="https://translations.metabrainz.org/projects/musicbrainz/"
                  onClick={onClose}
                >
                  {l('Help translate')}
                </a>
              </li>
            </ul>
          ) : (
            groups.map((group, gIdx) => (
              <ul className="list-unstyled mb-0" key={gIdx}>
                {group.map((item, idx) => (
                <li className="border-bottom" key={idx}>
                  <a
                    className="d-block bg-transparent text-decoration-none"
                    href={item.href}
                    onClick={onClose}
                  >
                    {item.label()}
                  </a>
                </li>
                ))}
              </ul>
            ))
          )}
        </div>
        <button
          aria-label={lp('Close', 'interactive')}
          onClick={onClose}
          type="button"
        >
          <FontAwesomeIcon color="white" icon={faChevronLeft} size="xl" />
        </button>
      </div>
    </>
  );
}

component Navbar() {
  const [mobileSidebar, setMobileSidebar] = React.useState<{
    isOpen: boolean,
    section:
      | DropdownSectionT
      | LanguageDropdownSectionT
      | null,
  }>({
    isOpen: false,
    section: null,
  });

  const openMobileSidebar = (
    section: DropdownSectionT | LanguageDropdownSectionT,
  ) => {
    setMobileSidebar({
      isOpen: true,
      section,
    });
  };

  const closeMobileSidebar = React.useCallback(() => {
    setMobileSidebar((prev) => ({
      ...prev,
      isOpen: false,
    }));
  }, []);

  const toggleMobileSidebar = (
    section: DropdownSectionT | LanguageDropdownSectionT,
  ) => {
    if (mobileSidebar.isOpen && mobileSidebar.section === section) {
      closeMobileSidebar();
    } else {
      openMobileSidebar(section);
    }
  };

  const toggleLanguageSidebar = () => {
    toggleMobileSidebar({key: 'language'});
  };

  return (
    <nav className="navbar navbar-expand-lg shadow-sm">
      <div className="container-fluid gap-4 position-relative layout-width">
        <button
          aria-controls="offcanvasNavbar"
          className="navbar-toggler position-absolute"
          data-bs-target="#offcanvasNavbar"
          data-bs-toggle="offcanvas"
          type="button"
        >
          <span className="navbar-toggler-icon" />
        </button>

        <a className="navbar-brand mx-auto" href="#">
          <img
            alt="MusicBrainz"
            height={40}
            src={musicbrainzLogo}
            width={200}
          />
        </a>

        <button
          aria-controls="mobileSearchOffcanvas"
          className={`d-lg-none position-absolute end-0
            pe-2 border-0 bg-transparent`}
          data-bs-target="#mobileSearchOffcanvas"
          data-bs-toggle="offcanvas"
          type="button"
        >
          <img
            alt={l('Search')}
            className="search-button-mobile"
            src={magnifyingGlassTheme}
          />
        </button>

        <div
          className="offcanvas offcanvas-start gap-3"
          data-bs-scroll="true"
          id="offcanvasNavbar"
        >
          <div className="offcanvas-header">
            <img alt="MusicBrainz" height={40} src={musicbrainzLogoIcon} />
          </div>
          <div className="offcanvas-body gap-3">
            <ul
              className="d-none d-lg-flex navbar-nav flex-grow-1 gap-3"
              id="offcanvasNavbarMenu"
            >
              {dropdownSections.map((section) => (
                <DropDownMenu key={section.key} section={section} />
              ))}

              {/* Language Selector */}
              <li className="nav-item dropdown d-flex">
                <LanguageSelector />
              </li>
            </ul>

            <form
              action="/search"
              className="d-none d-lg-flex mt-3 mt-lg-0"
              method="get"
              role="search"
            >
              <div className="input-group">
                <input
                  aria-label={l('Search')}
                  className="form-control"
                  id="headerid-query"
                  name="query"
                  placeholder={l('Search')}
                  required
                  type="text"
                />

                <span className="input-group-text">
                  {l('in')}
                </span>

                <select
                  aria-label={l('Entity for search')}
                  className="form-select"
                  name="type"
                >
                  {entities.map((entity) => (
                    <option key={entity.value} value={entity.value}>
                      {entity.name}
                    </option>
                  ))}
                </select>

                <button
                  className="btn search-button"
                  type="submit"
                >
                  <FontAwesomeIcon icon={faMagnifyingGlass} size="xl" />
                </button>
              </div>
            </form>

            <a
              className={`btn search-button advanced-search-button
                d-none d-lg-block`}
              href="/search"
            >
              <img
                alt={l('Advanced Search')}
                height={20}
                src={advancedSearchIcon}
                width={20}
              />
            </a>

            {/* Mobile Menu */}
            <ul
              className={`d-lg-none navbar-nav flex-grow-1 gap-3
                align-items-end`}
              id="offcanvasNavbarMenuMobile"
            >
              {dropdownSections.map((section) => {
                const isActive = mobileSidebar.section === section &&
                  mobileSidebar.isOpen;
                const handleClick = () => toggleMobileSidebar(section);
                return (
                  <li className="nav-item" key={section.key}>
                    <button
                      className={`nav-link border-0 bg-transparent
                        d-flex align-items-center ${
                        isActive ? 'active' : ''
                      }`}
                      onClick={handleClick}
                      type="button"
                    >
                      {section.label()}
                      <FontAwesomeIcon
                        className={isActive ? 'active' : ''}
                        icon={faChevronRight}
                      />
                    </button>
                  </li>
                );
              })}
            </ul>

            <button
              aria-label={l('Language')}
              className="d-lg-none border-0 bg-transparent text-end"
              onClick={toggleLanguageSidebar}
              type="button"
            >
              <img
                alt={l('Language')}
                height={40}
                src={languageIcon}
                width={40}
              />
            </button>

            <button
              aria-controls="mobileSearchOffcanvas"
              className="d-lg-none border-0 bg-transparent text-end"
              data-bs-target="#mobileSearchOffcanvas"
              data-bs-toggle="offcanvas"
              onClick={closeMobileSidebar}
              type="button"
            >
              <img
                alt={l('Search')}
                className="search-button"
                height={40}
                src={magnifyingGlass}
                width={40}
              />
            </button>
          </div>
        </div>
      </div>

      <MobileSidebar
        isOpen={mobileSidebar.isOpen}
        onClose={closeMobileSidebar}
        section={mobileSidebar.section}
      />

      <MobileSearchPopup />
    </nav>
  );
}

export default (hydrate < React.PropsOf< Navbar >>(
  'div.new-navbar.fixed-top',
  Navbar,
): component(...React.PropsOf< Navbar >));
