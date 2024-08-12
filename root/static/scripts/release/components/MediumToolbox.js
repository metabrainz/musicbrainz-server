/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {
  ActionT,
  CreditsModeT,
  LazyReleaseActionT,
} from '../types.js';

component _ToggleAllMediumsButtons(
  dispatch: (LazyReleaseActionT) => void,
  mediums: $ReadOnlyArray<MediumWithRecordingsT>,
) {
  return (
    <>
      <button
        className="btn-link"
        id="expand-all-mediums"
        onClick={() => {
          dispatch({
            expanded: true,
            mediums,
            type: 'toggle-all-mediums',
          });
        }}
        type="button"
      >
        {l('Expand all mediums')}
      </button>
      {' | '}
      <button
        className="btn-link"
        id="collapse-all-mediums"
        onClick={() => {
          dispatch({
            expanded: false,
            mediums,
            type: 'toggle-all-mediums',
          });
        }}
        type="button"
      >
        {l('Collapse all mediums')}
      </button>
    </>
  );
}

export const ToggleAllMediumsButtons: React.AbstractComponent<
  React.PropsOf<_ToggleAllMediumsButtons>
> = React.memo(_ToggleAllMediumsButtons);

component _MediumToolbox(
  creditsMode: CreditsModeT,
  dispatch: (ActionT) => void,
  mediums: $ReadOnlyArray<MediumWithRecordingsT>,
) {
  return (
    <span id="medium-toolbox">
      {mediums.length > 1 ? (
        <>
          <ToggleAllMediumsButtons
            dispatch={dispatch}
            mediums={mediums}
          />
          {' | '}
        </>
      ) : null}
      <button
        className="btn-link"
        id="toggle-credits"
        onClick={() => {
          dispatch({type: 'toggle-credits-mode'});
        }}
        type="button"
      >
        {creditsMode === 'bottom'
          ? l('Display credits inline')
          : l('Display credits at bottom')}
      </button>
    </span>
  );
}

const MediumToolbox: React.AbstractComponent<
  React.PropsOf<_MediumToolbox>
> = React.memo(_MediumToolbox);

export default MediumToolbox;
