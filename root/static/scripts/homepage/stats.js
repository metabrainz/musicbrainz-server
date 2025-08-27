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

export type WeeklyStatsT = {
  +name: string,
  +stat: string,
  +count: number,
  +total: number,
};

component Stats(
  weeklyStats: $ReadOnlyArray<WeeklyStatsT>,
) {
  return (
    <div className="stats-container" id="stats-container">
      <Swiper
        navigation={true}
        slidesPerView="auto"
        spaceBetween={30}
        centeredSlides
        modules={[Navigation]}
      >
        {weeklyStats.map((stat, index) => (
          <SwiperSlide key={index}>
            <div className="stat-card">
              <h2>+ {stat.count.toLocaleString()} {stat.name} last week</h2>
              <p className="d-flex align-items-center gap-2">
                {stat.total.toLocaleString()} total
                <a
                  href={`/statistics/timeline/${stat.stat}#r`}
                  target="_blank"
                  rel="noopener noreferrer"
                  title="View detailed statistics"
                >
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
