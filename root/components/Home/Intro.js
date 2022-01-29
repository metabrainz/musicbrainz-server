/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import {Modal} from 'react-bootstrap';

import Blog from './Blog';

class Intro extends React.Component {
    state = {
      data: 'Actively looking for a barcode...',
      show: false,
    };

    handleClose = () => {
      this.setState({show: false});
    }

    handleShow = () => {
      this.setState({show: true});
    }

    render() {
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

      function onChipClick(type) {
        const indexPrev = chipData.map(e => e.label).indexOf(typeCurrent);
        const elementPrev = document.getElementById('type' + indexPrev);
        elementPrev.className = 'chip';

        typeCurrent = type;

        const indexNew = chipData.map(e => e.label).indexOf(type);
        const elementNew = document.getElementById('type' + indexNew);
        elementNew.className = 'chip chip--active';
      }

      function searchButtonClick() {
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
        window.open('https://musicbrainz.org/' +
        'search?type=' +
        searchType +
        '&query=' +
        query.value, '_newTab');
      }

      return (
        <section
          className={'intro d-flex align-items-center ' +
          this.props.theme}
          id="intro"
        >
          <div className="container">
            <div className="row">
              <div
                className="col-lg-9 d-flex flex-column justify-content-center"
              >
                <h1
                  data-bs-aos="fade-up"
                  style={{marginTop: '20px'}}
                >
                  {l(`The Music Database`)}
                </h1>
                <h2
                  data-bs-aos="fade-up"
                  data-bs-aos-delay="400"
                >
                  {l(`World's Biggest Open Source Music Database`)}
                </h2>

                <div className="row search-margins">
                  <div className="col-8 col-md-10">
                    <input
                      className="form-control special-font"
                      id="searchInputMain"
                      name="query"
                      onKeyPress={event => {
                        if (event.key === 'Enter') {
                          const query = document
                            .getElementById('searchInputMain');
                          console.log(query.value);
                          if (query.value.trim().length < 1) {
                            return false;
                          }
                          let searchType;
                          if (typeCurrent === 'CD Stud') {
                            searchType = 'cdstub';
                          } else if (typeCurrent === 'Documentation') {
                            searchType = 'doc';
                          } else {
                            searchType = typeCurrent
                              .replace(' ', '_')
                              .toLowerCase();
                          }
                          window.open('https://musicbrainz.org/' +
                          'search?type=' +
                          searchType +
                          '&query=' +
                          query.value, '_newTab');
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
                      className="btn btn-b-n"
                      onClick={searchButtonClick}
                      type="button"
                    >
                      <i className="fab fa-searchengin" />
                    </button>
                    <button
                      className="btn btn-b-n"
                      onClick={this.handleShow}
                      type="button"
                    >
                      <i className="bi bi-upc-scan" />
                    </button>

                    <Modal
                      onHide={this.handleClose}
                      show={this.state.show}
                    >
                      <Modal.Header closeButton>
                        <Modal.Title>
                          {l(`Scan Barcode`)}
                        </Modal.Title>
                      </Modal.Header>
                      <Modal.Body />
                      <Modal.Footer>
                        <p>{this.state.data}</p>
                      </Modal.Footer>
                    </Modal>
                  </div>
                </div>
                <div className="choiceChips">
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
              </div>
              <div className="col-lg-3 d-none d-lg-block">
                <Blog />
              </div>
            </div>
          </div>
        </section>
      );
    }
}
export default (hydrate<Props>(
  'div.intro',
  Intro,
): React.AbstractComponent<Props, void>);
