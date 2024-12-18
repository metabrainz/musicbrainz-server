/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import mutate from 'mutate-cow';
import * as React from 'react';
import {flushSync} from 'react-dom';
import {createRoot} from 'react-dom/client';

import {
  closeDialog as closeArtistCreditEditorDialog,
  createInitialState as createArtistCreditEditorState,
  reducer as artistCreditEditorReducer,
} from '../edit/components/ArtistCreditEditor.js';
import {
  KnockoutArtistCreditEditor,
} from '../edit/components/forms.js';

ko.bindingHandlers.disableBecauseDiscIDs = {

  update(element, valueAccessor, allBindings, viewModel) {
    var disabled = ko.unwrap(valueAccessor()) && viewModel.medium.hasToc();

    $(element)
      .prop('disabled', disabled)
      .toggleClass('disabled-hint', disabled)
      .attr(
        'title',
        disabled
          ? l(`This medium has one or more discids
               which prevent this information from being changed.`)
          : element.title,
      );
  },
};

function reduceReleaseArtistCreditEditor(state, action) {
  const stateCtx = mutate(state);
  const entity = state.entity;
  switch (action.type) {
    case 'next-track': {
      invariant(entity.entityType === 'track');

      const nextTrack = entity.next();
      if (nextTrack) {
        closeArtistCreditEditorDialog(stateCtx);
        /*
         * Because we're closing the existing popover, we must open the
         * new one before the next repaint to avoid flickering.
         */
        requestAnimationFrame(() => {
          flushSync(() => {
            nextTrack.artistCreditDispatch({
              type: 'open-dialog',
              initialFocus: action.initialFocus ?? 'next-track',
            });
          });
        });
      }
      break;
    }

    case 'previous-track': {
      invariant(entity.entityType === 'track');

      const previousTrack = entity.previous();
      if (previousTrack) {
        closeArtistCreditEditorDialog(stateCtx);
        requestAnimationFrame(() => {
          flushSync(() => {
            previousTrack.artistCreditDispatch({
              type: 'open-dialog',
              initialFocus: 'prev-track',
            });
          });
        });
      }
      break;
    }

    case 'set-change-matching-artists': {
      stateCtx.set('changeMatchingTrackArtists', action.checked);
      break;
    }

    default: {
      return artistCreditEditorReducer(state, action);
    }
  }

  return stateCtx.final();
}

ko.bindingHandlers.artistCreditEditor = {

  init(element, valueAccessor) {
    const entity = valueAccessor();
    const artistCredit = entity.artistCredit();

    const initialState = createArtistCreditEditorState({
      activeUser: window[GLOBAL_JS_NAMESPACE].$c.user,
      artistCredit,
      entity,
      id: entity.uniqueID,
    });

    const root = createRoot(element);
    root.render(
      <KnockoutArtistCreditEditor
        initialState={initialState}
        reducer={reduceReleaseArtistCreditEditor}
      />,
    );

    ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
      root.unmount();
    });
  },
};
