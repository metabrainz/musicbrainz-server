/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type PropsT = {
  +artwork: ArtworkT,
};

const ArtLinks = ({
  artwork,
}: PropsT): React.MixedElement => (
  <>
    {artwork.small_thumbnail ? (
      <>
        <a href={artwork.small_thumbnail}>{l('250px')}</a>
        {' | '}
      </>
    ) : null}
    {artwork.large_thumbnail ? (
      <>
        <a href={artwork.large_thumbnail}>{l('500px')}</a>
        {' | '}
      </>
    ) : null}
    {artwork.huge_thumbnail ? (
      <>
        <a href={artwork.huge_thumbnail}>{l('1200px')}</a>
        {' | '}
      </>
    ) : null}
    <a href={artwork.image}>{l('original')}</a>
  </>
);

export default ArtLinks;
