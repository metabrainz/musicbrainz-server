/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  faPauseCircle,
  faPlayCircle,
  faPlusCircle,
} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

// $FlowExpectedError[untyped-import]
import {LazyLoadImage} from 'react-lazy-load-image-component';

// $FlowExpectedError[untyped-import]
import {Autoplay, Mousewheel, Navigation} from 'swiper/modules';

// $FlowExpectedError[untyped-import]
import {Swiper, SwiperSlide} from 'swiper/react';

import timelineCoverartPlaceholder
  from '../../images/homepage/timeline-coverart-placeholder.png';
import {l} from '../common/i18n.js';
import {reduceArtistCredit} from '../common/immutable-entities.js';
import entityHref from '../common/utility/entityHref.js';

component ReleaseTimelineImage(artwork: ReleaseArtT) {
  const release = artwork.release;
  const [imageLoaded, setImageLoaded] = React.useState<boolean>(false);

  const handleImageLoad = React.useCallback(() => {
    setImageLoaded(true);
  }, []);

  if (!release) {
    return null;
  }

  const artist = reduceArtistCredit(release.artistCredit);

  const releaseDescription = texp.l('{entity} by {artist}', {
    artist,
    entity: release.name,
  });

  return (
    <div className="timeline-image-container">
      <div className="timeline-item">
        <a
          className="timeline-coverart-container"
          href={entityHref(release)}
          role="button"
          style={{
            overflow: 'hidden',
          }}
          tabIndex={0}
        >
          <img
            alt={release.name}
            src={timelineCoverartPlaceholder}
            style={{
              display: imageLoaded ? 'none' : 'block',
              height: '150px',
              objectFit: 'cover',
              width: '150px',
            }}
            title={releaseDescription}
          />
          <LazyLoadImage
            alt={release.name}
            onLoad={handleImageLoad}
            src={artwork.small_ia_thumbnail}
            style={{
              height: '150px',
              objectFit: 'cover',
              width: '150px',
            }}
            title={releaseDescription}
          />
          <div className="hover-backdrop">
            <p>
              {release.name}
            </p>
            <p>
              {texp.l('By {artist}', {
                artist: reduceArtistCredit(release.artistCredit),
              })}
            </p>
          </div>
        </a>
      </div>
    </div>
  );
}

component EventTimelineImage(artwork: EventArtT) {
  const event = artwork.event;
  const [imageLoaded, setImageLoaded] = React.useState<boolean>(false);

  const handleImageLoad = React.useCallback(() => {
    setImageLoaded(true);
  }, []);

  if (!event) {
    return null;
  }

  const eventDescription = texp.l('{entity}', {
    entity: event.name,
  });

  return (
    <div className="timeline-image-container">
      <div className="timeline-item">
        <a
          className="timeline-coverart-container"
          href={entityHref(event)}
          role="button"
          style={{
            overflow: 'hidden',
          }}
          tabIndex={0}
        >
          <img
            alt={event.name}
            src={timelineCoverartPlaceholder}
            style={{
              display: imageLoaded ? 'none' : 'block',
              height: '150px',
              objectFit: 'cover',
              width: '150px',
            }}
            title={eventDescription}
          />
          <LazyLoadImage
            alt={event.name}
            className={`${imageLoaded ? '' : 'hidden'}`}
            onLoad={handleImageLoad}
            src={artwork.small_ia_thumbnail}
            style={{
              height: '150px',
              objectFit: 'cover',
              width: '150px',
            }}
            title={eventDescription}
          />
          <div className="hover-backdrop">
            <p>
              {event.name}
            </p>
          </div>
        </a>
      </div>
    </div>
  );
}

