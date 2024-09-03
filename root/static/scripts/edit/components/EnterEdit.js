/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type ControlledPropsT =
  | $ReadOnly<{
      controlled: true,
      onChange: (event: SyntheticEvent<HTMLInputElement>) => void,
    }>
  | $ReadOnly<{controlled?: false}>;

export component MakeVotable(
  disabled: boolean,
  field: FieldT<boolean>,
  inputProps: {
    checked?: boolean,
    defaultChecked?: boolean,
    onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
  },
) {
  return (
    <div className="row no-label">
      <div className="auto-editor">
        <label>
          <input
            className="make-votable"
            disabled={disabled}
            name={field.html_name}
            type="checkbox"
            value="1"
            {...inputProps}
          />
          {l('Make all edits votable.')}
        </label>
      </div>
    </div>
  );
}

component EnterEdit(
  children?: React.Node,
  childrenFirst: boolean = false,
  disabled: boolean = false,
  form: FormT<{+make_votable: FieldT<boolean>, ...}>,
  ...controlledProps: ControlledPropsT
) {
  const isMakeVotableChecked = form.field.make_votable.value;
  const makeVotableProps: {
    checked?: boolean,
    defaultChecked?: boolean,
    onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
  } = {};
  if (controlledProps.controlled /*:: === true */) {
    makeVotableProps.checked = isMakeVotableChecked;
    makeVotableProps.onChange = controlledProps.onChange;
  } else {
    makeVotableProps.defaultChecked = isMakeVotableChecked;
  }
  return (
    <>
      <MakeVotable
        disabled={disabled}
        field={form.field.make_votable}
        inputProps={makeVotableProps}
      />
      <div className="row no-label buttons">
        {childrenFirst ? children : null}
        <button
          className="submit positive"
          disabled={disabled}
          type="submit"
        >
          {l('Enter edit')}
        </button>
        {childrenFirst ? null : children}
      </div>
    </>
  );
}

export default EnterEdit;
