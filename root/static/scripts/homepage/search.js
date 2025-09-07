/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import openSourceImage from '../../images/homepage/open-source.png';
import dataProviderImage from '../../images/homepage/data-provider.png';
import ethicalSourceImage from '../../images/homepage/ethical-forever.png';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons';
import Blob from './blob.js';
import { entities } from './utils';
import { type WeeklyStatsT } from './stats';
import searchIcon from '../../images/homepage/search-bar-icon.svg';

component Search (
  weeklyStats: $ReadOnlyArray<WeeklyStatsT>,
) {
  const [searchQuery, setSearchQuery] = React.useState('');

  const entitiesWithStats = entities.map((entity) => {
    let statKey = `count.${entity.value}`;
    if (entity.value === "release_group") {
      statKey = "count.releasegroup";
    }

    const stat = weeklyStats.find((s) => s.stat === statKey);
    return { ...entity, stat };
  });

  const [selectedEntity, setSelectedEntity] = React.useState(entitiesWithStats[0]);

  const placeholder = selectedEntity.stat && selectedEntity.stat.total > 0
  ? `Search ${selectedEntity.stat.total.toLocaleString()} ${selectedEntity.stat?.name || selectedEntity.name}...`
  : `Search ${selectedEntity.name.toLowerCase()}...`;

  const handleSearch = (e: SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    window.location.href = `/search?query=${encodeURIComponent(searchQuery)}&type=${selectedEntity.value}`;
  }

  const scrollToElement = () => {
    const openSourceElement = document.getElementById('open-source');
    if (openSourceElement) {
      openSourceElement.scrollIntoView({ behavior: 'smooth' });
    }
  }

  return (
    <div className="universal-search layout-width">
      <Blob width={250} height={250} randomness={1.5} className="search-vector-1" />
      <Blob width={350} height={350} randomness={2} className="search-vector-2" />
      <Blob width={400} height={400} randomness={2} className="search-vector-3" />

      <div className="search-logo-info d-none d-md-flex" role="button" onClick={scrollToElement}>
        <img
          className="search-logo-info-image"
          src={openSourceImage}
          alt="MusicBrainz Open Source Logo"
        />
        <img
          className="search-logo-info-image"
          src={dataProviderImage}
          alt="MusicBrainz Data Provider Logo"
        />
        <img
          className="search-logo-info-image"
          src={ethicalSourceImage}
          alt="MusicBrainz Ethical Source Logo"
        />
      </div>

      <div className="search-container">
        <h2 className="search-info-text">
          The open music encyclopedia
        </h2>

        <form onSubmit={handleSearch}>
          <div className="search-input-container">
            <div className="search-entity-selector">
              {entitiesWithStats.map((entity) => {
                return (
                  <div className={`entity-pill ${selectedEntity.value === entity.value ? 'selected' : ''}`} key={entity.value} onClick={() => setSelectedEntity(entity)}>
                    <span className="entity-pill-text">{entity.name}</span>
                  </div>
                )
              })}
              <a href="/search" className="advanced-search-text">Advanced Search</a>
            </div>

            <div className="search-bar">
              <input
                type="text"
                className="form-control form-control-lg"
                name="search_term"
                placeholder={placeholder}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.currentTarget.value)}
                required
              />
              <button type="submit">
                <img src={searchIcon} alt="Search" width={30} height={30} />
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  )
}

export default (hydrate<React.PropsOf<Search>>(
  'div.homepage-search',
  Search,
): component(...React.PropsOf<Search>));
