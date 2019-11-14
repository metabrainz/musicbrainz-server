/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import zip from 'lodash/zip';

import EntityLink from '../../common/components/EntityLink';
import DiffSide from '../components/edit/DiffSide';

import editDiff, {
  INSERT,
  EQUAL,
  DELETE,
  CHANGE,
  CLASS_MAP,
} from './editDiff';

function areArtistCreditNamesEqual(a, b) {
  return (
    a.artist.id === b.artist.id &&
    a.name === b.name &&
    a.joinPhrase === b.joinPhrase
  );
}

type ArtistLinkProps = {
  +content?: React.Node,
  +credit: ArtistCreditNameT,
  +nameVariation?: boolean,
};

const ArtistLink = ({content, credit, nameVariation}: ArtistLinkProps) => (
  <EntityLink
    content={content || credit.name}
    entity={credit.artist}
    nameVariation={nameVariation}
  />
);

export default function diffArtistCredits(
  oldArtistCredit: ArtistCreditT,
  newArtistCredit: ArtistCreditT,
) {
  const diffs = editDiff(
    oldArtistCredit.names,
    newArtistCredit.names,
    areArtistCreditNamesEqual,
  );

  const oldNames = [];
  const newNames = [];

  for (let i = 0; i < diffs.length; i++) {
    const diff = diffs[i];

    switch (diff.type) {
      case EQUAL:
        diff.oldItems.forEach(function (credit) {
          const oldLink =
            <ArtistLink credit={credit} key={oldNames.length} />;
          const newLink =
            <ArtistLink credit={credit} key={newNames.length} />;
          oldNames.push(oldLink, credit.joinPhrase);
          newNames.push(newLink, credit.joinPhrase);
        });
        break;

      case CHANGE:
        // $FlowFixMe - zip doesn't like $ReadOnlyArray
        zip(diff.oldItems, diff.newItems).forEach(function (pair) {
          const oldCredit = pair[0] ||
            {artist: null, joinPhrase: '', name: ''};
          const newCredit = pair[1] ||
            {artist: null, joinPhrase: '', name: ''};

          const oldJoin = (
            <DiffSide
              filter={DELETE}
              newText={newCredit.joinPhrase}
              oldText={oldCredit.joinPhrase}
              split="\s+"
            />
          );

          const newJoin = (
            <DiffSide
              filter={INSERT}
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
              key={oldNames.length}
              nameVariation={oldCredit.artist.name !== oldCredit.name}
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
              key={newNames.length}
              nameVariation={newCredit.artist.name !== newCredit.name}
            />,
            newJoin,
          );
        });

        break;

      case DELETE:
        oldNames.push(...diff.oldItems.map(credit => (
          <span className={CLASS_MAP[DELETE]} key={oldNames.length}>
            <ArtistLink credit={credit} />
            {credit.joinPhrase}
          </span>
        )));
        break;

      case INSERT:
        newNames.push(...diff.newItems.map(credit => (
          <span className={CLASS_MAP[INSERT]} key={newNames.length}>
            <ArtistLink credit={credit} />
            {credit.joinPhrase}
          </span>
        )));
        break;
    }
  }

  return {
    new: React.createElement(React.Fragment, null, ...newNames),
    old: React.createElement(React.Fragment, null, ...oldNames),
  };
}
