/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../common/components/EntityLink.js';
import isolateText from '../../common/utility/isolateText.js';
import DiffSide from '../components/edit/DiffSide.js';

import editDiff, {
  CHANGE,
  CLASS_MAP,
  DELETE,
  EQUAL,
  INSERT,
} from './editDiff.js';

function areArtistCreditNamesEqual(
  a: ArtistCreditNameT,
  b: ArtistCreditNameT,
) {
  return (
    a.artist.id === b.artist.id &&
    a.name === b.name &&
    a.joinPhrase === b.joinPhrase
  );
}

type ArtistLinkProps = {
  +content?: Expand2ReactOutput,
  +credit: ArtistCreditNameT,
  +nameVariation?: boolean,
};

const ArtistLink = ({content, credit, nameVariation}: ArtistLinkProps) => (
  credit.artist ? (
    <EntityLink
      content={empty(content) ? credit.name : content}
      entity={credit.artist}
      nameVariation={nameVariation}
      shouldIsolate={false}
    />
  ) : null
);

export default function diffArtistCredits(
  oldArtistCredit: ArtistCreditT,
  newArtistCredit: ArtistCreditT,
): {new: React.Node, old: React.Node} {
  const diffs = editDiff(
    oldArtistCredit.names,
    newArtistCredit.names,
    areArtistCreditNamesEqual,
  );

  const oldNames: Array<React.Node> = [];
  const newNames: Array<React.Node> = [];

  for (let i = 0; i < diffs.length; i++) {
    const diff = diffs[i];
    const {oldItems, newItems} = diff;

    switch (diff.type) {
      case EQUAL:
        oldItems.forEach(function (credit, index) {
          const link = <ArtistLink credit={credit} key={'equal-' + index} />;
          oldNames.push(link, credit.joinPhrase);
          newNames.push(link, credit.joinPhrase);
        });
        break;

      case CHANGE: {
        const itemCount = Math.max(oldItems.length, newItems.length);

        for (let i = 0; i < itemCount; i++) {
          const oldCredit = oldItems[i] ||
            {artist: null, joinPhrase: '', name: ''};
          const newCredit = newItems[i] ||
            {artist: null, joinPhrase: '', name: ''};

          const oldJoin = (
            <DiffSide
              filter={DELETE}
              key={'old-join-' + i}
              newText={newCredit.joinPhrase}
              oldText={oldCredit.joinPhrase}
              split="\s+"
            />
          );

          const newJoin = (
            <DiffSide
              filter={INSERT}
              key={'new-join-' + i}
              newText={newCredit.joinPhrase}
              oldText={oldCredit.joinPhrase}
              split="\s+"
            />
          );

          oldNames.push(
            <ArtistLink
              content={
                <DiffSide
                  filter={DELETE}
                  newText={newCredit.name}
                  oldText={oldCredit.name}
                  split="\s+"
                />
              }
              credit={oldCredit}
              key={'old-' + i}
              nameVariation={oldCredit.artist &&
                oldCredit.artist.name !== oldCredit.name}
            />,
            oldJoin,
          );

          newNames.push(
            <ArtistLink
              content={
                <DiffSide
                  filter={INSERT}
                  newText={newCredit.name}
                  oldText={oldCredit.name}
                  split="\s+"
                />
              }
              credit={newCredit}
              key={'new-' + i}
              nameVariation={newCredit.artist &&
                newCredit.artist.name !== newCredit.name}
            />,
            newJoin,
          );
        }

        break;
      }

      case DELETE:
        oldNames.push(...oldItems.map((credit, index) => (
          <span className={CLASS_MAP[DELETE]} key={'old-' + index}>
            <ArtistLink credit={credit} />
            {credit.joinPhrase}
          </span>
        )));
        break;

      case INSERT:
        newNames.push(...newItems.map((credit, index) => (
          <span className={CLASS_MAP[INSERT]} key={'new-' + index}>
            <ArtistLink credit={credit} />
            {credit.joinPhrase}
          </span>
        )));
        break;
    }
  }

  return {
    new: isolateText(newNames),
    old: isolateText(oldNames),
  };
}
