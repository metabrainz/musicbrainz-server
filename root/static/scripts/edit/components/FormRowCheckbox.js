/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

type ControlledPropsT =
  | $ReadOnly<{
      onChange: (event: SyntheticEvent<HTMLInputElement>) => void,
      uncontrolled?: false,
    }>
  | $ReadOnly<{onChange?: void, uncontrolled: true}>;

component FormRowCheckbox(
  disabled?: boolean,
  field: FieldT<boolean>,
  hasNoLabel: boolean = true,
  hasNoMargin: boolean = false,
  help?: React$Node,
  label: React$Node,
  ...controlledProps: ControlledPropsT
) {
  const extraProps: {
    checked?: boolean,
    defaultChecked?: boolean,
    onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
  } = {};
  if (controlledProps.uncontrolled /*:: === true */) {
    extraProps.defaultChecked = field.value;
  } else {
    extraProps.onChange = controlledProps.onChange;
    extraProps.checked = field.value;
  }

  const showHelp = nonEmpty(help);

  return (
    <FormRow hasNoLabel={hasNoLabel} hasNoMargin={hasNoMargin}>
      <label className="inline">
        <input
          aria-describedby={showHelp ? `field-help-${field.id}` : null}
          disabled={disabled}
          id={'id-' + String(field.html_name)}
          name={field.html_name}
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
}

export default FormRowCheckbox;
