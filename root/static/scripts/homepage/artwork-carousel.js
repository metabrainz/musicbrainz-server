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
import {Autoplay, Mousewheel, Navigation} from 'swiper/modules';
import {Swiper, SwiperSlide} from 'swiper/react';

import artworkCoverartPlaceholder
  from '../../images/homepage/artwork-coverart-placeholder.png';
import {l} from '../common/i18n.js';
import {reduceArtistCredit} from '../common/immutable-entities.js';
import entityHref from '../common/utility/entityHref.js';

component ReleaseArtworkImage(artwork: ReleaseArtT) {
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
    <div className="artwork-image-container">
      <div className="artwork-item">
        <a
          className="artwork-coverart-container"
          href={entityHref(release)}
          role="button"
          style={{
            overflow: 'hidden',
            position: 'relative',
          }}
          tabIndex={0}
        >
          <img
            alt={release.name}
            src={artworkCoverartPlaceholder}
            style={{
              height: '150px',
              objectFit: 'cover',
              opacity: imageLoaded ? 0 : 1,
              position: 'absolute',
              transition: 'opacity 0.3s ease',
              width: '150px',
              zIndex: imageLoaded ? 0 : 1,
            }}
            title={releaseDescription}
          />
          <img
            alt={release.name}
            loading="lazy"
            onLoad={handleImageLoad}
            src={artwork.small_ia_thumbnail}
            srcSet={
              artwork.small_ia_thumbnail + ' 1x, ' +
              artwork.large_ia_thumbnail + ' 1.5x'
            }
            style={{
              height: '150px',
              objectFit: 'cover',
              opacity: imageLoaded ? 1 : 0,
              position: 'relative',
              transition: 'opacity 0.3s ease',
              width: '150px',
              zIndex: imageLoaded ? 1 : 0,
            }}
            title={releaseDescription}
          />
          <div className="hover-backdrop">
            <p>
              {release.name}
            </p>
            <p>
              {texp.l('by {artist}', {
                artist: reduceArtistCredit(release.artistCredit),
              })}
            </p>
          </div>
        </a>
      </div>
    </div>
  );
}

component EventArtworkImage(artwork: EventArtT) {
  const event = artwork.event;
  const [imageLoaded, setImageLoaded] = React.useState<boolean>(false);

  const handleImageLoad = React.useCallback(() => {
    setImageLoaded(true);
  }, []);

  if (!event) {
    return null;
  }

  const eventDescription = event.name;

  return (
    <div className="artwork-image-container">
      <div className="artwork-item">
        <a
          className="artwork-coverart-container"
          href={entityHref(event)}
          role="button"
          style={{
            overflow: 'hidden',
            position: 'relative',
          }}
          tabIndex={0}
        >
          <img
            alt={event.name}
            src={artworkCoverartPlaceholder}
            style={{
              height: '150px',
              objectFit: 'cover',
              opacity: imageLoaded ? 0 : 1,
              position: 'absolute',
              transition: 'opacity 0.3s ease',
              width: '150px',
              zIndex: imageLoaded ? 0 : 1,
            }}
            title={eventDescription}
          />
          <img
            alt={event.name}
            loading="lazy"
            onLoad={handleImageLoad}
            src={artwork.small_ia_thumbnail}
            srcSet={
              artwork.small_ia_thumbnail + ' 1x, ' +
              artwork.large_ia_thumbnail + ' 1.5x'
            }
            style={{
              height: '150px',
              objectFit: 'cover',
              opacity: imageLoaded ? 1 : 0,
              position: 'relative',
              transition: 'opacity 0.3s ease',
              width: '150px',
              zIndex: imageLoaded ? 1 : 0,
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

component ArtworkCarousel(
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
      <div className="artwork-carousel-inner">
        <div className="artwork-carousel-text">
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
                <ReleaseArtworkImage artwork={artwork} />
              </SwiperSlide>
            );
          }) : eventSlides?.map((artwork, index) => {
            return (
              <SwiperSlide key={`${mode}-${index}`}>
                <EventArtworkImage artwork={artwork} />
              </SwiperSlide>
            );
          })}
        </Swiper>
      </div>
      <div className="d-flex pt-3 justify-content-between flex-row gap-3">
        <div className="d-flex gap-2">
          <div
            className={`artwork-carousel-pill ${
              mode === 'fresh' ? 'selected' : ''
            }`}
            onClick={handleFreshPillClick}
            title={entityType === 'release'
              ? l('Order by release date')
              : l('Order by event date')}
          >
            {entityType === 'release'
              ? l('Fresh releases')
              : l('Fresh events')}
          </div>
          <div
            className={`artwork-carousel-pill ${
              mode === 'new' ? 'selected' : ''
            }`}
            onClick={handleNewPillClick}
            title={l('Order by date added to MusicBrainz')}
          >
            {l('New additions')}
          </div>
        </div>
        <div className="d-flex gap-3">
          <div
            className="d-flex gap-1 align-items-center artwork-control"
            onClick={toggleAutoPlay}
            role="button"
          >
            <FontAwesomeIcon icon={autoPlay ? faPauseCircle : faPlayCircle} />
            <h5 className="artwork-control d-none d-md-block">
              {autoPlay ? l('Pause') : l('Play')}
            </h5>
          </div>
          <a
            className={`d-flex gap-1 align-items-center
              text-decoration-none artwork-control`}
            href={
              entityType === 'release' ? '/release/add' : '/event/create'
            }
          >
            <FontAwesomeIcon icon={faPlusCircle} />
            <h5 className="artwork-control d-none d-md-block">
              {entityType === 'release'
                ? l('Add release')
                : l('Add event')}
            </h5>
          </a>
        </div>
      </div>
    </>
  );
}

export default (hydrate<React.PropsOf<ArtworkCarousel>>(
  'div.artwork-carousel',
  ArtworkCarousel,
): component(...React.PropsOf<ArtworkCarousel>));
