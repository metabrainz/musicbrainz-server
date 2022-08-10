/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRow from '../components/FormRow.js';
import FormRowTextLong from '../components/FormRowTextLong.js';
import {unwrapNl} from '../static/scripts/common/i18n.js';

type Props = {
  +form: FormT<{
    +comment: FieldT<string | null>,
    +nonce: FieldT<string>,
    +position?: FieldT<number>,
    +type_id: FieldT<Array<StrOrNum>>,
    ...
  }>,
  +typeIdOptions: SelectOptionsT,
};

const CoverArtFields = ({
  form,
  typeIdOptions,
}: Props): React.Element<typeof React.Fragment> => {
  const typeIdField = form.field.type_id;
  const selectedTypeIds = new Set(typeIdField.value.map(
    value => String(value),
  ));
  return (
    <>
      {form.field.position ? (
        <input
          id={'id-' + form.field.position.html_name}
          name={form.field.position.html_name}
          type="hidden"
          value={form.field.position.value}
        />
      ) : null}
      {form.field.nonce ? (
        <input
          id={'id-' + form.field.nonce.html_name}
          name={form.field.nonce.html_name}
          type="hidden"
          value={form.field.nonce.value}
        />
      ) : null}
      <FormRow>
        <fieldset className="cover-art-types row">
          <legend>{addColonText(l('Type'))}</legend>
          <ul className="cover-art-type-checkboxes">
            {typeIdOptions.map(option => (
              <li key={option.value}>
                <label>
                  <input
                    defaultChecked={selectedTypeIds.has(String(option.value))}
                    name={typeIdField.html_name}
                    type="checkbox"
                    value={option.value}
                  />
                  {unwrapNl<string>(option.label)}
                </label>
              </li>
            ))}
          </ul>
        </fieldset>
        <ul
          className="errors"
          id="cover-art-type-error"
          style={{display: 'none'}}
        >
          <li>{l('Choose one or more cover art types for this image')}</li>
        </ul>
        <FormRow>
          <label>{'\u00A0'}</label>
          <p>
            {exp.l(
              `Please see the {doc|Cover Art Types} documentation
               for a description of these types.`,
              {doc: {href: '/doc/Cover_Art/Types', target: '_blank'}},
            )}
          </p>
        </FormRow>
      </FormRow>
      <FormRowTextLong
        field={form.field.comment}
        label={l('Comment:')}
        uncontrolled
      />
    </>
  );
};

export default CoverArtFields;
