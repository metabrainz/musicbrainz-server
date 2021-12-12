/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ThemeSwitchButton from '../../Utils/ThemeSwitchButton/ThemeSwitchButton';

import SearchOverlay from './SearchOverlay';

export default function Header(props) {
  let typeCurrent = 'Artist';

  return (
    <>
      <SearchOverlay theme={props.theme} />
      <nav className={'navbar navbar-default navbar-trans navbar-expand-lg fixed-top ' + props.theme}>
        <div className="container">
          <button aria-controls="navbarDefault" aria-expanded="false" aria-label="Toggle navigation" className="navbar-toggler collapsed" data-bs-target="#navbarDefault" data-bs-toggle="collapse" type="button">
            <span />
            <span />
            <span />
          </button>
          <img alt="image" className="d-none d-lg-block" height="36" src="../../../../static/images/meb-mini/musicbrainz.svg" />
          <a className="navbar-brand text-brand" href="#">
            <span className="color-purple">Music</span>
            <span className="color-orange">Brainz</span>
          </a>

          <div className="navbar-collapse collapse justify-content-center" id="navbarDefault">
            <ul className="navbar-nav">
              <li className="nav-item dropdown">
                <a aria-expanded="false" aria-haspopup="true" className="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" id="navbarDropdown" role="button">English</a>
                <div className="dropdown-menu">
                  <a className="dropdown-item ">Deutsch</a>
                  <a className="dropdown-item ">English</a>
                  <a className="dropdown-item ">Français</a>
                  <a className="dropdown-item ">Italiano</a>
                  <a className="dropdown-item ">Nederlands</a>
                  <a className="dropdown-item ">(Reset Language)</a>
                  <div className="dropdown-divider" />
                  <a className="dropdown-item">Help Translate</a>
                </div>
              </li>

              <li className="nav-item">
                <a className="nav-link " href="https://musicbrainz.org/doc/MusicBrainz_Documentation" rel="noopener noreferrer" target="_blank">Docs</a>
              </li>

              <li className="nav-item">
                <a className="nav-link " href="https://musicbrainz.org/doc/MusicBrainz_API" rel="noopener noreferrer" target="_blank">API</a>
              </li>

              <li className="nav-item">
                <a className="nav-link " href="https://blog.metabrainz.org" rel="noopener noreferrer" target="_blank">Community</a>
              </li>

              <li className="nav-item dropdown">
                <a aria-expanded="false" aria-haspopup="true" className="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" id="navbarDropdown" role="button">Username</a>
                <div className="dropdown-menu">
                  <a className="dropdown-item ">Profile</a>
                  <a className="dropdown-item ">Applications</a>
                  <a className="dropdown-item ">Subscriptions</a>
                  <ThemeSwitchButton
                    changeTheme={props.switchActiveTheme}
                    dark={props.isDarkThemeActive}
                  />
                  <a className="dropdown-item ">Logout</a>
                </div>
              </li>
            </ul>

          </div>
          <div className="d-none d-lg-block general-margins">
            <input
              className="form-control"
              id="searchInputHeader"
              name="query"
              onKeyPress={event => {
                if (event.key === 'Enter') {
                  const query = document.getElementById('searchInputHeader');
                  console.log(query.value);
                  if (query.value.trim().length < 1) {
                    return false;
                  }
                  let searchType;
                  typeCurrent = document.getElementById('typeHeader').value;
                  if (typeCurrent === 'CD Stud') {
                    searchType = 'cdstub';
                  } else if (typeCurrent === 'Documentation') {
                    searchType = 'doc';
                  } else {
                    searchType = typeCurrent.replace(' ', '_').toLowerCase();
                  }
                  window.open('https://musicbrainz.org/' + 'search?type=' + searchType + '&query=' + query.value, '_newTab');
                  return false;
                }
              }}
              placeholder="Search"
              style={{textTransform: 'capitalize'}}
              type="search"
            />
          </div>

          <div className="d-none d-lg-block general-margins">
            <select className="form-control" id="typeHeader" name="type">
              <option>Artist</option>
              <option>Release</option>
              <option>Recording</option>
              <option>Label</option>
              <option>Work</option>
              <option>Release Group</option>
              <option>Area</option>
              <option>Place</option>
              <option>Annotation</option>
              <option>CD Stud</option>
              <option>Editor</option>
              <option>Tag</option>
              <option>Instrument</option>
              <option>Series</option>
              <option>Event</option>
              <option>Documentation</option>

            </select>
          </div>
          <button className="btn btn-b-n" onClick={attach} type="button">
            <i className="bi bi-search" />
          </button>

        </div>
      </nav>
    </>
  );
}

const attach = e => {
  e.preventDefault();
  const query = document.getElementById('searchInputHeader');

  if (query.value.length > 1) {
    let searchType;
    const typeCurrent = document.getElementById('typeHeader').value;
    if (typeCurrent === 'CD Stub') {
      searchType = 'cdstub';
    } else if (typeCurrent === 'Documentation') {
      searchType = 'doc';
    } else {
      searchType = typeCurrent.replace(' ', '_').toLowerCase();
    }
    window.open('https://musicbrainz.org/' + 'search?type=' + searchType + '&query=' + query.value, '_newTab');
    return;
  }
  document.body.classList.add('box-collapse-open');
  document.body.classList.remove('box-collapse-closed');
};