component TimelineCarousel(
  newestReleaseArtwork?: $ReadOnlyArray<ReleaseArtT>,
  freshReleaseArtwork?: $ReadOnlyArray<ReleaseArtT>,
  newestEventArtwork?: $ReadOnlyArray<EventArtT>,
  freshEventArtwork?: $ReadOnlyArray<EventArtT>,
  entityType: 'release' | 'event',
) {
  const [mode, setMode] = React.useState<'fresh' | 'new'>('fresh');
  const [autoPlay, setAutoPlay] = React.useState<boolean>(true);
  const swiperRef = React.useRef<React.ElementRef<typeof Swiper>>(null);

  const handleFreshPillClick = React.useCallback(() => {
    setMode('fresh');
  }, []);

  const handleNewPillClick = React.useCallback(() => {
    setMode('new');
  }, []);

  const toggleAutoPlay = React.useCallback(() => {
    setAutoPlay((currentAutoPlayState) => {
      if (currentAutoPlayState) {
        swiperRef.current.swiper.autoplay.stop();
      } else {
        swiperRef.current.swiper.autoplay.start();
      }
      return !currentAutoPlayState;
    });
  }, []);

  const releaseSlides = mode === 'fresh'
    ? freshReleaseArtwork
    : newestReleaseArtwork;
  const eventSlides = mode === 'fresh'
    ? freshEventArtwork
    : newestEventArtwork;

  return (
    <>
      <div className="timeline-carousel-inner">
        <div className="timeline-carousel-text">
          {l('Now')}
        </div>
        <Swiper
          autoplay={{
            delay: 5000,
            pauseOnMouseEnter: true,
          }}
          modules={[Navigation, Mousewheel, Autoplay]}
          mousewheel
          navigation
          ref={swiperRef}
          slidesPerView="auto"
          spaceBetween={24}
        >
          {entityType === 'release' ? releaseSlides?.map((artwork, index) => {
            return (
              <SwiperSlide key={`${mode}-${index}`}>
                <ReleaseTimelineImage artwork={artwork} />
              </SwiperSlide>
            );
          }) : eventSlides?.map((artwork, index) => {
            return (
              <SwiperSlide key={`${mode}-${index}`}>
                <EventTimelineImage artwork={artwork} />
              </SwiperSlide>
            );
          })}
        </Swiper>
      </div>
      <div className="d-flex pt-3 justify-content-between flex-row gap-3">
        <div className="d-flex gap-2">
          <div
            className={`timeline-carousel-pill ${
              mode === 'fresh' ? 'selected' : ''
            }`}
            onClick={handleFreshPillClick}
            title={texp.l(
              'Order by {type} date',
              {
                type: entityType === 'release' ? 'release' : 'event',
              },
            )}
          >
            {texp.l('Fresh {type}', {
              type: entityType === 'release' ? 'releases' : 'events',
            })}
          </div>
          <div
            className={`timeline-carousel-pill ${
              mode === 'new' ? 'selected' : ''
            }`}
            onClick={handleNewPillClick}
            title={l('Order by date added to MusicBrainz')}
          >
            {l('New Additions')}
          </div>
        </div>
        <div className="d-flex gap-3">
          <div
            className="d-flex gap-1 align-items-center timeline-control"
            onClick={toggleAutoPlay}
            role="button"
          >
            <FontAwesomeIcon icon={autoPlay ? faPauseCircle : faPlayCircle} />
            <h5 className="timeline-control d-none d-md-block">
              {autoPlay ? l('Pause') : l('Play')}
            </h5>
          </div>
          <a
            className={`d-flex gap-1 align-items-center
              text-decoration-none timeline-control`}
            href={
              entityType === 'release' ? '/release/add' : '/event/create'
            }
          >
            <FontAwesomeIcon icon={faPlusCircle} />
            <h5 className="timeline-control d-none d-md-block">
              {texp.l('Add {type}', {
                type: entityType === 'release' ? 'Release' : 'Event',
              })}
            </h5>
          </a>
        </div>
      </div>
    </>
  );
}

export default (hydrate<React.PropsOf<TimelineCarousel>>(
  'div.timeline-carousel',
  TimelineCarousel,
): component(...React.PropsOf<TimelineCarousel>));
