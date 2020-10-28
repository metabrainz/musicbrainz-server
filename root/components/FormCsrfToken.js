/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type PropsT = {
  +form: ReadOnlyFormT<{
    +csrf_token?: ReadOnlyFieldT<string>,
    ...
  }>,
};

const FormCsrfToken = ({form}: PropsT): React.Node => {
  const field = form.field.csrf_token;
  return field ? (
    <>
      {field.errors.length ? (
        <p className="error">
          {field.errors[0]}
        </p>
      ) : null}
      <input
        name={field.html_name}
        type="hidden"
        value={field.value}
      />
    </>
  ) : null;
};

export default FormCsrfToken;
