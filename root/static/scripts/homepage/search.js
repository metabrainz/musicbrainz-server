/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {faChevronDown, faXmark} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

import dataProviderImage from '../../images/homepage/data-provider.png';
import ethicalSourceImage from '../../images/homepage/ethical-forever.png';
import openSourceImage from '../../images/homepage/open-source.png';
import searchIcon from '../../images/homepage/search-bar-icon.svg';

import Blob from './blob.js';
import {type WeeklyStatsT} from './stats.js';
import entities from './utils.js';

component Search (
  weeklyStats: $ReadOnlyArray<WeeklyStatsT>,
) {
  const [searchQuery, setSearchQuery] = React.useState('');

  const entitiesWithStats = entities.map((entity) => {
    let statKey = `count.${entity.value}`;
    if (entity.value === 'release_group') {
      statKey = 'count.releasegroup';
    }

    const stat = weeklyStats.find((s) => s.stat === statKey);
    return {...entity, stat};
  });

  const [selectedEntity, setSelectedEntity] = React.useState(entitiesWithStats[0]);
  const [isModalOpen, setIsModalOpen] = React.useState(false);

  const placeholder = selectedEntity.stat && selectedEntity.stat.total > 0
    ? `Search ${selectedEntity.stat.total.toLocaleString()} ${selectedEntity.stat?.name || selectedEntity.name}...`
    : `Search ${selectedEntity.name.toLowerCase()}...`;

  const handleSearch = (e: SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    window.location.href = `/search?query=${encodeURIComponent(searchQuery)}&type=${selectedEntity.value}`;
  };

  const scrollToElement = () => {
    const openSourceElement = document.getElementById('open-source');
    if (openSourceElement) {
      openSourceElement.scrollIntoView({behavior: 'smooth'});
    }
  };

  const handleEntitySelect = (entity: typeof entitiesWithStats[0]) => {
    setSelectedEntity(entity);
    setIsModalOpen(false);
  };

  return (
    <div className="universal-search layout-width">
      <Blob className="search-vector-1" height={250} randomness={1.5} width={250} />
      <Blob className="search-vector-2" height={350} randomness={2} width={350} />
      <Blob className="search-vector-3" height={400} randomness={2} width={400} />

      <div className="search-logo-info d-none d-md-flex" onClick={scrollToElement} role="button">
        <img
          alt="MusicBrainz Open Source Logo"
          className="search-logo-info-image"
          src={openSourceImage}
        />
        <img
          alt="MusicBrainz Data Provider Logo"
          className="search-logo-info-image"
          src={dataProviderImage}
        />
        <img
          alt="MusicBrainz Ethical Source Logo"
          className="search-logo-info-image"
          src={ethicalSourceImage}
        />
      </div>

      <div className="search-container">
        <h2 className="search-info-text">
          The open music encyclopedia
        </h2>

        <form onSubmit={handleSearch}>
          <div className="search-input-container">
            <div className="search-entity-selector d-none d-md-flex">
              {entitiesWithStats.map((entity) => {
                return (
                  <div className={`entity-pill ${selectedEntity.value === entity.value ? 'selected' : ''}`} key={entity.value} onClick={() => setSelectedEntity(entity)}>
                    <span className="entity-pill-text">{entity.name}</span>
                  </div>
                );
              })}
              <a className="advanced-search-text" href="/search" title="Advanced Search">Advanced Search</a>
            </div>

            <div className="search-bar">
              <input
                className="form-control form-control-lg"
                name="search_term"
                onChange={(e) => setSearchQuery(e.currentTarget.value)}
                placeholder={placeholder}
                required
                type="text"
                value={searchQuery}
              />
              <button type="submit">
                <img alt="Search" height={30} src={searchIcon} width={30} />
              </button>
            </div>

            <div className="mobile-entity-selector d-md-none">
              <div
                className="mobile-entity-button"
                onClick={() => setIsModalOpen(true)}
              >
                <span className="mobile-entity-text">in {selectedEntity.name}</span>
                <FontAwesomeIcon icon={faChevronDown} />
              </div>
              <a className="mobile-advanced-search-text" href="/search">Advanced search</a>
            </div>
          </div>
        </form>
      </div>

      {isModalOpen && (
        <>
          <div
            className="mobile-entity-modal-backdrop"
            onClick={() => setIsModalOpen(false)}
          />
          <div className="mobile-entity-modal">
            <h3 className="mobile-entity-modal-title">Search in:</h3>
            <div className="mobile-entity-list">
              {entitiesWithStats.map((entity) => (
                <button
                  className="mobile-entity-item"
                  key={entity.value}
                  onClick={() => handleEntitySelect(entity)}
                  type="button"
                >
                  {entity.name}
                </button>
              ))}
            </div>
            <button
              aria-label="Close"
              className="mobile-entity-modal-close"
              onClick={() => setIsModalOpen(false)}
              type="button"
            >
              <FontAwesomeIcon icon={faXmark} />
            </button>
          </div>
        </>
      )}
    </div>
  );
}

export default (hydrate<React.PropsOf<Search>>(
  'div.homepage-search',
  Search,
): component(...React.PropsOf<Search>));
