// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import hydrate from '../utility/hydrate';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import GuessCaseOptions from '../components/GuessCaseOptions';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowSelect from '../components/FormRowSelect';
import escapeClosingTags from '../utility/escapeClosingTags';
import AddReleaseGroup from '../edit/details/AddReleaseGroup';
import EditReleaseGroup from '../edit/details/EditReleaseGroup';

type Props = {
  editEntity: ReleaseGroupT,
  entityType: string,
  form: ReleaseGroupFormT,
  formType: string,
  optionsPrimaryTypeId: SelectOptionsT,
  optionsSecondaryTypeIds: SelectOptionsT,
  relationshipEditorHTML?: string,
  uri: string,
};

const EditForm = ({
  editEntity,
  entityType,
  form,
  formType,
  optionsPrimaryTypeId,
  optionsSecondaryTypeIds,
  relationshipEditorHTML,
  uri,
}: Props) => {
  const guess = MB.GuessCase[entityType];
  const [
    name,
    setName,
  ] = useState(form.field.name.value ? form.field.name : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [
    primaryTypeId,
    setPrimaryTypeId,
  ] = useState(form.field.primary_type_id);
  const [
    secondaryTypeIds,
    setSecondaryTypeIds,
  ] = useState(form.field.secondary_type_ids);

  useEffect(() => {
    const $ = require('jquery');
    const $options = $('#guesscase-options');
    if ($options.length && !$options.data('ui-dialog')) {
      $options.dialog({autoOpen: false, title: l('Guess Case Options')});
      ReactDOM.render(<GuessCaseOptions />, $options[0]);
    }
  }, []);

  const primaryTypeOptions = {
    grouped: false,
    options: optionsPrimaryTypeId,
  };

  const secondartTypeOptions = {
    grouped: false,
    options: optionsSecondaryTypeIds,
  };

  const script = `$(function () {
    MB.initializeArtistCredit(
      ${JSON.stringify(form)},
      ${JSON.stringify(form.field.artist_credit)},
    );
    MB.Control.initialize_guess_case('release-group', 'id-edit-release-group');
    MB.Control.initGuessFeatButton('edit-release-group');
  });`;

  function typeUsed(optionNo) {
    const type = optionsPrimaryTypeId.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function secondaryTypeUsed(optionNo) {
    const type = optionsSecondaryTypeIds.find((option) => {
      return option.value === parseInt(optionNo, 10);
    });
    return type ? {
      name: type.label,
    } : null;
  }

  function generateAddPreview() {
    return {
      display_data: {
        comment: comment.value,
        name: name.value,
        release_group: {
          comment: comment.value,
          name: name.value,
          secondaryTypeIDs: [secondaryTypeIds.value],
          typeID: primaryTypeId.value,
        },
        secondary_types: secondaryTypeUsed(secondaryTypeIds.value),
        type: typeUsed(primaryTypeId.value),
      },
    };
  }

  function generateEditPreview() {
    return {
      display_data: {
        comment: {
          new: comment.value,
          old: form.field.comment.value,
        },
        name: {
          new: name.value,
          old: form.field.name.value,
        },
        release_group: editEntity,
        // secondary_types: {
        //   new: secondaryTypeUsed(secondaryTypeIds.value),
        //   old: secondaryTypeUsed(form.field.secondary_types.value),
        // },
        type: {
          new: typeUsed(primaryTypeId.value),
          old: typeUsed(form.field.primary_type_id.value),
        },
      },
    };
  }

  console.log(form);

  return (
    <>
      <noscript>
        {l('Javascript is required for this page to work properly.')}
      </noscript>
      <p>{exp.l('For more information, check the {doc_doc|documentation} and {doc_styleguide|style guidelines}.', {doc_doc: '/doc/Release_Group', doc_styleguide: '/doc/Style/Release_Group'})}</p>
      <form action={uri} method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Release Group Details')}</legend>
            <FormRowNameWithGuesscase
              field={name}
              label={l('Name')}
              onChangeInput={(e) => setName({
                ...name,
                value: e.target.value,
              })}
              onPressGuessCaseOptions={() => {
                const $ = require('jquery');
                return $('#guesscase-options').dialog('open');
              }}
              onPressGuessCaseTitle={() => setName({
                ...name,
                value: guess.guess(name.value),
              })}
              options={{guessfeat: true, label: l('Name')}}
              required
            />
            <div id="artist-credit-editor" />
            <FormRowTextLong
              field={comment}
              label={addColonText(l('Disambiguation'))}
              onChange={(e) => {
                setComment({
                  ...comment,
                  value: e.target.value,
                });
              }}
            />
            <FormRowSelect
              allowEmpty
              field={primaryTypeId}
              label={l('Primary Type:')}
              onChange={(e) => {
                setPrimaryTypeId({
                  ...primaryTypeId,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={primaryTypeOptions}
            />
            <FormRowSelect
              allowEmpty
              field={secondaryTypeIds}
              label={l('Secondary Types:')}
              multiple
              onChange={(e) => {
                setSecondaryTypeIds({
                  ...secondaryTypeIds,
                  // $FlowFixMe
                  value: e.target.value,
                });
              }}
              options={secondartTypeOptions}
            />
          </fieldset>
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <fieldset>
            <legend>{l('Changes')}</legend>
            {formType === 'add'
              ? <AddReleaseGroup edit={generateAddPreview()} />
              : <EditReleaseGroup edit={generateEditPreview()} />}
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>
      </form>
      <script dangerouslySetInnerHTML={{__html: script}} />
    </>
  );
};

export default hydrate<Props>('div.release-group-edit-form', EditForm);
