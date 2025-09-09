/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons';
import { entities } from './utils';
import searchIcon from '../../images/homepage/search-bar-icon.svg';

component MobileSearchPopup() {
  const [searchQuery, setSearchQuery] = React.useState('');
  const [selectedEntity, setSelectedEntity] = React.useState(entities[0]);

  const handleSearch = (e: SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    window.location.href = `/search?query=${encodeURIComponent(searchQuery)}&type=${selectedEntity.value}`;
  };

  return (
    <div 
      className="offcanvas offcanvas-top d-lg-none" 
      tabIndex={-1}
      id="mobileSearchOffcanvas" 
      aria-labelledby="mobileSearchOffcanvasLabel"
    > 
      <div className="offcanvas-body p-0">
        <form onSubmit={handleSearch} className="d-flex flex-column gap-3 p-4 align-items-center">
          <div className="d-grid align-items-center search-container">
            <p>
              Search
            </p> 
            <select 
              id="searchEntitySelect"
              className="form-select"
              value={selectedEntity.value}
              onChange={(e) => {
                const target = e.currentTarget;
                const entity = entities.find(ent => ent.value === target.value);
                if (entity) setSelectedEntity(entity);
              }}
            >
              {entities.map((entity) => (
                <option key={entity.value} value={entity.value}>
                  {entity.name}
                </option>
              ))}
            </select>
          </div>

          <div className="search-bar">
            <input
              type="text"
              className="form-control form-control-lg"
              name="search_term"
              placeholder="Search"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.currentTarget.value)}
              required
            />
            <button type="submit">
              <img src={searchIcon} alt="Search" width={30} height={30} />
            </button>
          </div>
        </form>

        <div className="p-3 d-flex justify-content-center advanced-search">
          <a href="/search">
            <h3>
              Advanced Search
            </h3>
          </a>
        </div>
      </div>
    </div>
  );
}

export default MobileSearchPopup;
