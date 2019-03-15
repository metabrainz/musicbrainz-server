/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EnterEdit from '../components/EnterEdit';
import EnterEditNote from '../components/EnterEditNote';
import FieldErrors from '../components/FieldErrors';
import RecordingsList from '../components/RecordingsList';
import {withCatalystContext} from '../context';
import Layout from '../layout';

type RecordingMergeForm = FormT<{|
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +merging: RepeatableFieldT<FieldT<number>>,
  +rename: FieldT<boolean>,
  +target: FieldT<number>,
|}>;

type Props = {|
  +$c: CatalystContextT,
  +form: RecordingMergeForm,
  +isrcsDiffer?: boolean,
  +toMerge: $ReadOnlyArray<RecordingT>,
|};

const RecordingMerge = ({$c, form, isrcsDiffer, toMerge}: Props) => {
  function renderCheckboxElement(recording, index) {
    return (
      <>
        <input
          name={'merge.merging.' + index}
          type="hidden"
          value={recording.id}
        />
        <input
          checked={recording.id === form.field.target.value}
          name="merge.target"
          type="radio"
          value={recording.id}
        />
      </>
    );
  }
  return (
    <Layout fullWidth title={l('Merge Recordings')}>
      <div id="content">
        <h1>{l('Merge Recordings')}</h1>
        <p>
          {l(`You are about to merge the following recordings into a single
              recording. Please select the recording which you would like other
              recordings to be merged into:`)}
        </p>
        {isrcsDiffer ? (
          <div className="warning warning-isrcs-differ">
            <p>
              {exp.l(`<strong>Warning:</strong> Some of the recordings you're
                      merging have different ISRCs. Please make sure they are
                      indeed the same recordings and you wish to continue with
                      the merge.`)}
            </p>
          </div>
        ) : null}
        <form action={$c.req.uri} method="post">
          <RecordingsList
            recordings={toMerge}
            renderCheckboxElement={renderCheckboxElement}
            showArtists
          />
          <FieldErrors field={form.field.target} />

          <EnterEditNote field={form.field.edit_note} />

          <EnterEdit form={form}>
            <button
              className="negative"
              name="submit"
              type="submit"
              value="cancel"
            >
              {l('Cancel')}
            </button>
          </EnterEdit>
        </form>
      </div>
    </Layout>
  );
};
export default withCatalystContext(RecordingMerge);
