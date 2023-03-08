/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ENTITY_NAMES} from '../../common/constants.js';
import HelpIcon from '../../edit/components/HelpIcon.js';
import {stripAttributes} from '../../edit/utility/linkPhrase.js';
import type {
  DialogEntityCreditStateT,
} from '../types.js';
import type {
  DialogEntityCreditActionT,
} from '../types/actions.js';

type PropsT = {
  +backward: boolean,
  +dispatch: (DialogEntityCreditActionT) => void,
  +entityName: string,
  +forEntity: string,
  +linkType: ?LinkTypeT,
  +state: $ReadOnly<{...DialogEntityCreditStateT, ...}>,
  +targetType: CoreEntityTypeT,
};

export function createInitialState(
  creditedAs: string,
  releaseHasUnloadedTracks: boolean,
): DialogEntityCreditStateT {
  return {
    creditedAs,
    creditsToChange: '',
    releaseHasUnloadedTracks,
  };
}

export function reducer<T: $ReadOnly<{...DialogEntityCreditStateT, ...}>>(
  state: T,
  action: DialogEntityCreditActionT,
): T {
  const newState: {...T, ...} = {...state};

  switch (action.type) {
    case 'set-credit': {
      newState.creditedAs = action.creditedAs;
      break;
    }
    case 'set-credits-to-change': {
      newState.creditsToChange = action.value;
      break;
    }
    default: {
      /*:: exhaustive(action); */
      invariant(false);
    }
  }

  return newState;
}

const DialogEntityCredit = (React.memo<PropsT, void>(({
  backward,
  dispatch,
  entityName,
  forEntity,
  linkType,
  state,
  targetType,
}: PropsT): React$MixedElement => {
  const origCredit = React.useRef(state.creditedAs || '');
  const inputRef = React.useRef<HTMLInputElement | null>(null);
  const inputId = React.useId();

  function handleCreditedAsChange(event: SyntheticEvent<HTMLInputElement>) {
    dispatch({
      creditedAs: event.currentTarget.value,
      type: 'set-credit',
    });
  }

  function handleChangeCreditsChecked(
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    dispatch({
      type: 'set-credits-to-change',
      value: event.currentTarget.checked ? 'all' : '',
    });
  }

  function handleChangedCreditsSelection(
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    dispatch({
      type: 'set-credits-to-change',
      // $FlowIgnore[unclear-type]
      value: (event.currentTarget.value: any),
    });
  }

  let changeCreditsSection;
  if (
    state.creditsToChange ||
    state.creditedAs !== '' ||
    state.creditedAs !== origCredit.current
  ) {
    changeCreditsSection = (
      <>
        <br />
        <label className="change-credits-checkbox">
          <input
            checked={!!state.creditsToChange}
            disabled={state.releaseHasUnloadedTracks}
            onChange={handleChangeCreditsChecked}
            type="checkbox"
          />
          <span>
            {exp.l(
              `Change credits for other {entity} relationships
                on the page.`,
              {entity: <bdi>{entityName}</bdi>},
            )}
          </span>
        </label>
        {state.releaseHasUnloadedTracks ? (
          <div className="form-help">
            <p>
              {l(`Some tracks/mediums haven’t been loaded yet. If you want
                  to use this option, please close this dialog and load all
                  tracks/mediums beforehand.`)}
            </p>
          </div>
        ) : (
          state.creditsToChange ? (
            <div className="change-credits-radio-options">
              <label>
                <input
                  checked={state.creditsToChange === 'all'}
                  name="changed-credits"
                  onChange={handleChangedCreditsSelection}
                  type="radio"
                  value="all"
                />
                {l('All of these relationships.')}
              </label>

              <label>
                <input
                  checked={state.creditsToChange === 'same-entity-types'}
                  name="changed-credits"
                  onChange={handleChangedCreditsSelection}
                  type="radio"
                  value="same-entity-types"
                />
                <span>
                  {texp.l('Only relationships to {entity_type} entities.', {
                    entity_type: ENTITY_NAMES[targetType](),
                  })}
                </span>
              </label>

              {linkType ? (
                <label>
                  <input
                    checked={
                      state.creditsToChange === 'same-relationship-type'}
                    name="changed-credits"
                    onChange={handleChangedCreditsSelection}
                    type="radio"
                    value="same-relationship-type"
                  />
                  <span>
                    {texp.l(
                      `Only “{relationship_type}” relationships to
                      {entity_type} entities.`,
                      {
                        entity_type: ENTITY_NAMES[targetType](),
                        relationship_type: stripAttributes(
                          linkType,
                          l_relationships(
                            backward
                              ? linkType.reverse_link_phrase
                              : linkType.link_phrase,
                          ),
                        ),
                      },
                    )}
                  </span>
                </label>
              ) : null}
            </div>
          ) : null
        )}
      </>
    );
  }

  const helpText = l(
    `A credited name is optional. You can leave this field blank
     to keep the current name.`,
  );

  return (
    <div className={forEntity + '-entity-credit'}>
      <input
        aria-description={helpText}
        aria-label={l('Credited as')}
        className="entity-credit"
        id={inputId}
        onChange={handleCreditedAsChange}
        placeholder={l('Credited as')}
        ref={inputRef}
        type="text"
        value={state.creditedAs}
      />
      <HelpIcon content={helpText} />
      {changeCreditsSection}
    </div>
  );
}): React.AbstractComponent<PropsT, void>);

export default DialogEntityCredit;
