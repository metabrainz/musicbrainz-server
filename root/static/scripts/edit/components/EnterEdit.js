/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type CommonProps = {
  +children?: React.Node,
  +disabled?: boolean,
  +form: ReadOnlyFormT<{
    +make_votable: ReadOnlyFieldT<boolean>,
    ...
  }>,
};

type Props =
  | $ReadOnly<{
      ...CommonProps,
      controlled: true,
      onChange: (event: SyntheticEvent<HTMLInputElement>) => void,
    }>
  | $ReadOnly<{
      ...CommonProps,
      controlled?: false,
    }>;

const EnterEdit = ({
  children,
  disabled = false,
  form,
  ...otherProps
}: Props): React.MixedElement => {
  const isMakeVotableChecked = form.field.make_votable.value;
  const makeVotableProps: {
    checked?: boolean,
    defaultChecked?: boolean,
    onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
  } = {};
  if (otherProps.controlled) {
    makeVotableProps.checked = isMakeVotableChecked;
    makeVotableProps.onChange = otherProps.onChange;
  } else {
    makeVotableProps.defaultChecked = isMakeVotableChecked;
  }
  return (
    <>
      <div className="row no-label">
        <div className="auto-editor">
          <label>
            <input
              className="make-votable"
              disabled={disabled}
              name={form.field.make_votable.html_name}
              type="checkbox"
              value="1"
              {...makeVotableProps}
            />
            {l('Make all edits votable.')}
          </label>
        </div>
      </div>
      <div className="row no-label buttons">
        <button
          className="submit positive"
          disabled={disabled}
          type="submit"
        >
          {l('Enter edit')}
        </button>
        {children}
      </div>
    </>
  );
};

export default EnterEdit;
