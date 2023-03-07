/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

type CommonProps = {
  +disabled?: boolean,
  +field: ReadOnlyFieldT<boolean>,
  +help?: React.Node,
  +label: string,
};

type Props =
  | $ReadOnly<{
      ...CommonProps,
      onChange: (event: SyntheticEvent<HTMLInputElement>) => void,
      uncontrolled?: false,
    }>
  | $ReadOnly<{
      ...CommonProps,
      uncontrolled: true,
    }>;

const FormRowCheckbox = ({
  disabled,
  field,
  help,
  label,
  // $FlowIssue[prop-missing]
  onChange,
  uncontrolled,
}: Props): React$Element<typeof FormRow> => {
  const extraProps: {
    checked?: boolean,
    defaultChecked?: boolean,
    onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
  } = {};
  if (uncontrolled) {
    extraProps.defaultChecked = field.value;
  } else {
    extraProps.onChange = onChange;
    extraProps.checked = field.value;
  }

  const showHelp = nonEmpty(help);

  return (
    <FormRow hasNoLabel>
      <label className="inline">
        <input
          aria-describedby={showHelp ? `field-help-${field.id}` : null}
          disabled={disabled}
          id={'id-' + String(field.html_name)}
          name={field.html_name}
          onChange={onChange}
          type="checkbox"
          value="1"
          {...extraProps}
        />
        {' '}
        {label}
      </label>
      <FieldErrors field={field} />
      {showHelp ? (
        <div className="form-help" id={`field-help-${field.id}`}>
          {help}
        </div>
      ) : null}
    </FormRow>
  );
};

export default FormRowCheckbox;
