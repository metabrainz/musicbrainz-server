import React from 'react';

import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import SeriesLayout from './SeriesLayout';
import EditForm from './EditForm';

const Edit = ({
  $c,
  editEntity,
  form,
  optionsTypeId,
  optionsOrderingTypeId,
}) => {
  return (
    <SeriesLayout entity={editEntity} fullWidth page="edit" title={l('Edit')}>
      {manifest.js('edit')}
      <EditForm
        editEntity={editEntity}
        form={form}
        formType="edit"
        optionsOrderingTypeId={optionsOrderingTypeId}
        optionsTypeId={optionsTypeId}
        relationshipEditorHTML={$c.stash.relationship_editor_html}
        seriesOrderingTypes={$c.stash.series_ordering_types}
        seriesTypes={$c.stash.series_types}
        uri={$c.req.uri}
      />
      {manifest.js('series')}
    </SeriesLayout>
  );
};

export default withCatalystContext(Edit);
