/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import noop from 'lodash/noop';
import React from 'react';

import {withCatalystContext} from '../context';
import FormRowSelect from '../components/FormRowSelect';
import FormRowTextArea from '../components/FormRowTextArea';
import FormRowTextLong from '../components/FormRowTextLong';
import FormSubmit from '../components/FormSubmit';
import FormRowCheckbox from '../components/FormRowCheckbox';

import type {CollectionFormT} from './types';

type Props = {|
  +$c: CatalystContextT,
  +collectionTypes: SelectOptionsT,
  +form: CollectionFormT,
|};

const CollectionEditForm = ({$c, collectionTypes, form}: Props) => {
  const typeOptions = {
    grouped: false,
    options: collectionTypes,
  };

  return (
    <form action={$c.req.uri} method="post">
      <fieldset>
        <legend>{l('Collection details')}</legend>
        <FormRowTextLong
          field={form.field.name}
          label={addColonText(l('Name'))}
          required
        />
        <FormRowSelect
          field={form.field.type_id}
          label={addColonText(l('Type'))}
          onChange={noop}
          options={typeOptions}
        />
        <FormRowTextArea
          field={form.field.description}
          label={addColonText(l('Description'))}
        />
        <FormRowCheckbox
          field={form.field.public}
          label={l('Allow other users to see this collection')}
        />
      </fieldset>

      <div className="row no-label">
        {$c.action.name === 'create' ? (
          <FormSubmit label={l('Create collection')} />
        ) : (
          <FormSubmit label={l('Update collection')} />
        )}
      </div>
    </form>
  );
};

export default withCatalystContext(CollectionEditForm);
