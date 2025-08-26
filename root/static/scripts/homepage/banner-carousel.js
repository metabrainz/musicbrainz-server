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
import { faAngleRight } from '@fortawesome/free-solid-svg-icons';
// $FlowFixMe[untyped-import]
import { Swiper, SwiperSlide } from 'swiper/react';
// $FlowFixMe[untyped-import]
import { Navigation } from 'swiper/modules';

import picardImage from "../../../static/images/homepage/picard.png"
import picardLogo from "../../../static/images/meb-logos/Picard_logo_icon.svg"
import listenBrainzImage from "../../../static/images/homepage/LB-Headphone.svg"
import listenBrainzLogo from "../../../static/images/meb-logos/Listenbrainz_logo_icon.svg"
import Blob from './blob.js';

component BannerCarousel() {
  return (
    <div className="carousel-container" id="banner-carousel">
      <Swiper
        navigation={true}
        loop={true}
        modules={[Navigation]}
      >
        <SwiperSlide>
          <div className="carousel-slide carousel-slide-1">
            <div className="carousel-slide-content">
              <img src={picardImage} alt="Tag your music" />
              <div className="d-flex flex-column gap-3">
                <h2>Tag your music</h2>
                <div className="carousel-pill d-flex gap-2">
                  <img src={picardLogo} alt="Picard" className="picard-logo" />
                  <a href="https://picard.musicbrainz.org/" target="_blank" rel="noopener noreferrer">
                    MusicBrainz Picard
                  </a>
                </div>
                <div className="d-flex gap-3">
                  <a href="https://musicbrainz.org/doc/AudioRanger" target="_blank" rel="noopener noreferrer">
                    AudioRanger
                  </a>
                  <a href="https://musicbrainz.org/doc/Mp3tag" target="_blank" rel="noopener noreferrer">
                    Mp3tag
                  </a>
                  <a href="https://musicbrainz.org/doc/Yate_Music_Tagger" target="_blank" rel="noopener noreferrer">
                    Yate
                  </a>
                </div>
              </div>
            </div>
            <Blob width={300} height={300} randomness={2} className="slide-vector-1" />
            <Blob width={100} height={100} randomness={2} className="slide-vector-2" />
          </div>
        </SwiperSlide>
        <SwiperSlide>
          <div className="carousel-slide carousel-slide-2">
          <div className="carousel-slide-content">
              <img src={listenBrainzImage} alt="Listen together" className="listenbrainz-image" />
              <div className="d-flex flex-column gap-3">
                <h2>Listen together</h2>
                <div className="carousel-pill d-flex gap-2">
                  <img src={listenBrainzLogo} alt="ListenBrainz" className="listenbrainz-logo" />
                  <a href="https://listenbrainz.org/" target="_blank" rel="noopener noreferrer">
                    with ListenBrainz
                  </a>
                </div>
                <div className="d-flex gap-3 align-items-center">
                  <FontAwesomeIcon icon={faAngleRight} size="sm" color='#1E1E1E' /> 
                  <a href="https://listenbrainz.org/" target="_blank" rel="noopener noreferrer">
                    Explore the music you listen to.
                  </a>
                </div>
              </div>
            </div>
            <Blob width={100} height={100} randomness={2} className="slide-vector-3" />
            <Blob width={300} height={300} randomness={2} className="slide-vector-4" />
          </div>
        </SwiperSlide>
      </Swiper>
    </div>
  );
};

export default (hydrate<React.PropsOf<BannerCarousel>>(
  'div.banner-carousel',
  BannerCarousel,
): component(...React.PropsOf<BannerCarousel>));
