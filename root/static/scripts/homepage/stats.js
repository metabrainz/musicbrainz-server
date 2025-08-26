/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from "react";
// $FlowFixMe[untyped-import]
import { Swiper, SwiperSlide } from 'swiper/react';
// $FlowFixMe[untyped-import]
import { Navigation } from 'swiper/modules';
import magnifyingGlass from '../../images/icons/magnifying-glass.svg';


const statsData = [
  {
    entity: "artists",
    count: 9284928,
    total: 10000000,
    url: "https://musicbrainz.org/statistics/timeline/count.edit#r"
  },
  {
    entity: "releases",
    count: 74834,
    total: 10000000,
    url: "https://musicbrainz.org/statistics/timeline/count.edit#r"
  },
  {
    entity: "tracks",
    count: 1833452,
    total: 10000000,
    url: "https://musicbrainz.org/statistics/timeline/count.edit#r"
  },
  {
    entity: "recordings",
    count: 453534,
    total: 10000000,
    url: "https://musicbrainz.org/statistics/timeline/count.edit#r"
  },
  {
    entity: "works",
    count: 12345,
    total: 10000000,
    url: "https://musicbrainz.org/statistics/timeline/count.edit#r"
  },
  {
    entity: "labels",
    count: 34535,
    total: 10000000,
    url: "https://musicbrainz.org/statistics/timeline/count.edit#r"
  }
]

component Stats() {
  return (
    <div className="stats-container" id="stats-container">
      <Swiper
        navigation={true}
        slidesPerView="auto"
        spaceBetween={30}
        centeredSlides
        modules={[Navigation]}
      >
        {statsData.map((stat, index) => (
          <SwiperSlide key={index}>
            <div className="stat-card">
              <h2>+ {stat.count.toLocaleString()} {stat.entity} last week</h2>
              <p className="d-flex align-items-center gap-2">
                {stat.total.toLocaleString()} total
                <a href={stat.url} target="_blank" rel="noopener noreferrer" title="View detailed statistics">
                  <img src={magnifyingGlass} alt="Magnifying glass" />
                </a>
              </p>
            </div>
          </SwiperSlide>
        ))}
      </Swiper>
    </div>
  )
}

export default (hydrate<React.PropsOf<Stats>>(
  'div.stats-container',
  Stats,
): component(...React.PropsOf<Stats>));
