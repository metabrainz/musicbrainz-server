/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {Autoplay, Navigation} from 'swiper/modules';
import {Swiper, SwiperSlide} from 'swiper/react';

import magnifyingGlass from '../../images/icons/magnifying-glass.svg';
import {l} from '../common/i18n.js';

export type WeeklyStatsT = {
  +count: number,
  +name: string,
  +stat: string,
  +total: number,
};

const entitiesForStats = [
  'edits',
  'votes',
  'ratings',
  'artists',
  'releases',
  'recordings',
  'works',
  'labels',
  'tracks',
  'events',
  'editors',
  'places',
  'series',
  'tags',
  'release groups',
];


component Stats(
  weeklyStats: $ReadOnlyArray<WeeklyStatsT>,
) {
  // Filter the stats which need to be displayed in the carousel
  const filteredStats = weeklyStats.filter(
    (stat) => entitiesForStats.includes(stat.name),
  );

  if (filteredStats.length === 0) {
    return null;
  }

  return (
    <Swiper
      autoplay={{
        delay: 2500,
        pauseOnMouseEnter: true,
      }}
      centeredSlides
      loop
      modules={[Navigation, Autoplay]}
      navigation
      slidesPerView="auto"
      spaceBetween={30}
    >
      {filteredStats.map((stat, index) => (
        <SwiperSlide key={index}>
          <div className="stat-card">
            <h2>
              {stat.count > 0
                ? `+${stat.count.toLocaleString()}`
                : stat.count.toLocaleString()}
{' '}
              {stat.name}
{' '}
{l('last week')}
            </h2>
            <p className="d-flex align-items-center gap-2">
              {stat.total.toLocaleString()}
{' '}
              {l('total')}
              <a
                href={`/statistics/timeline/${stat.stat}#r`}
                rel="noopener noreferrer"
                target="_blank"
                title={l('View detailed statistics')}
              >
                <img alt={l('Magnifying glass')} src={magnifyingGlass} />
              </a>
            </p>
          </div>
        </SwiperSlide>
      ))}
    </Swiper>
  );
}

export default (hydrate<React.PropsOf<Stats>>(
  'div.stats-container',
  Stats,
): component(...React.PropsOf<Stats>));
