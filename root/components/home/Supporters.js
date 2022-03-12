/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import 'swiper/less';
import "swiper/less/grid";
import "swiper/less/pagination";
import "swiper/less/navigation";
import {Swiper, SwiperSlide} from 'swiper/react';
import {Pagination, Navigation} from 'swiper';

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
          alt="Google"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/google.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="BBC"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/bbc.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="Microsoft"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/microsoft.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="Amazon"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/amazon.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="LastFN"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/lastfm.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="Plex"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/plex.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="AcoustID"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/acoustid.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="TicketMaster"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/ticketmaster.svg"
          width="36px"
        />
      </SwiperSlide>

      <SwiperSlide>
        <img
          alt="Pandora"
          className="slide-image"
          height="36px"
          src="../../static/images/supporters/pandora.svg"
          width="36px"
        />
      </SwiperSlide>

    </Swiper>
  </div>
);

export default Supporters;
