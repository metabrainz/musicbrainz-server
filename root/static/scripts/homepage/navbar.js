/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from "react";
import musicbrainzLogo from '../../images/meb-logos/MusicBrainz_logo_mini.svg';
import musicbrainzLogoIcon from '../../images/meb-logos/MusicBrainz_logo_icon.svg';
import { l, lp } from '../common/i18n.js';
import { entities } from './utils';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faMagnifyingGlass, faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
import magnifyingGlass from '../../images/icons/magnifying-glass.svg';
import magnifyingGlassTheme from '../../images/icons/magnifying-glass-theme.svg';
import advancedSearchIcon from '../../images/homepage/advanced_search.svg';
import MobileSearchPopup from './mobile-search-popup.js';
import LanguageSelector from './language.js';

const aboutGroups = [
  [
    { label: 'About MusicBrainz', href: '/doc/About' },
    { label: 'Sponsors', href: 'https://metabrainz.org/sponsors' },
    { label: 'Team', href: 'https://metabrainz.org/team' },
    { label: 'Shop', href: 'https://www.redbubble.com/people/metabrainz/shop' },
    { label: 'Contact us', href: 'https://metabrainz.org/contact' },
  ],
  [
    { label: 'Data licenses', href: '/doc/About/Data_License' },
    { label: 'Social contract', href: 'https://metabrainz.org/social-contract' },
    { label: 'Code of Conduct', href: '/doc/Code_of_Conduct' },
    { label: 'Privacy policy', href: 'https://metabrainz.org/privacy' },
    { label: 'GDPR compliance', href: 'https://metabrainz.org/gdpr' },
    { label: 'Copyright and DMCA compliance', href: '/doc/Copyright_and_DMCA_Compliance' },
    { label: 'Data removal policy', href: '/doc/Data_Removal_Policy' },
  ],
  [
    { label: 'Auto-editor elections', href: '/elections' },
    { label: 'Privileged user accounts', href: '/privileged' },
    { label: 'Statistics', href: '/statistics' },
    { label: 'Timeline graph', href: '/statistics/timeline' },
    { label: 'MusicBrainz history', href: '/history' },
  ],
];

const productGroups = [
  [
    { label: 'MusicBrainz Picard', href: '//picard.musicbrainz.org' },
    { label: 'AudioRanger', href: '/doc/AudioRanger' },
    { label: 'Mp3tag', href: '/doc/Mp3tag' },
    { label: 'Yate Music Tagger', href: '/doc/Yate_Music_Tagger' },
  ],
  [
    { label: 'MusicBrainz for Android', href: '/doc/MusicBrainz_for_Android' },
  ],
  [
    { label: 'MusicBrainz Server', href: '/doc/MusicBrainz_Server' },
    { label: 'MusicBrainz Database', href: '/doc/MusicBrainz_Database' },
  ],
  [
    { label: 'Developer resources', href: '/doc/Developer_Resources' },
    { label: 'MusicBrainz API', href: '/doc/MusicBrainz_API' },
    { label: 'Live Data Feed', href: '/doc/Live_Data_Feed' },
  ],
];

const searchGroups = [
  [
    { label: 'Advanced search', href: '/search' },
    { label: 'Edit search', href: '/search/edits' },
    { label: 'Tag cloud', href: '/tags', context: "folksonomy" },
    { label: 'Top CD stubs', href: '/cdstub/browse' },
  ],
];

const communityGroups = [
  [
    { label: 'Forums', href: 'https://community.metabrainz.org/' },
    { label: 'Chat', href: '/doc/Communication/ChatBrainz' },
    { label: 'Bluesky', href: 'https://bsky.app/profile/musicbrainz.org' },
    { label: 'Mastodon', href: 'https://mastodon.social/@musicbrainz' },
    { label: 'Reddit', href: 'https://www.reddit.com/r/MusicBrainz/' },
    { label: 'Discord', href: 'https://discord.gg/R4hBw972QA' },
  ]
]

const dropdownSections = {
  "About": aboutGroups,
  "Products": productGroups,
  "Search": searchGroups,
  "Community": communityGroups,
}

type Section = $Keys<typeof dropdownSections>;

type DropdownMenuItem = {
  label: string,
  href: string,
  context?: string,
};

