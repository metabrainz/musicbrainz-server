// @flow

import React from 'react';

import chooseLayoutComponent from '../../utility/chooseLayoutComponent';
import * as manifest from '../../static/manifest';
import {withCatalystContext} from '../../context';

import EditForm from './EditForm';

type Props = {
  $c: CatalystContextT,
  entity: AliasT,
  form: AliasFormT,
  formType: string,
  localeOptions: Array<{|label: string, value: string|}>,
  type: string,
  typeOptions: Array<{|label: string, value: string|}>,
};

const AliasForm = ({
  $c,
  type,
  form,
  typeOptions,
  localeOptions,
  entity,
  formType,
}: Props) => {
  const LayoutComponent = chooseLayoutComponent(type);
  return (
    <LayoutComponent entity={entity} fullWidth title={l('Add Alias')}>
      {formType === 'add' ? <h2>{l('Add alias')}</h2> : <h2>{l('Edit alias')}</h2>}
      {manifest.js('edit')}
      <EditForm
        editKind={formType}
        entity={entity}
        entityType={type}
        form={form}
        localeOptions={localeOptions}
        typeId={entity.typeID}
        typeOptions={typeOptions}
        uri={$c.req.uri}
      />
      <div id="guesscase-options" />
    </LayoutComponent>
  );
};

export default withCatalystContext(AliasForm);
