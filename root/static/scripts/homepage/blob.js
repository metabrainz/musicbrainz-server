/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as blobs2Animate from 'blobs/v2/animate';
import * as React from 'react';

function isUndefined(value: mixed): boolean {
  return value === undefined;
}

component Blob(
  width: number,
  height: number,
  randomness: number,
  className?: string,
  style?: {
    animationDelay?: string,
  },
  seed?: number,
  blur?: number,
) {
  const blobCanvas = React.useRef<HTMLCanvasElement | null>(null);

  React.useEffect(() => {
    const ctx = blobCanvas.current?.getContext('2d');
    if (!ctx) {
      return;
    }
    const animation = blobs2Animate.canvasPath();
    const randomAngleStart = Math.random() * 360;
    if (!isUndefined(blur) && Number.isFinite(blur)) {
      ctx.filter = `blur(${blur}px)`;
    }
    const renderAnimation = (time: number) => {
      ctx.clearRect(0, 0, width, height);
      let angle = (((time / 50) % 360) / 180) * Math.PI;
      angle += randomAngleStart;
      const gradient = ctx.createLinearGradient(
        width / 2,
        0,
        width / 2 + Math.cos(angle) * width,
        Math.sin(angle) * height,
      );
      gradient.addColorStop(0, '#D48835');
      gradient.addColorStop(1, '#BC4C88');
      ctx.fillStyle = gradient;
      ctx.fill(animation.renderFrame());
      requestAnimationFrame(renderAnimation);
    };
    requestAnimationFrame(renderAnimation);

    let size = Math.min(width, height);
    let offsetX = 0;
    let offsetY = 0;
    if (!isUndefined(blur) && Number.isFinite(blur)) {
      size -= blur * 2;
      offsetX = blur;
      offsetY = blur;
    }
    blobs2Animate.wigglePreset(
      animation,
      {
        seed: seed ?? Date.now(),
        extraPoints: 3,
        randomness: randomness * 2,
        size,
      },
      {offsetX, offsetY},
      {speed: Math.random() * 1.7},
    );
  }, [blobCanvas, height, width, randomness, blur, seed]);

  return (
    <canvas
      className={className}
      height={height}
      ref={blobCanvas}
      style={style}
      width={width}
    />
  );
}

export default (hydrate<React.PropsOf<Blob>>(
  'div.blob',
  Blob,
): component(...React.PropsOf<Blob>));
