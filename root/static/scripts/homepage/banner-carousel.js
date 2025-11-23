/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {faAngleRight} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

// $FlowFixMe[untyped-import]
import {Autoplay, Navigation} from 'swiper/modules';

// $FlowFixMe[untyped-import]
import {Swiper, SwiperSlide} from 'swiper/react';

import listenBrainzImage from '../../images/homepage/LB-Headphone.png';
import picardImage from '../../images/homepage/picard.png';
import listenBrainzLogo from '../../images/meb-logos/Listenbrainz_logo_icon.svg';
import picardLogo from '../../images/meb-logos/Picard_logo_icon.svg';

import Blob from './blob.js';

component BannerCarousel() {
  return (
    <Swiper
      autoplay={{
        delay: 5000,
        pauseOnMouseEnter: true,
      }}
      loop
      modules={[Navigation, Autoplay]}
      navigation
    >
      <SwiperSlide className="carousel-slide-1">
        <div className="carousel-slide">
          <div className="carousel-slide-content">
            <img alt="Tag your music" src={picardImage} />
            <div className="d-flex flex-column gap-3 carousel-slide-content-text">
              <h2>Tag your music</h2>
              <a href="https://picard.musicbrainz.org/">
                <div className="carousel-pill d-flex gap-2">
                <img alt="Picard" className="picard-logo" src={picardLogo} />
                  MusicBrainz Picard
                </div>
              </a>
              <div className="d-flex gap-3">
                <a href="/doc/AudioRanger">
                  AudioRanger
                </a>
                <a href="/doc/Mp3tag">
                  Mp3tag
                </a>
                <a href="/doc/Yate_Music_Tagger">
                  Yate
                </a>
              </div>
            </div>
          </div>
          <Blob className="slide-vector-1" height={300} randomness={2} width={300} />
          <Blob className="slide-vector-2" height={100} randomness={2} width={100} />
        </div>
      </SwiperSlide>
      <SwiperSlide className="carousel-slide-2">
        <div className="carousel-slide">
          <div className="carousel-slide-content">
            <img alt="Listen together" className="listenbrainz-image" src={listenBrainzImage} />
            <div className="d-flex flex-column gap-3 carousel-slide-content-text" id="listenbrainz-content">
              <h2>Listen together</h2>
              <a href="https://listenbrainz.org/">
               <div className="carousel-pill d-flex gap-2">
                <img alt="ListenBrainz" className="listenbrainz-logo" src={listenBrainzLogo} />
                 with ListenBrainz
               </div>
              </a>
              <div className="d-flex gap-3 align-items-center">
                <FontAwesomeIcon color="#1E1E1E" icon={faAngleRight} size="sm" />
                <a href="https://listenbrainz.org/">
                  Explore the music you listen to.
                </a>
              </div>
            </div>
          </div>
          <Blob className="slide-vector-3" height={100} randomness={2} width={100} />
          <Blob className="slide-vector-4" height={300} randomness={2} width={300} />
        </div>
      </SwiperSlide>
    </Swiper>
  );
}

export default (hydrate<React.PropsOf<BannerCarousel>>(
  'div.carousel-container',
  BannerCarousel,
): component(...React.PropsOf<BannerCarousel>));
