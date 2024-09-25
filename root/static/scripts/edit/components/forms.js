/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as React from 'react';
import {flushSync} from 'react-dom';
import * as ReactDOMClient from 'react-dom/client';

import '../../common/entity.js';

import {createArtistObject} from '../../common/entity2.js';
import {
  artistCreditsAreEqual,
  reduceArtistCredit,
} from '../../common/immutable-entities.js';
import MB from '../../common/MB.js';

import {
  incompleteArtistCreditFromState,
} from './ArtistCreditEditor/utilities.js';
import ArtistCreditEditor, {
  createInitialState as createArtistCreditEditorState,
  reducer as artistCreditEditorReducer,
} from './ArtistCreditEditor.js';
import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

/*
 * Helper component to keep the ArtistCreditEditor in sync with a Knockout
 * observable.
 *
 *  * When the observable changes, we'll update the component state.
 *  * When the component state changes, we'll update the observable.
 *
 * There are also some release-editor-specific bits to handle the
 * `changeMatchingTrackArtists` option.
 */
export const KnockoutArtistCreditEditor = ({
  initialState,
  reducer,
}) => {
  const [state, dispatch] = React.useReducer(
    reducer,
    initialState,
  );

  const entity = state.entity;
  const isOpenRef = React.useRef(state.isOpen);
  const artistCreditRef = React.useRef(entity.artistCredit.peek());

  React.useEffect(() => {
    entity.artistCreditDispatch = dispatch;
    return () => {
      entity.artistCreditDispatch = null;
    };
  }, [entity, dispatch]);

  React.useEffect(() => {
    const newArtistCredit = incompleteArtistCreditFromState(state.names);
    if (!artistCreditsAreEqual(newArtistCredit, artistCreditRef.current)) {
      artistCreditRef.current = newArtistCredit;
      entity.artistCredit(newArtistCredit);
    }

    if (isOpenRef.current !== state.isOpen) {
      isOpenRef.current = state.isOpen;

      if (
        !state.isOpen &&
        // The dialog was closed; copy changes to the tracks.
        entity.entityType === 'track' &&
        state.changeMatchingTrackArtists
      ) {
        entity.medium.release.mediums()
          .flatMap(medium => medium.tracks())
          .forEach(function (otherTrack) {
            if (
              otherTrack !== entity &&
              state.initialArtistCreditString ===
                reduceArtistCredit(otherTrack.artistCredit.peek())
            ) {
              otherTrack.artistCredit(newArtistCredit);
            }
          });
      }
    }
  }, [
    entity,
    state.isOpen,
    state.names,
    state.changeMatchingTrackArtists,
    state.initialArtistCreditString,
  ]);

  React.useEffect(() => {
    const subscription = entity.artistCredit.subscribe((newArtistCredit) => {
      if (newArtistCredit !== artistCreditRef.current) {
        dispatch({
          artistCredit: newArtistCredit,
          type: 'set-names-from-artist-credit',
        });
      }
    });
    return () => {
      subscription.dispose();
    };
  }, [entity.artistCredit, dispatch]);

  return (
    <ArtistCreditEditor
      dispatch={dispatch}
      state={state}
    />
  );
};

export const FormRowArtistCredit = ({
  form,
  initialState,
}) => (
  <FormRow>
    <label className="required" htmlFor="ac-source-single-artist">
      {addColonText(l('Artist'))}
    </label>
    <KnockoutArtistCreditEditor
      initialState={initialState}
      reducer={artistCreditEditorReducer}
    />
    {form ? <FieldErrors field={form.field.artist_credit} /> : null}
  </FormRow>
);

MB.initializeArtistCredit = function (form, initialArtistCredit) {
  const source = MB.getSourceEntityInstance() ?? {name: ''};
  source.uniqueID = 'source';
  source.artistCredit = ko.observable({
    ...(initialArtistCredit ?? {}),
    names: (initialArtistCredit?.names ?? []).map((name) => {
      let artist = name.artist;
      if (!artist.id) {
        artist = {
          ...createArtistObject({name: name.name ?? ''}),
          ...name.artist,
        };
      }
      return {
        artist,
        joinPhrase: name.joinPhrase ?? '',
        name: name.name ?? '',
      };
    }),
  });

  const initialState = createArtistCreditEditorState({
    artistCredit: initialArtistCredit,
    entity: source,
    formName: form.name,
    id: 'source',
  });
  const container = document.getElementById('artist-credit-editor');
  const root = ReactDOMClient.createRoot(container);

  flushSync(() => {
    root.render(
      <FormRowArtistCredit
        form={form}
        initialState={initialState}
      />,
    );
  });
};

/*
 * Registers a beforeunload event listener on the window that prompts
 * the user if any of the page's form inputs have been changed.
 */
MB.installFormUnloadWarning = function () {
  let inputsChanged = false;
  let submittingForm = false;

  const form = document.querySelector('#page form');

  /*
   * This is somewhat heavy-handed, in that it will still warn even if the
   * user changes an input back to its original value.
   */
  form.addEventListener('change', () => {
    inputsChanged = true;
  });

  // Disarm the warning when the form is being submitted.
  form.addEventListener('submit', () => {
    submittingForm = true;
  });

  window.addEventListener('beforeunload', event => {
    if (submittingForm) {
      return false;
    }

    // Check if there are pending relationship or URL changes.
    if (!inputsChanged && !form.querySelector([
      '#relationship-editor .rel-add',
      '#relationship-editor .rel-edit',
      '#relationship-editor .rel-remove',
      '#external-links-editor .rel-add',
      '#external-links-editor .rel-edit',
      '#external-links-editor .rel-remove',
    ].join(', '))) {
      return false;
    }

    if (MUSICBRAINZ_RUNNING_TESTS) {
      sessionStorage.setItem('didShowBeforeUnloadAlert', 'true');
    }

    event.returnValue = l(
      'All of your changes will be lost if you leave this page.',
    );
    return event.returnValue;
  });
};
