/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {Swiper, SwiperSlide} from 'swiper/react';
import {Pagination, Navigation} from 'swiper';
import 'swiper/less';
import "swiper/less/grid";
import "swiper/less/pagination";
import "swiper/less/navigation";

const Supporters = (): React.Element<'div'> => (
  <div className="section-with-bg">
    <div className="title">
      <h2>Supporters</h2>
    </div>
    <Swiper
      loop
      loopFillGroupWithBlank
      modules={[Pagination, Navigation]}
      navigation
      slidesPerGroup={3}
      slidesPerView={3}
    >
      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/google.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/bbc.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/microsoft.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/amazon.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/lastfm.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/plex.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/acoustid.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/ticketmaster.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt=""
          className="slide-image"
          height="36px"
          src="/assets/img/supporters/pandora.svg"
          width="36px"
        />
      </SwiperSlide>

    </Swiper>
  </div>
);

export default Supporters;
