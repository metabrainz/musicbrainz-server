// @flow
import React from 'react';

import Layout from '../layout';
import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import EditForm from './EditForm';

type Props = {
  $c: CatalystContextT,
  form: ReleaseGroupFormT,
  optionsPrimaryTypeId: SelectOptionsT,
  optionsSecondaryTypeIds: SelectOptionsT,
};

const Create = ({
  $c,
  form,
  optionsPrimaryTypeId,
  optionsSecondaryTypeIds,
}: Props) => {
  return (
    <Layout fullWidth title={l('Add Release Group')}>
      {manifest.js('edit')}
      <div id="content">
        <h1>{lp('Add Release Group', 'header')}</h1>
        <noscript>
          {l('Javascript is required for this page to work properly.')}
        </noscript>
        <EditForm
          entityType="release_group"
          form={form}
          formType="add"
          optionsPrimaryTypeId={optionsPrimaryTypeId}
          optionsSecondaryTypeIds={optionsSecondaryTypeIds}
          relationshipEditorHTML={$c.stash.relationship_editor_html}
          uri={$c.req.uri}
        />
        <div id="guesscase-options" />
      </div>
    </Layout>
  );
};

export default withCatalystContext(Create);
