/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
// import picard from '../../../static/images/homepage/picard.png';
import Blob from './blob.js';

const SlideOne = () => (
  <div
    className="carousel-slide"
    style={{
      background: "linear-gradient(270deg, #BA478F -8.99%, #EB743B 87.81%)",
    }}
  >
    <div className="carousel-slide-content">
      <h2>Slide 1</h2>
    </div>
    <Blob width={300} height={300} randomness={2} className="slide-vector-1" />
    <Blob width={100} height={100} randomness={2} className="slide-vector-2" />
  </div>
);

const SlideTwo = () => (
  <div
    className="carousel-slide"
    style={{
      background: "linear-gradient(270deg, #EB743B -8.99%, #BA478F 87.81%)",
    }}
  >
    <div className="carousel-slide-content">
      <h2>Slide 2</h2>
    </div>
    <Blob width={100} height={100} randomness={2} className="slide-vector-3" />
    <Blob width={300} height={300} randomness={2} className="slide-vector-4" />
  </div>
);

component BannerCarousel() {
  const slides = [  
    <SlideOne key="slide-one" />,
    <SlideTwo key="slide-two" />,
  ]
  const extendedSlides = [
    slides[slides.length - 1],
    ...slides,
    slides[0],
  ];

  const [activeIndex, setActiveIndex] = React.useState(1);
  const [isTransitioning, setIsTransitioning] = React.useState(true);

  const handleTransitionEnd = () => {
    if (activeIndex === 0) {
      setIsTransitioning(false);
      setActiveIndex(slides.length);
    } else if (activeIndex === slides.length + 1) {
      setIsTransitioning(false);
      setActiveIndex(1);
    }
  };

  React.useEffect(() => {
    if (!isTransitioning) {
      requestAnimationFrame(() => setIsTransitioning(true));
    }
  }, [isTransitioning]);

  return (
    <div className="carousel-container banner-carousel" id="banner-carousel">
      <div
        className="carousel-track"
        style={{
          transform: `translateX(-${activeIndex * 100}%)`,
          transition: isTransitioning ? "transform 0.5s ease" : "none",
        }}
        onTransitionEnd={handleTransitionEnd}
      >
        {extendedSlides}
      </div>

      <button
        className="carousel-btn prev"
        onClick={() => setActiveIndex((prev) => (prev - 1 + slides.length) % slides.length)}
      >
        <FontAwesomeIcon icon={faChevronLeft} />
      </button>
      <button
        className="carousel-btn next"
        onClick={() => setActiveIndex((prev) => (prev + 1) % slides.length)}
      >
        <FontAwesomeIcon icon={faChevronRight} />
      </button>
    </div>
  );
};

export default (hydrate<React.PropsOf<BannerCarousel>>(
  'div.banner-carousel',
  BannerCarousel,
): component(...React.PropsOf<BannerCarousel>));