component DropDownMenu(
  label: string,
  groups: DropdownMenuItem[][],
) {
  return (
    <li className="nav-item dropdown d-flex align-items-center">
      <a
        className="nav-link dropdown-toggle"
        href="#"
        role="button"
        data-bs-toggle="dropdown"
        aria-expanded="false"
      >
        {l(label)}
      </a>
      <ul className="dropdown-menu">
        {groups.map((group, gIdx) => (
          <React.Fragment key={gIdx}>
            {group.map((item, idx) => (
              <li key={idx}>
                <a className="dropdown-item" href={item.href}>
                  {item.context !== undefined ? lp(item.label, item.context) : l(item.label)}
                </a>
              </li>
            ))}
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
  const groups = section ? dropdownSections[section] : [];

  return (
    <>
      <div 
        className={`mobile-sidebar-backdrop ${isOpen ? "open" : ''}`} 
        onClick={onClose} 
      />
      <div className={`mobile-sidebar ${isOpen ? 'open' : ''}`}>
        <div className="offcanvas-body">
          {groups.map((group, gIdx) => (
            <ul className="list-unstyled mb-0" key={gIdx}>
              {group.map((item, idx) => (
              <li key={idx} className="border-bottom">
                <a 
                  href={item.href} 
                  className="d-block bg-transparent text-decoration-none"
                  onClick={onClose}
                >
                  {item.context !== undefined ? lp(item.label, item.context) : l(item.label)}
                </a>
              </li>
              ))}
            </ul>
          ))}
        </div>
        <button 
          type="button" 
          onClick={onClose}
          aria-label="Close"
        >
          <FontAwesomeIcon icon={faChevronLeft} size="xl" color="white" />
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

  const closeMobileSidebar = () => {
    setMobileSidebar((prev) => ({
      ...prev,
      isOpen: false,
    }));
  };

  const toggleMobileSidebar = (section: Section) => {
    if (mobileSidebar.isOpen && mobileSidebar.section === section) {
      closeMobileSidebar();
    } else {
      openMobileSidebar(section);
    }
  };

  return (
    <nav className="navbar navbar-expand-lg shadow-sm" aria-label="Offcanvas navbar large">
      <div className="container-fluid gap-4 position-relative layout-width">
        <button
          className="navbar-toggler position-absolute"
          type="button"
          data-bs-toggle="offcanvas"
          data-bs-target="#offcanvasNavbar"
          aria-controls="offcanvasNavbar"
        >
          <span className="navbar-toggler-icon" />
        </button>

        <a className="navbar-brand mx-auto" href="#">
          <img src={musicbrainzLogo} alt="MusicBrainz" width={200} height={40} />
        </a>

        <button
          type="button"
          data-bs-toggle="offcanvas"
          data-bs-target="#mobileSearchOffcanvas"
          aria-controls="mobileSearchOffcanvas"
          className="d-lg-none position-absolute end-0 pe-2 border-0 bg-transparent"
        >
          <img src={magnifyingGlassTheme} alt="Search" className="search-button-mobile" />
        </button>

        <div className="offcanvas offcanvas-start gap-3" id="offcanvasNavbar" data-bs-scroll="true">
          <div className="offcanvas-header">
            <img src={musicbrainzLogoIcon} alt="MusicBrainz" height={40} />
          </div>
          <div className="offcanvas-body gap-3">
            <ul className="d-none d-lg-flex navbar-nav flex-grow-1 gap-3" id="offcanvasNavbarMenu">
              {Object.keys(dropdownSections).map((section) => (
                <DropDownMenu key={section} label={section} groups={dropdownSections[section]} />
              ))}

              {/* Language Selector */}
              <li className="nav-item dropdown d-flex">
                <LanguageSelector />
              </li>
            </ul>

            <form className="d-none d-lg-flex mt-3 mt-lg-0" role="search" action="/search" method="get">
              <div className="input-group">
                <input
                  type="text"
                  className="form-control"
                  aria-label="search"
                  name="query"
                  placeholder="Search"
                  required
                />

                <span className="input-group-text">
                  in
                </span>

                <select className="form-select" aria-label="Server" name="type">
                  {entities.map((entity) => (
                    <option key={entity.value} value={entity.value}>{entity.name}</option>
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
              className="btn search-button advanced-search-button d-none d-lg-block"
              href="/search"
            >
              <img src={advancedSearchIcon} alt="Advanced Search" width={20} height={20} />
            </a>

            {/* Mobile Menu */}
            <ul className="d-lg-none navbar-nav flex-grow-1 gap-3 align-items-end" id="offcanvasNavbarMenuMobile">
              {Object.keys(dropdownSections).map((section) => {
                const isActive = mobileSidebar.section === section && mobileSidebar.isOpen;
                return (
                  <li className="nav-item" key={section}>
                    <button
                      className={`nav-link border-0 bg-transparent d-flex align-items-center ${isActive ? 'active' : ''}`}
                      onClick={() => toggleMobileSidebar(section)}
                    >
                      {l(section)}
                      <FontAwesomeIcon icon={faChevronRight} className={isActive ? 'active' : ''} />
                    </button>
                  </li>
                );
              })}
            </ul>

            <button
              type="button"
              data-bs-toggle="offcanvas"
              data-bs-target="#mobileSearchOffcanvas"
              aria-controls="mobileSearchOffcanvas"
              className="d-lg-none border-0 bg-transparent text-end"
              onClick={() => closeMobileSidebar()}
            >
              <img src={magnifyingGlass} alt="Search" width={40} height={40} className="search-button" />
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
};

export default (hydrate < React.PropsOf < Navbar >> (
  'div.new-navbar.fixed-top',
  Navbar,
): component(...React.PropsOf < Navbar >));