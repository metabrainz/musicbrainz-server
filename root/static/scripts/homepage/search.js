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

const entities = [
  { name: "Artist", value: "artist" },
  { name: "Event", value: "event" },
  { name: "Release", value: "release" },
  { name: "Release Group", value: "release-group" },
  { name: "Recording", value: "recording" },
  { name: "Series", value: "series" }, 
  { name: "Work", value: "work" },
  { name: "Area", value: "area" },
  { name: "Instrument", value: "instrument" },
  { name: "Label", value: "label" },
  { name: "Place", value: "place" },
  { name: "Annotation", value: "annotation" },
  { name: "Tag", value: "tag" },
  { name: "CD Stub", value: "cdstub" },
  { name: "Editor", value: "editor" },
  { name: "Stub", value: "stub" },
]

component Search () {
  const [searchQuery, setSearchQuery] = React.useState('');
  const [selectedEntity, setSelectedEntity] = React.useState(entities[0]);

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
    <div className="universal-search">
      <Blob width={250} height={250} randomness={1.5} className="search-vector-1" />
      <Blob width={300} height={300} randomness={2} className="search-vector-2" />
      <Blob width={300} height={300} randomness={2} className="search-vector-3" />

      <div className="search-logo-info" role="button" onClick={scrollToElement}>
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
              {entities.map((entity) => {
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
                placeholder="Search 2,664,960 Artists..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.currentTarget.value)}
                required
              />
              <button type="submit">
                <FontAwesomeIcon icon={faMagnifyingGlass} size="xl" />
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
