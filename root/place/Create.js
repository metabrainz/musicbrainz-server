// @flow
import React from 'react';

import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import {withCatalystContext} from '../context';

import EditForm from './EditForm';

type Props = {
  $c: CatalystContextT,
  entity: PlaceT,
  form: PlaceFormT,
};

const Create = ({$c, form, entity}: Props) => {
  console.log(form);
  const LayoutComponent = chooseLayoutComponent("place");
  return (
    <LayoutComponent entity={entity} fullWidth title={l('Add Place')}>
      <div id="content">
        <h1>{l("Add Place")}</h1>
        <EditForm
          uri={$c.req.uri}
          form={form}
        />
      </div>
    </LayoutComponent>
  )
};

export default withCatalystContext(Create);