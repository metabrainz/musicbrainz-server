/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import * as React from 'react';

import ArtistCreditLink from '../../common/components/ArtistCreditLink.js';
import ArtistCreditUsageLink
  from '../../common/components/ArtistCreditUsageLink.js';
import {compare} from '../../common/i18n.js';
import {reduceArtistCredit} from '../../common/immutable-entities.js';
import {sortedIndexWith} from '../../common/utility/arrays.js';
import bracketed, {bracketedText} from '../../common/utility/bracketed.js';
import diffArtistCredits from '../../edit/utility/diffArtistCredits.js';

type ArtistCreditWithIdT = $ReadOnly<{
  ...ArtistCreditT,
  +id: number,
}>;

type ArtistCreditRowPropsT = {
  +artistCredit: ArtistCreditWithIdT,
  +dispatch: (ActionT) => void,
  +isInitiallyChecked: boolean,
};

type ArtistCreditRenamerPropsT = {
  +artistCredits: $ReadOnlyArray<ArtistCreditWithIdT>,
  +artistMbid: string,
  +artistName: string,
  +initialArtistName: string,
  +initialSelectedArtistCreditIds: {+[artistCreditId: number]: 1},
};

type StateT = {
  +expanded: boolean,
  +name: string,
  +selection: Array<ArtistCreditWithIdT>,
};

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {
      +type: 'set-expanded',
      +expanded: boolean,
    }
  | {
      +type: 'set-name',
      +name: string,
    }
  | {
      +type: 'toggle-artist-credit',
      +artistCredit: ArtistCreditWithIdT,
      +checked: boolean,
    };
/* eslint-enable ft-flow/sort-keys */

const MARGIN_1EM = {margin: '1em'};

function compareArtistCredits(
  ac1: ArtistCreditWithIdT,
  ac2: ArtistCreditWithIdT,
) {
  return compare(
    reduceArtistCredit(ac1),
    reduceArtistCredit(ac2),
  );
}

function createInitialState(name: string): StateT {
  return {expanded: false, name, selection: []};
}

function reducer(state: StateT, action: ActionT): StateT {
  switch (action.type) {
    case 'set-expanded': {
      return {...state, expanded: action.expanded};
    }
    case 'set-name': {
      return {...state, name: action.name};
    }
    case 'toggle-artist-credit': {
      const selection = state.selection;
      const {artistCredit, checked} = action;
      if (checked) {
        const [index] = sortedIndexWith(
          selection,
          artistCredit,
          compareArtistCredits,
        );
        const newSelection = [...selection];
        newSelection.splice(index, 0, artistCredit);
        return {...state, selection: newSelection};
      }
      return {
        ...state,
        selection: selection.filter(x => x !== artistCredit),
      };
    }
  }
  return state;
}

const ArtistCreditRow = ({
  artistCredit,
  dispatch,
  isInitiallyChecked,
}: ArtistCreditRowPropsT) => {
  const [isChecked, setChecked] = React.useState(isInitiallyChecked);
  return (
    <div>
      <input
        checked={isChecked}
        name="edit-artist.rename_artist_credit"
        onChange={(event) => {
          const checked = event.target.checked;
          setChecked(checked);
          dispatch({
            artistCredit,
            checked,
            type: 'toggle-artist-credit',
          });
        }}
        type="checkbox"
        value={artistCredit.id}
      />
      <ArtistCreditLink artistCredit={artistCredit} />
      {' '}
      <span className="small">
        {bracketed(
          <ArtistCreditUsageLink
            artistCredit={artistCredit}
            content={l('see uses')}
          />,
        )}
      </span>
    </div>
  );
};

