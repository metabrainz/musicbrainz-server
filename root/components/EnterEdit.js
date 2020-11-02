/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type Props = {
  +children?: React.Node,
  +disabled?: boolean,
  +form: ReadOnlyFormT<{
    +make_votable: ReadOnlyFieldT<boolean>,
    ...
  }>,
};

const EnterEdit = ({
  children,
  disabled = false,
  form,
}: Props): React.MixedElement => (
  <>
    <div className="row no-label">
      <div className="auto-editor">
        <label>
          <input
            className="make-votable"
            defaultChecked={form.field.make_votable.value}
            disabled={disabled}
            name={form.field.make_votable.html_name}
            type="checkbox"
            value="1"
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

export default EnterEdit;
