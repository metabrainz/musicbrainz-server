// @flow
import React from 'react';

import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import SeriesLayout from './SeriesLayout';
import EditForm from './EditForm';

type Props = {
  $c: CatalystContextT,
  editEntity: SeriesT,
  form: SeriesFormT,
  optionsOrderingTypeId: SelectOptionsT,
  optionsTypeId: SelectOptionsT,
};

const Edit = ({
  $c,
  editEntity,
  form,
  optionsTypeId,
  optionsOrderingTypeId,
}: Props) => {
  return (
    <SeriesLayout entity={editEntity} fullWidth page="edit" title={l('Edit')}>
      {manifest.js('edit')}
      <EditForm
        editEntity={editEntity}
        entityType="series"
        form={form}
        formType="edit"
        optionsOrderingTypeId={optionsOrderingTypeId}
        optionsTypeId={optionsTypeId}
        relationshipEditorHTML={$c.stash.relationship_editor_html}
        seriesOrderingTypes={$c.stash.series_ordering_types}
        seriesTypes={$c.stash.series_types}
        uri={$c.req.uri}
      />
      <div id="guesscase-options" />
      {manifest.js('series')}
    </SeriesLayout>
  );
};

export default withCatalystContext(Edit);
