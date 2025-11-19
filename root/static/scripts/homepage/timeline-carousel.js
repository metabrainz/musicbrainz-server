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
import { Navigation, Mousewheel, Autoplay } from 'swiper/modules';
import {faPlusCircle, faPauseCircle, faPlayCircle} from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {reduceArtistCredit} from '../common/immutable-entities';
import entityHref from '../common/utility/entityHref';
// $FlowFixMe[untyped-import]
import { LazyLoadImage } from 'react-lazy-load-image-component';
import timelineCoverartPlaceholder from '../../images/homepage/timeline-coverart-placeholder.png';

component ReleaseTimelineImage(artwork: ReleaseArtT) {
  const release = artwork.release;
  const [imageLoaded, setImageLoaded] = React.useState<boolean>(false);
  if (!release) {
    return null;
  }

  const artist = reduceArtistCredit(release.artistCredit);

  const releaseDescription = texp.l('{entity} by {artist}', {
    artist: artist,
    entity: release.name,
  });

  const handleImageLoad = () => {
    setImageLoaded(true);
  }

  return (
    <div className="timeline-image-container">
      <div className="timeline-item">
        <a
          className="timeline-coverart-container"
          role="button"
          tabIndex={0}
          href={entityHref(release)}
          style={{
            overflow: 'hidden',
          }}
        >
          <img
            src={timelineCoverartPlaceholder}
            style={{
              objectFit: 'cover',
              width: '150px',
              height: '150px',
              display: imageLoaded ? "none" : "block",
            }}
            alt={release.name}
            title={releaseDescription}
          />
          <LazyLoadImage
            src={artwork.small_ia_thumbnail}
            alt={release.name}
            title={releaseDescription}
            onLoad={handleImageLoad}
            style={{
              objectFit: 'cover',
              width: '150px',
              height: '150px',
            }}
          />
          <div className="hover-backdrop">
            <p>
              {release.name}
            </p>
            <p>
              By {reduceArtistCredit(release.artistCredit)}
            </p>
          </div>
        </a>
      </div>
    </div>
  )
}

component EventTimelineImage(artwork: EventArtT) {
  const event = artwork.event;
  const [imageLoaded, setImageLoaded] = React.useState<boolean>(false);

  if (!event) {
    return null;
  }

  const eventDescription = texp.l('{entity}', {
    entity: event.name,
  });

  const handleImageLoad = () => {
    setImageLoaded(true);
  }

  return (
    <div className="timeline-image-container">
      <div className="timeline-item">
        <a
          className="timeline-coverart-container"
          role="button"
          tabIndex={0}
          href={entityHref(event)}
          style={{
            overflow: 'hidden',
          }}
        >
          <img
            src={timelineCoverartPlaceholder}
            style={{
              objectFit: 'cover',
              width: '150px',
              height: '150px',
              display: imageLoaded ? "none" : "block",
            }}
            alt={event.name}
            title={eventDescription}
          />
          <LazyLoadImage
            className={`${imageLoaded ? "" : "hidden"}`}
            src={artwork.small_ia_thumbnail}
            alt={event.name}
            title={eventDescription}
            onLoad={handleImageLoad}
            style={{
              objectFit: 'cover',
              width: '150px',
              height: '150px',
            }}
          />
          <div className="hover-backdrop">
            <p>
              {event.name}
            </p>
          </div>
        </a>
      </div>
    </div>
  )
}

component TimelineCarousel(
  newestReleaseArtwork?: $ReadOnlyArray<ReleaseArtT>,
  freshReleaseArtwork?: $ReadOnlyArray<ReleaseArtT>,
  newestEventArtwork?: $ReadOnlyArray<EventArtT>,
  freshEventArtwork?: $ReadOnlyArray<EventArtT>,
  entityType: "release" | "event",
) {
  const [mode, setMode] = React.useState<'fresh' | 'new'>('fresh');
  const [autoPlay, setAutoPlay] = React.useState<boolean>(true);
  const swiperRef = React.useRef<React.ElementRef<typeof Swiper>>(null);

  const handlePillClick = (pill: 'fresh' | 'new') => {
    setMode(pill);
  }

  const toggleAutoPlay = () => {
    setAutoPlay((currentAutoPlayState) => {
      if (currentAutoPlayState) {
        swiperRef.current.swiper.autoplay.stop();
      } else {
        swiperRef.current.swiper.autoplay.start()
      }
      return !currentAutoPlayState;
    });
  };

  const releaseSlides = mode === 'fresh' ? freshReleaseArtwork : newestReleaseArtwork;
  const eventSlides = mode === 'fresh' ? freshEventArtwork : newestEventArtwork;

  return (
    <>
      <div className='timeline-carousel-inner'>
        <div className='timeline-carousel-text'>
          Now
        </div>
        <Swiper
          ref={swiperRef}
          navigation={true}
          slidesPerView="auto"
          spaceBetween={24}
          modules={[Navigation, Mousewheel, Autoplay]}
          mousewheel={true}
          autoplay={{
            delay: 5000,
            pauseOnMouseEnter: true,
          }}
        >
          {entityType === "release" ? releaseSlides?.map((artwork, index) => {
            return (
              <SwiperSlide key={`${mode}-${index}`}>
                <ReleaseTimelineImage artwork={artwork} />
              </SwiperSlide>
            )
          }) : eventSlides?.map((artwork, index) => {
            return (
              <SwiperSlide key={`${mode}-${index}`}>
                <EventTimelineImage artwork={artwork} />
              </SwiperSlide>
            )
          })}
        </Swiper>
      </div>
      <div className='d-flex pt-3 justify-content-between flex-row gap-3'>
        <div className="d-flex gap-2">
          <div
            className={`timeline-carousel-pill ${mode === 'fresh' ? 'selected' : ''}`}
            onClick={() => handlePillClick('fresh')}
            title={`Order by ${entityType === "release" ? "release" : "event"} date`}
          >
            Fresh {entityType === "release" ? "releases" : "events"}
          </div>
          <div
            className={`timeline-carousel-pill ${mode === 'new' ? 'selected' : ''}`}
            onClick={() => handlePillClick('new')}
            title="Order by date added to MusicBrainz"
          >
            New Additions
          </div>
        </div>
        <div className="d-flex gap-3">
          <div role="button" onClick={toggleAutoPlay} className="d-flex gap-1 align-items-center timeline-control">
            <FontAwesomeIcon icon={autoPlay ? faPauseCircle : faPlayCircle} />
            <h5 className="timeline-control d-none d-md-block">
              {autoPlay ? "Pause" : "Play"}
            </h5>
          </div>
          <a
            className="d-flex gap-1 align-items-center text-decoration-none timeline-control"
            href={entityType === "release" ? "/release/add" : "/event/create"}
          >
            <FontAwesomeIcon icon={faPlusCircle} />
            <h5 className="timeline-control d-none d-md-block">
              Add {entityType === "release" ? "Release" : "Event"}
            </h5>
          </a>
        </div>
      </div>
    </>
  );
}

export default (hydrate<React.PropsOf<TimelineCarousel>> (
  'div.timeline-carousel',
  TimelineCarousel,
): component(...React.PropsOf <TimelineCarousel>));
