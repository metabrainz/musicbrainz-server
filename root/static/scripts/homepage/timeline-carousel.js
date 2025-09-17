/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import timelineImage from '../../images/homepage/timeline-image.png'
// $FlowFixMe[untyped-import]
import { Swiper, SwiperSlide } from 'swiper/react';
// $FlowFixMe[untyped-import]
import { Navigation } from 'swiper/modules';
import {faPlusCircle} from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

component TimelineImage() {
  return (
    <div className="timeline-image-container">
      <div className="timeline-item">
        <div
          className="timeline-coverart-container"
          role="button"
          tabIndex={0}
        >
          <img
            src={timelineImage}
            width="150px"
          />
          <div className="hover-backdrop">
            <p>
              Release Name
            </p>
            <p>
              By Artist Name
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

const arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

component TimelineCarousel() {
  return (
    <>
      <div className='timeline-carousel-text'>
        Now
      </div>
      <Swiper
        navigation={true}
        slidesPerView="auto"
        spaceBetween={24}
        modules={[Navigation]}
      >
        {arr.map((_, index) => (
          <SwiperSlide key={index}>
            <TimelineImage />
          </SwiperSlide>
        ))}
      </Swiper>
    </>
  );
}

export default (hydrate <React.PropsOf<TimelineCarousel>> (
  'div.timeline-carousel',
  TimelineCarousel,
): component(...React.PropsOf <TimelineCarousel>));
