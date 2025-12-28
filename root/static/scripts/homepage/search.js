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
import {l} from '../common/i18n.js';

import Blob from './blob.js';
import {type WeeklyStatsT} from './stats.js';
import entities from './utils.js';

type EntityWithStatsT = {
  +name: string,
  +stat: WeeklyStatsT | void,
  +statKey: string,
  +value: string,
};

component Search (
  weeklyStats: $ReadOnlyArray<WeeklyStatsT>,
) {
  const [searchQuery, setSearchQuery] = React.useState('');

  const entitiesWithStats: $ReadOnlyArray<EntityWithStatsT> =
    entities.map((entity) => {
      const stat = weeklyStats.find((s) => s.stat === entity.statKey);
      return {name: entity.name(), statKey: entity.statKey, value: entity.value, stat};
    });

  const [selectedEntity, setSelectedEntity] =
    React.useState<EntityWithStatsT>(entitiesWithStats[0]);
  const [isModalOpen, setIsModalOpen] = React.useState(false);

  const placeholder = selectedEntity.stat && selectedEntity.stat.total > 0
    ? `Search ${selectedEntity.stat.total.toLocaleString()} ${
      selectedEntity.stat?.name || selectedEntity.name
    }...`
    : `Search ${selectedEntity.name.toLowerCase()}...`;

  const handleSearch = (e: SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    window.location.href = `/search?query=${encodeURIComponent(
      searchQuery,
    )}&type=${selectedEntity.value}`;
  };

  const scrollToElement = () => {
    const openSourceElement = document.getElementById('open-source');
    if (openSourceElement) {
      openSourceElement.scrollIntoView({behavior: 'smooth'});
    }
  };

  const handleEntitySelect = (entity: EntityWithStatsT) => {
    setSelectedEntity(entity);
    setIsModalOpen(false);
  };

  return (
    <div className="universal-search layout-width">
      <Blob
        className="search-vector-1"
        height={250}
        randomness={1.5}
        width={250}
      />
      <Blob
        className="search-vector-2"
        height={350}
        randomness={2}
        width={350}
      />
      <Blob
        className="search-vector-3"
        height={400}
        randomness={2}
        width={400}
      />

      <div
        className="search-logo-info d-none d-md-flex"
        onClick={scrollToElement}
        role="button"
      >
        <img
          alt={l('MusicBrainz open source logo')}
          className="search-logo-info-image"
          src={openSourceImage}
        />
        <img
          alt={l('MusicBrainz data provider logo')}
          className="search-logo-info-image"
          src={dataProviderImage}
        />
        <img
          alt={l('MusicBrainz ethical source logo')}
          className="search-logo-info-image"
          src={ethicalSourceImage}
        />
      </div>

      <div className="search-container">
        <h2 className="search-info-text">
          {l('The open music encyclopedia')}
        </h2>

        <form onSubmit={handleSearch}>
          <div className="search-input-container">
            <div className="search-entity-selector d-none d-md-flex">
              {entitiesWithStats.map((entity) => {
                const isSelected = selectedEntity.value === entity.value;
                const handleClick = () => setSelectedEntity(entity);
                return (
                  <div
                    className={`entity-pill ${isSelected ? 'selected' : ''}`}
                    key={entity.value}
                    onClick={handleClick}
                  >
                    <span className="entity-pill-text">{entity.name}</span>
                  </div>
                );
              })}
              <a
                className="advanced-search-text"
                href="/search"
                title={l('Advanced search')}
              >
                {l('Advanced search')}
              </a>
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
                <img
                  alt={l('Search')}
                  height={30}
                  src={searchIcon}
                  width={30}
                />
              </button>
            </div>

            <div className="mobile-entity-selector d-md-none">
              <div
                className="mobile-entity-button"
                onClick={() => setIsModalOpen(true)}
              >
                <span className="mobile-entity-text">
                  {l('in')} {selectedEntity.name}
                </span>
                <FontAwesomeIcon icon={faChevronDown} />
              </div>
              <a
                className="mobile-advanced-search-text"
                href="/search"
              >
                {l('Advanced search')}
              </a>
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
            <h3 className="mobile-entity-modal-title">
              {addColonText(l('Search in'))}
            </h3>
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
              aria-label={lp('Close', 'interactive')}
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
