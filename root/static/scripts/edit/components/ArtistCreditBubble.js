/*
 * @flow strict
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import mutate from 'mutate-cow';
import * as React from 'react';

import ArtistCreditLink from '../../common/components/ArtistCreditLink.js';
import DescriptiveLink from '../../common/components/DescriptiveLink.js';
import {reduceArtistCredit} from '../../common/immutable-entities.js';
import clean from '../../common/utility/clean.js';

import type {
  ActionT,
  ArtistCreditableT,
  ArtistCreditNameStateT,
  StateT as ArtistCreditStateT,
} from './ArtistCreditEditor/types.js';
import {
  artistCreditFromState,
} from './ArtistCreditEditor/utilities.js';
import ArtistCreditNameEditor from './ArtistCreditNameEditor.js';

type ButtonsPropsT = {
  +dispatch: (ActionT) => void,
  +initialBubbleFocus: ArtistCreditStateT['initialBubbleFocus'],
  +initialFocusRef: {-current: HTMLElement | null},
  +isTrack: boolean,
};

const Buttons = React.memo<ButtonsPropsT>(({
  dispatch,
  initialBubbleFocus,
  initialFocusRef,
  isTrack,
}: ButtonsPropsT): React.MixedElement => (
  <div className="buttons">
    <button
      id="copy-ac"
      onClick={() => dispatch({type: 'copy'})}
      type="button"
    >
      {l('Copy credits')}
    </button>
    <button
      id="paste-ac"
      onClick={() => dispatch({type: 'paste'})}
      type="button"
    >
      {l('Paste credits')}
    </button>
    <button className="positive" type="submit">
      {l('Done')}
    </button>
    {isTrack ? (
      <>
        <button
          id="next-track-ac"
          onClick={() => dispatch({type: 'next-track'})}
          ref={
            initialBubbleFocus === 'next-track' ? initialFocusRef : null
          }
          type="button"
        >
          {l('Next')}
        </button>
        <button
          id="prev-track-ac"
          onClick={() => dispatch({type: 'previous-track'})}
          ref={
            initialBubbleFocus === 'prev-track' ? initialFocusRef : null
          }
          type="button"
        >
          {l('Previous')}
        </button>
      </>
    ) : null}
  </div>
));

const ArtistCreditDocumentation = (React.memo(() => (
  <tr>
    <td colSpan={3} id="ac-docs">
      {exp.l(
        `Use the following fields to enter artist name variations
         and multiple artist collaborations. See the
         {ac|Artist Credit} documentation for more information.`,
        {ac: '/doc/Artist_Credits'},
      )}
    </td>
  </tr>
)));

type ArtistCreditPreviewPropsT = {
  +editsPending: boolean | void,
  +entity: ArtistCreditableT,
  +names: $ReadOnlyArray<ArtistCreditNameStateT>,
};

const ArtistCreditPreview = (React.memo<ArtistCreditPreviewPropsT>(({
  editsPending,
  entity,
  names,
}: ArtistCreditPreviewPropsT): React.MixedElement => {
  const artistCredit = React.useMemo(() => ({
    ...artistCreditFromState(names),
    editsPending,
  }), [names, editsPending]);

  return (
    <thead>
      <ArtistCreditDocumentation />
      {clean(reduceArtistCredit(artistCredit)) ? (
        <tr>
          <td colSpan={4} id="ac-preview-cell">
            {addColonText(lp('Preview', 'header')) + ' '}
            {entity.entityType === 'track'
              ? (
                <DescriptiveLink
                  allowNew
                  content={ko.unwrap(entity.name) === ''
                    ? l('[missing track name]')
                    : ''}
                  customArtistCredit={artistCredit}
                  deletedCaption={ko.unwrap(entity.name) === ''
                    ? l('You haven’t entered a track name yet.')
                    : l('This track hasn’t been added yet.')}
                  entity={entity}
                  showDeletedArtists={false}
                  target="_blank"
                />
              ) : (
                <ArtistCreditLink
                  artistCredit={artistCredit}
                  showDeleted={false}
                  target="_blank"
                />
              )}
          </td>
        </tr>
      ) : null}
      <tr className="artist-credit-header">
        <th>{l('Artist in MusicBrainz:')}</th>
        <th>{l('Artist as credited:')}</th>
        <th>{l('Join phrase:')}</th>
        <th />
      </tr>
    </thead>
  );
}));

component _AddArtistCreditRow(dispatch: (ActionT) => void) {
  return (
    <tr>
      <td className="align-right" colSpan={4}>
        <button
          className="add-item with-label"
          onClick={() => dispatch({type: 'add-name'})}
          type="button"
        >
          {lp('Add artist credit', 'interactive')}
        </button>
      </td>
    </tr>
  );
}

const AddArtistCreditRow = React.memo(_AddArtistCreditRow);

component _ChangeMatchingTrackArtistsRow(
  changeMatchingTrackArtists: boolean | void,
  dispatch: (ActionT) => void,
  initialArtistCreditString: string,
) {
  return (
    <div>
      <label>
        <input
          checked={changeMatchingTrackArtists === true}
          id="change-matching-artists"
          onChange={
            (event: SyntheticEvent<HTMLInputElement>) => dispatch({
              checked: event.currentTarget.checked,
              type: 'set-change-matching-artists',
            })
          }
          type="checkbox"
        />
        {initialArtistCreditString ? (
          texp.l(
            'Change all artists on this release that match “{name}”',
            {name: initialArtistCreditString},
          )
        ) : (
          l('Change all artists on this release that are currently empty')
        )}
      </label>
    </div>
  );
}

const ChangeMatchingTrackArtistsRow =
  React.memo(_ChangeMatchingTrackArtistsRow);

component _ArtistCreditBubble(
  closeAndReturnFocus: () => void,
  dispatch: (ActionT) => void,
  initialFocusRef: {-current: HTMLElement | null},
  state: ArtistCreditStateT,
) {
  const {
    changeMatchingTrackArtists,
    editsPending,
    entity,
    initialArtistCreditString,
    initialBubbleFocus,
    names,
  } = state;

  const isTrack = entity.entityType === 'track';

  const tableRef = React.useRef<HTMLTableElement | null>(null);

  function handleKeyDown(event: SyntheticKeyboardEvent<HTMLElement>) {
    if (
      event.target instanceof HTMLInputElement &&
      event.keyCode === 13 /* Enter */ &&
      isTrack && /*:: entity.entityType === 'track' && */
      entity.next()
    ) {
      // Prevent form submission.
      event.preventDefault();
      dispatch({initialFocus: 'default', type: 'next-track'});
    }
  }

  function handleSubmit(event: SyntheticEvent<HTMLFormElement>) {
    event.preventDefault();
    // Prevent the submit event from propagating to a parent form.
    event.stopPropagation();
    closeAndReturnFocus();
  }

  const namesWithInitialFocus = React.useMemo(() => {
    if (
      names.length &&
      (initialBubbleFocus == null || initialBubbleFocus === 'default')
    ) {
      return mutate(names)
        .set(0, 'artist', 'inputRef', initialFocusRef)
        .final();
    }
    return names;
  }, [names, initialBubbleFocus, initialFocusRef]);

  const allowNameMoveOrRemoval = React.useMemo(
    () => state.names.filter((n) => !n.removed).length > 1,
    [state.names],
  );

  return (
    <form onSubmit={handleSubmit}>
      <table
        className="table-condensed"
        onKeyDown={handleKeyDown}
        ref={tableRef}
      >
        <ArtistCreditPreview
          editsPending={editsPending}
          entity={entity}
          names={names}
        />
        <tbody>
          {namesWithInitialFocus.map((name, index) => (
            <ArtistCreditNameEditor
              allowMoveDown={index < names.length - 1}
              allowMoveUp={index > 0}
              allowRemoval={allowNameMoveOrRemoval}
              artistCreditEditorId={state.id}
              dispatch={dispatch}
              index={index}
              key={name.key}
              name={name}
              showMoveButtons={allowNameMoveOrRemoval && !name.removed}
            />
          ))}
          <AddArtistCreditRow dispatch={dispatch} />
        </tbody>
      </table>
      {isTrack ? (
        <ChangeMatchingTrackArtistsRow
          changeMatchingTrackArtists={changeMatchingTrackArtists}
          dispatch={dispatch}
          initialArtistCreditString={initialArtistCreditString}
        />
      ) : null}
      <Buttons
        dispatch={dispatch}
        initialBubbleFocus={initialBubbleFocus}
        initialFocusRef={initialFocusRef}
        isTrack={isTrack}
      />
    </form>
  );
}

const ArtistCreditBubble:
  component(...React.PropsOf<_ArtistCreditBubble>) =
  React.memo(_ArtistCreditBubble);

export default ArtistCreditBubble;
