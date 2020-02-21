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

type ToggleAllMediumsButtonsPropsT = {
  +dispatch: (LazyReleaseActionT) => void,
  +mediums: $ReadOnlyArray<MediumWithRecordingsT>,
};

export const ToggleAllMediumsButtons = (React.memo<
  ToggleAllMediumsButtonsPropsT,
>(({
  dispatch,
  mediums,
}: ToggleAllMediumsButtonsPropsT): React.MixedElement => (
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
)): React.AbstractComponent<ToggleAllMediumsButtonsPropsT>);

type MediumToolboxPropsT = {
  +creditsMode: CreditsModeT,
  +dispatch: (ActionT) => void,
  +mediums: $ReadOnlyArray<MediumWithRecordingsT>,
};

const MediumToolbox = (React.memo<MediumToolboxPropsT>(({
  creditsMode,
  dispatch,
  mediums,
}: MediumToolboxPropsT): React.Element<'span'> => (
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
        ? l('Display Credits Inline')
        : l('Display Credits at Bottom')}
    </button>
  </span>
)): React.AbstractComponent<MediumToolboxPropsT>);

export default MediumToolbox;
