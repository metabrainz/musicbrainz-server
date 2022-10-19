/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Props = {
  +forField?: {+html_name: string, ...},
  +label: React$Node,
  +required?: boolean,
};

const FormLabel = (props: Props): React$Element<'label'> => (
  <label
    className={props.required /*:: === true */ ? 'required' : ''}
    htmlFor={props.forField ? 'id-' + props.forField.html_name : null}
  >
    {props.label}
  </label>
);

export default FormLabel;
