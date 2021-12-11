/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useState} from 'react';
import {Modal} from 'react-bootstrap';

const responsive = {
  desktop: {
    breakpoint: {max: 3000, min: 1024},
    items: 3,
  },
  tablet: {
    breakpoint: {max: 1024, min: 464},
    items: 2,
  },
  mobile: {
    breakpoint: {max: 464, min: 0},
    items: 1,
  },
};

export default class Intro extends React.Component {
    state = {
      additionalTransform: 0,
      posts: [],
      data: 'Actively looking for a barcode...',
      show: false,
    };

    handleClose = () => {
      this.setState({show: false});
    }

    handleShow = () => {
      this.setState({show: true});
    }

    componentDidMount() {
      fetch(`https://itunes.apple.com/us/rss/topalbums/limit=100/json`)
        .then(response => response.json())
        .then(res => {
          this.setState({posts: res.feed.entry});
        });
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
        window.open('https://musicbrainz.org/' + 'search?type=' + searchType + '&query=' + query.value, '_newTab');
      }


      return (
        <section className={'intro d-flex align-items-center ' + this.props.theme} id="intro">
          <div className="container">
            <div className="row">
              <div className="col-lg-9 d-flex flex-column justify-content-center">
                <h1 data-bs-aos="fade-up" style={{marginTop: '20px'}}>The Music Database</h1>
                <h2 data-bs-aos="fade-up" data-bs-aos-delay="400">
                  World&apos;s Biggest Open Source Music Database
                </h2>

                <div className="row search-margins">
                  <div className="col-8 col-md-10">
                    <input
                      type="search"
name="query"
                      id="searchInputMain"
                      className="form-control special-font"
                      style={{textTransform: 'capitalize'}}
                      onKeyPress={event => {
                        if (event.key === 'Enter') {
                          const query = document.getElementById('searchInputMain');
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
                            searchType = typeCurrent.replace(' ', '_').toLowerCase();
                          }
                          window.open('https://musicbrainz.org/' + 'search?type=' + searchType + '&query=' + query.value, '_newTab');
                          return false;
                        }
                      }}
                      placeholder="Search 41,054,421 Entities"
                    />
                  </div>
                  <div className="col-4 col-md-2">
                    <button className="btn btn-b-n" onClick={searchButtonClick} type="button">
                      <i className="fab fa-searchengin" />
                    </button>
                    <button className="btn btn-b-n" onClick={this.handleShow} type="button">
                      <i className="bi bi-upc-scan" />
                    </button>

                    <Modal onHide={this.handleClose} show={this.state.show}>
                      <Modal.Header closeButton>
                        <Modal.Title>Scan Barcode</Modal.Title>
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
                        return <div className="chip chip--active" id={'type' + data.key} onClick={() => onChipClick(data.label)}>{data.label}</div>;
                      }
                      return (
                      // eslint-disable-next-line react/jsx-key
                        <div className="chip" id={'type' + data.key} onClick={() => onChipClick(data.label)}>{data.label}</div>
                      );
                    })
                  }
                </div>
                <Carousel
                  additionalTransform={-this.state.additionalTransform}
                  autoPlay
                  autoPlaySpeed={6000}
                  beforeChange={nextSlide => {
                    if (nextSlide !== 0 && this.state.additionalTransform !== 150) {
                      this.setState({additionalTransform: 150});
                    }
                    if (nextSlide === 0 && this.state.additionalTransform === 150) {
                      this.setState({additionalTransform: 0});
                    }
                  }}
                  containerClass="carousel-container-with-scrollbar"
                  infinite
                  itemClass="slider-image-item"
                  partialVisbile={false}
                  ref={el => (this.Carousel = el)}
                  responsive={responsive}
                  ssr={false}
                >
                  {
                    this.state.posts ? this.state.posts.map((artwork, indx) => {
                      return (

                        <div className="card text-left mt-5" key={indx}>
                          <img
                              style={{width: '100%', height: '250px', objectFit: 'cover'}}
                              src={artwork['im:image'][2].label} alt="Alt text"
                            />
                        </div>

                      );
                    }) : <div className="card text-left mt-5" key="1">
                      <img
                        style={{width: '100%', height: '250px', objectFit: 'cover'}}
                        src="../../../../static/images/demo.jpg" alt="Alt text"
                      />
                    </div>
                  }
                </Carousel>
              </div>
              <div className="col-lg-3 d-none d-lg-block">
                <div className="card">
                  <img alt="Blogs Logo" className="card-img-top" src="../../../../static/images/blogs.svg" />
                  <div className="card-body">
                    <h5 className="card-title text-center">
                      <span className=" color-purple">News</span>
                      {' '}
                      &
                      {' '}
                      <span className="color-orange">Updates</span>
                    </h5>
                  </div>
                  <ul className="list-group list-group-flush">
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/10/07/picard-2-7-beta-1/" rel="noopener noreferrer" target="_blank">Picard 2.7 Beta 1</a></li>
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/10/06/picard-2-6-4-released/" rel="noopener noreferrer" target="_blank">Picard 2.6.4 released</a></li>
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/10/04/musicbrainz-server-update-2021-10-04/" rel="noopener noreferrer" target="_blank">MusicBrainz Server update, 2021-10-04</a></li>
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/09/20/musicbrainz-server-update-2021-09-20/" rel="noopener noreferrer" target="_blank">MusicBrainz Server update, 2021-09-20</a></li>
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/09/06/musicbrainz-server-update-2021-09-06/" rel="noopener noreferrer" target="_blank">MusicBrainz Server update, 2021-09-06</a></li>
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/09/01/acoustic-similarity-in-acousticbrainz/" rel="noopener noreferrer" target="_blank">Acoustic similarity in AcousticBrainz</a></li>
                    <li className="list-group-item"><a className="card-link" href="https://blog.metabrainz.org/2021/08/23/gsoc-2021-pin-recordings-and-critiquebrainz-integration-in-listenbrainz/" rel="noopener noreferrer" target="_blank">GSoC 2021: Pin Recordings and CritiqueBrainz Integration in ListenBrainz</a></li>
                  </ul>
                  <div className="card-body align-items-center d-flex justify-content-center">
                    <a className="card-link" href="https://twitter.com/MusicBrainz" rel="noopener noreferrer" target="_blank">
                      {' '}
                      <i className="fab fa-twitter" />
                    </a>
                    <a className="card-link" href="https://blog.metabrainz.org" rel="noopener noreferrer" target="_blank">
                      {' '}
                      <i className="bi bi-rss-fill" />
                    </a>
                    <a className="card-link" href="https://community.metabrainz.org" rel="noopener noreferrer" target="_blank">Community Forum</a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      );
    }
}