const ArtistCreditRenamer = ({
  artistCredits,
  artistMbid,
  artistName,
  initialArtistName,
  initialSelectedArtistCreditIds,
}: ArtistCreditRenamerPropsT): React$MixedElement | null => {
  const rowsRef = React.useRef<
    $ReadOnlyArray<React.Element<typeof ArtistCreditRow>> | null,
  >(null);

  const [state, dispatch] = React.useReducer(
    reducer,
    initialArtistName,
    createInitialState,
  );

  if (!rowsRef.current) {
    // Cache the element list for artists with hundreds of ACs.
    rowsRef.current = artistCredits.map(artistCredit => {
      const id = artistCredit.id;
      const isChecked = initialSelectedArtistCreditIds[id] === 1;
      if (isChecked) {
        // This is only safe on first render!
        state.selection.push(artistCredit);
      }
      return (
        <ArtistCreditRow
          artistCredit={artistCredit}
          dispatch={dispatch}
          isInitiallyChecked={isChecked}
          key={id}
        />
      );
    });
  }

  const rows = rowsRef.current;
  const tooManyRows = rows.length > 10;

  const handleArtistNameChange = React.useCallback((
    event: SyntheticInputEvent<HTMLInputElement>,
  ) => {
    dispatch({name: event.target.value, type: 'set-name'});
  }, [dispatch]);

  React.useEffect(() => {
    $(document).on(
      'input',
      '#id-edit-artist\\.name',
      handleArtistNameChange,
    );
    return () => {
      $(document).off(
        'input',
        '#id-edit-artist\\.name',
        handleArtistNameChange,
      );
    };
  }, [handleArtistNameChange]);

  return (
    <fieldset
      id="artist-credit-renamer"
      style={{display: artistName === state.name ? 'none' : 'block'}}
    >
      <legend>{l('Artist credits')}</legend>
      <p>
        {exp.l(
          `Please select the {doc|artist credits} that you want to
           rename to follow the new artist name.`,
          {doc: '/doc/Artist_Credits'},
        )}
      </p>
      <p>
        {l(`This will enter additional edits to change each specific
            credit to use the new name. Only use this if you are sure
            the existing credits are incorrect (such as for typos).`)}
      </p>
      <p>
        {l(`Keep in mind artist credits should generally follow what is
            printed on releases. If an artist has changed their name,
            but old releases were credited to the existing name, do not
            change the artist credit.`)}
      </p>
      <div
        className={
          'collapsible-body' +
          ((tooManyRows && !state.expanded) ? ' collapsed' : '')
        }
        key="artist-credits"
        style={MARGIN_1EM}
      >
        {rows}
      </div>
      {tooManyRows ? (
        state.expanded ? (
          <div style={MARGIN_1EM}>
            <a
              href="#"
              onClick={(event) => {
                event.preventDefault();
                dispatch({expanded: false, type: 'set-expanded'});
              }}
              role="button"
              title={l('Show less artist credits')}
            >
              {bracketedText(l('Show less...'))}
            </a>
          </div>
        ) : (
          <div style={MARGIN_1EM}>
            <a
              href="#"
              onClick={(event) => {
                event.preventDefault();
                dispatch({expanded: true, type: 'set-expanded'});
              }}
              role="button"
              title={l('Show more artist credits')}
            >
              {bracketedText(l('Show more...'))}
            </a>
          </div>
        )
      ) : null}
      {state.selection.length ? (
        <>
          <h2>{lp('Preview', 'header')}</h2>
          <table
            className="details split-artist"
            style={MARGIN_1EM}
          >
            <tbody>
              {state.selection.map((artistCredit) => {
                const newArtistCredit = {
                  ...artistCredit,
                  names: artistCredit.names.map(x => (
                    x.artist.gid === artistMbid
                      ? {...x, name: state.name}
                      : x
                  )),
                };

                const diff = diffArtistCredits(
                  artistCredit,
                  newArtistCredit,
                );

                return (
                  <tr key={'preview-' + String(artistCredit.id)}>
                    <td className="old">
                      {diff.old}
                    </td>
                    <td className="new">
                      {diff.new}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </>
      ) : null}
    </fieldset>
  );
};

export default (hydrate<ArtistCreditRenamerPropsT>(
  'div.artist-credit-renamer',
  ArtistCreditRenamer,
): React.AbstractComponent<ArtistCreditRenamerPropsT, void>);
