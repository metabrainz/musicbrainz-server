/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FieldErrors from './FieldErrors';
import FormRow from './FormRow';

type Props = {
  +field: ReadOnlyFieldT<string>,
  +hideHelp?: boolean,
};

const EnterEditNote = ({
  field,
  hideHelp = false,
}: Props) => (
  <fieldset className="editnote">
    <legend>{l('Edit Note')}</legend>
    {hideHelp ? null : (
      <>
        <p>
          {exp.l(
            `Entering an {note|edit note} that describes where you got
             your information is highly recommended. Not only does it
             make your sources clear (both now and to users who see the
             edit years later), but it can also encourage other users
             to vote on the edit — thus making it get applied faster.`,
            {note: {href: '/doc/Edit_Note', target: '_blank'}},
          )}
        </p>
        <p>
          {exp.l(
            `Even just providing a URL or two is helpful!
             For more suggestions,
             see {doc_how_to|our guide for writing good edit notes}.`,
            {
              doc_how_to: {
                href: '/doc/How_to_Write_Edit_Notes',
                target: '_blank',
              },
            },
          )}
        </p>
      </>
    )}
    <FormRow>
      <label htmlFor="edit-note-text">{l('Edit note:')}</label>
      <textarea
        className="edit-note"
        cols="80"
        defaultValue={field.value}
        id="edit-note-text"
        name={field.html_name}
        rows="5"
      />
      <FieldErrors field={field} />
    </FormRow>
  </fieldset>
);

export default EnterEditNote;
