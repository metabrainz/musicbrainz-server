/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormLabel from '../components/FormLabel';
import FormRow from '../components/FormRow';
import FormRowTextLong from '../components/FormRowTextLong';
import SelectField from '../components/SelectField';

type Props = {
  +form: FormT<{
    +comment: FieldT<string | null>,
    +position?: FieldT<number>,
    +type_id: FieldT<number>,
    ...
  }>,
  +typeIdOptions: SelectOptionsT,
};

const CoverArtFields = ({
  form,
  typeIdOptions,
}: Props): React.Element<typeof React.Fragment> => (
  <>
    {form.field.position ? (
      <input
        name={form.field.position.html_name}
        type="hidden"
        value={form.field.position.value}
      />
    ) : null}
    <FormRow>
      <FormLabel
        forField={form.field.type_id}
        label={addColonText(l('Type'))}
      />
      <SelectField
        field={form.field.type_id}
        multiple
        options={{grouped: false, options: typeIdOptions}}
        size="5"
        style={{width: '10em'}}
        uncontrolled
      />
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

export default CoverArtFields;
