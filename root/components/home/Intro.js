/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import {faSearch} from '@fortawesome/free-solid-svg-icons';

import {reduceArtistCredit}
  from '../../static/scripts/common/immutable-entities';
import {ArtworkImage} from '../Artwork';
import entityHref
  from '../../static/scripts/common/utility/entityHref';

import Blog from './Blog';

const chipData = [
  {key: 0, label: 'Artist'},
  {key: 1, label: 'Release'},
  {key: 2, label: 'Recording'},
  {key: 3, label: 'Label'},
  {key: 4, label: 'Work'},
  {key: 5, label: 'Release Group'},
  {key: 6, label: 'Area'},
  {key: 7, label: 'Place'},
  {key: 8, label: 'Annotation'},
  {key: 9, label: 'CD Stud'},
  {key: 10, label: 'Editor'},
  {key: 11, label: 'Tag'},
  {key: 12, label: 'Instrument'},
  {key: 13, label: 'Series'},
  {key: 14, label: 'Event'},
  {key: 15, label: 'Documentation'},
];

let typeCurrent = 'Artist';

const Intro = (props): React.Element<'section'> => {
  return (
    <section className="intro d-flex align-items-center" id="intro">
      <div className="container">
        <div className="row">
          <div
            className="col-lg-9 d-flex flex-column"
          >
            <h1
              className="ms-4 mt-4"
              style={{color: 'white', height: '5vh'}}
            >
              {l('The Music Database')}
            </h1>
            <h2
              className="ms-4 mt-2"
              style={{color: 'white', height: '5vh'}}
            >
              {l(`World's Biggest Open Source Music Database`)}
            </h2>
            <div className="row mt-2 ms-2 mb-2">
              <div className="col-8 col-md-10">
                <input
                  className="form-control special-font"
                  id="searchInputMain"
                  name="query"
                  onKeyDown={event => {
                    if (event.key === 'Enter') {
                      const query =
                              document.getElementById('searchInputMain');
                      console.log(query.value);
                      if (query.value.trim().length < 1) {
                        return false;
                      }
                      let searchType;
                      if (typeCurrent === 'CD Stub') {
                        searchType = 'cdstub';
                      } else if (typeCurrent === 'Documentation') {
                        searchType = 'doc';
                      } else {
                        searchType =
                                typeCurrent.replace(' ', '_').toLowerCase();
                      }
                      window.open('https://musicbrainz.org/' + 'search?type=' + searchType + '&query=' + query.value, '_self');
                      return false;
                    }
                    return false;
                  }}
                  placeholder="Search 41,054,421 Entities"
                  style={{textTransform: 'capitalize'}}
                  type="search"
                />
              </div>
              <div className="col-4 col-md-2">
                <button
                  className="btn btn-primary"
                  onClick={searchButtonClick}
                  type="button"
                >
                  <FontAwesomeIcon
                    icon={faSearch}
                    size="lg"
                  />
                </button>
              </div>
            </div>
            <div className="choice-chips mt-2 ms-4 mb-2">
              {
                chipData.map((data) => {
                  if (data.key === 0) {
                    return (
                      <div
                        className="chip chip--active"
                        id={'type' + data.key}
                        onClick={() => onChipClick(data.label)}
                      >
                        {data.label}
                      </div>
                    );
                  }
                  return (
                  // eslint-disable-next-line react/jsx-key
                    <div
                      className="chip"
                      id={'type' + data.key}
                      onClick={() => onChipClick(data.label)}
                    >
                      {data.label}
                    </div>
                  );
                })
              }
            </div>
            <div
              className="row ps-2 pe-2"
              style={{height: '40vh', overflow: 'hidden'}}
            >
              {props.recentAdditions.map((artwork, index) => (
                <ReleaseArtwork
                  artwork={artwork}
                  key={index}
                />
                  ))}
            </div>
          </div>
          <div className="col-lg-3 pe-4 d-none d-lg-block">
            <Blog blogEntries={props.blogs} />
          </div>
        </div>
      </div>
    </section>
  );
};

export default Intro;

const onChipClick = (type) => {
  const indexPrev = chipData.map(e => e.label).indexOf(typeCurrent);
  const elementPrev = document.getElementById('type' + indexPrev);
  elementPrev.className = 'chip';

  typeCurrent = type;

  const indexNew = chipData.map(e => e.label).indexOf(type);
  const elementNew = document.getElementById('type' + indexNew);
  elementNew.className = 'chip chip--active';
};

const searchButtonClick = () => {
  const query = document.getElementById('searchInputMain');
  console.log(query.value);
  if (query.value.trim().length < 1) {
    return;
  }
  let searchType;
  if (typeCurrent === 'CD Stub') {
    searchType = 'cdstub';
  } else if (typeCurrent === 'Documentation') {
    searchType = 'doc';
  } else {
    searchType = typeCurrent.replace(' ', '_').toLowerCase();
  }
  window.open('https://musicbrainz.org/' + 'search?type=' + searchType + '&query=' + query.value, '_self');
};
const ReleaseArtwork = ({
  artwork,
}: {
  +artwork: ArtworkT,
}) => {
  const release = artwork.release;
  if (!release) {
    return null;
  }
  const releaseDescription = texp.l('{entity} by {artist}', {
    artist: reduceArtistCredit(release.artistCredit),
    entity: release.name,
  });
  return (
    <div className="artwork-cont" style={{textAlign: 'center'}}>
      <div className="artwork">
        <a
          href={entityHref(release)}
          title={releaseDescription}
        >
          <ArtworkImage
            artwork={artwork}
            fallback={release.cover_art_url || ''}
            hover={releaseDescription}
          />
        </a>
      </div>
    </div>
  );
};
