/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component FormLabel(
  forField?: {+html_name: string, ...},
  label: React.Node,
  required?: boolean,
) {
  return (
    <label
      className={required /*:: === true */ ? 'required' : ''}
      htmlFor={forField ? 'id-' + forField.html_name : null}
    >
      {label}
    </label>
  );
}

export default FormLabel;
