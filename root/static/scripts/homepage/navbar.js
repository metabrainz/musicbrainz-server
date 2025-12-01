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
import {l, lp} from '../common/i18n.js';
import {capitalize} from '../common/utility/strings.js';

import LanguageSelector from './language.js';
import MobileSearchPopup from './mobile-search-popup.js';
import entities from './utils.js';

type DropdownMenuItem = {
  context?: string,
  href: string,
  label: string,
};


const aboutGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: '/doc/About', label: 'About MusicBrainz'},
    {href: 'https://metabrainz.org/sponsors', label: 'Sponsors'},
    {href: 'https://metabrainz.org/team', label: 'Team'},
    {
      href: 'https://www.redbubble.com/people/metabrainz/shop',
      label: 'Shop',
    },
    {href: 'https://metabrainz.org/contact', label: 'Contact us'},
  ],
  [
    {href: '/doc/About/Data_License', label: 'Data licenses'},
    {
      href: 'https://metabrainz.org/social-contract',
      label: 'Social contract',
    },
    {href: '/doc/Code_of_Conduct', label: 'Code of Conduct'},
    {href: 'https://metabrainz.org/privacy', label: 'Privacy policy'},
    {href: 'https://metabrainz.org/gdpr', label: 'GDPR compliance'},
    {
      href: '/doc/Copyright_and_DMCA_Compliance',
      label: 'Copyright and DMCA compliance',
    },
    {href: '/doc/Data_Removal_Policy', label: 'Data removal policy'},
  ],
  [
    {href: '/elections', label: 'Auto-editor elections'},
    {href: '/privileged', label: 'Privileged user accounts'},
    {href: '/statistics', label: 'Statistics'},
    {href: '/statistics/timeline', label: 'Timeline graph'},
    {href: '/history', label: 'MusicBrainz history'},
  ],
];

const productGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: '//picard.musicbrainz.org', label: 'MusicBrainz Picard'},
    {href: '/doc/AudioRanger', label: 'AudioRanger'},
    {href: '/doc/Mp3tag', label: 'Mp3tag'},
    {href: '/doc/Yate_Music_Tagger', label: 'Yate Music Tagger'},
  ],
  [
    {
      href: '/doc/MusicBrainz_for_Android',
      label: 'MusicBrainz for Android',
    },
  ],
  [
    {href: '/doc/MusicBrainz_Server', label: 'MusicBrainz Server'},
    {href: '/doc/MusicBrainz_Database', label: 'MusicBrainz Database'},
  ],
  [
    {href: '/doc/Developer_Resources', label: 'Developer resources'},
    {href: '/doc/MusicBrainz_API', label: 'MusicBrainz API'},
    {href: '/doc/Live_Data_Feed', label: 'Live Data Feed'},
  ],
];

const searchGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: '/search', label: 'Advanced search'},
    {href: '/search/edits', label: 'Edit search'},
    {context: 'folksonomy', href: '/tags', label: 'Tag cloud'},
    {href: '/cdstub/browse', label: 'Top CD stubs'},
  ],
];

const communityGroups: Array<Array<DropdownMenuItem>> = [
  [
    {href: 'https://community.metabrainz.org/', label: 'Forums'},
    {href: '/doc/Communication/ChatBrainz', label: 'Chat'},
    {href: 'https://bsky.app/profile/musicbrainz.org', label: 'Bluesky'},
    {href: 'https://mastodon.social/@musicbrainz', label: 'Mastodon'},
    {href: 'https://www.reddit.com/r/MusicBrainz/', label: 'Reddit'},
    {href: 'https://discord.gg/R4hBw972QA', label: 'Discord'},
  ],
];

const dropdownSections = {
  About: aboutGroups,
  Community: communityGroups,
  Products: productGroups,
  Search: searchGroups,
};

type Section = $Keys<typeof dropdownSections> | 'Language';

component DropDownMenu(
  label: string,
  groups: Array<Array<DropdownMenuItem>>,
) {
  return (
    <li className="nav-item dropdown d-flex align-items-center">
      <a
        aria-expanded="false"
        className="nav-link dropdown-toggle"
        data-bs-toggle="dropdown"
        href="#"
        role="button"
        title={l(label)}
      >
        {l(label)}
      </a>
      <ul className="dropdown-menu">
        {groups.map((group, gIdx) => (
          <React.Fragment key={gIdx}>

            {group.map((item, idx) => {
              const itemLabel = item.context === undefined
                ? l(item.label)
                : lp(item.label, item.context);

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

            {gIdx !== groups.length - 1 && (
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
  section: Section | null,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const groups = section && section !== 'Language'
    ? dropdownSections[section]
    : [];
  const isLanguage = section === 'Language';

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
                      title={languageName(language, isSelected)}
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
                  title={l('reset language')}
                >
                  {l('(reset language)')}
                </a>
              </li>
              <li className="border-bottom">
                <a
                  className="d-block bg-transparent text-decoration-none"
                  href="https://translations.metabrainz.org/projects/musicbrainz/"
                  onClick={onClose}
                  title={l('Help translate')}
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
                    {item.context === undefined
                      ? l(item.label)
                      : lp(item.label, item.context)}
                  </a>
                </li>
                ))}
              </ul>
            ))
          )}
        </div>
        <button
          aria-label="Close"
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
    section: Section | null,
  }>({
    isOpen: false,
    section: null,
  });

  const openMobileSidebar = (section: Section) => {
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

  const toggleMobileSidebar = (section: Section) => {
    if (mobileSidebar.isOpen && mobileSidebar.section === section) {
      closeMobileSidebar();
    } else {
      openMobileSidebar(section);
    }
  };

  const toggleLanguageSidebar = () => {
    toggleMobileSidebar('Language');
  };

  return (
    <nav
      aria-label="Offcanvas navbar large"
      className="navbar navbar-expand-lg shadow-sm"
    >
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
            alt="Search"
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
              {Object.keys(dropdownSections).map((section) => (
                <DropDownMenu
                  groups={dropdownSections[section]}
                  key={section}
                  label={section}
                />
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
                  aria-label="search"
                  className="form-control"
                  name="query"
                  placeholder="Search"
                  required
                  type="text"
                />

                <span className="input-group-text">
                  {l('in')}
                </span>

                <select
                  aria-label="Server"
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
              title={l('Advanced Search')}
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
              {Object.keys(dropdownSections).map((section) => {
                const isActive = mobileSidebar.section === section &&
                  mobileSidebar.isOpen;
                const handleClick = () => toggleMobileSidebar(section);
                return (
                  <li className="nav-item" key={section}>
                    <button
                      className={`nav-link border-0 bg-transparent
                        d-flex align-items-center ${
                        isActive ? 'active' : ''
                      }`}
                      onClick={handleClick}
                      type="button"
                    >
                      {l(section)}
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
              aria-label="Language"
              className="d-lg-none border-0 bg-transparent text-end"
              onClick={toggleLanguageSidebar}
              type="button"
            >
              <img alt="Language" height={40} src={languageIcon} width={40} />
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
                alt="Search"
                className="search-button"
                height={40}
                src={magnifyingGlass}
                width={40}
              />
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Sidebar */}
      <MobileSidebar
        isOpen={mobileSidebar.isOpen}
        onClose={closeMobileSidebar}
        section={mobileSidebar.section}
      />

      {/* Mobile Search Popup */}
      <MobileSearchPopup />
    </nav>
  );
}

export default (hydrate < React.PropsOf< Navbar >>(
  'div.new-navbar.fixed-top',
  Navbar,
): component(...React.PropsOf< Navbar >));
