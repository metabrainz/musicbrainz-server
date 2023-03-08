/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type PropsT = {
  +form: ReadOnlyFormT<{
    +csrf_session_key?: ReadOnlyFieldT<string>,
    +csrf_token?: ReadOnlyFieldT<string>,
    ...
  }>,
};

const FormCsrfToken = ({form}: PropsT): React$Node => {
  const sessionKeyField = form.field.csrf_session_key;
  const tokenField = form.field.csrf_token;
  return (sessionKeyField && tokenField) ? (
    <>
      {sessionKeyField.errors.length ? (
        <p className="error">
          {sessionKeyField.errors[0]}
        </p>
      ) : null}
      <input
        name={sessionKeyField.html_name}
        type="hidden"
        value={sessionKeyField.value}
      />
      {tokenField.errors.length ? (
        <p className="error">
          {tokenField.errors[0]}
        </p>
      ) : null}
      <input
        name={tokenField.html_name}
        type="hidden"
        value={tokenField.value}
      />
    </>
  ) : null;
};

export default FormCsrfToken;
