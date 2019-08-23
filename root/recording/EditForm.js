// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useState, useEffect} from 'react';
import ReactDOM from 'react-dom';

import gc from '../static/scripts/guess-case/MB/GuessCase/Main';
import MB from '../static/scripts/common/MB';
import EnterEditNote from '../components/EnterEditNote';
import EnterEdit from '../components/EnterEdit';
import FormRow from '../components/FormRow';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import formatTrackLength from '../static/scripts/common/utility/formatTrackLength';
import GuessCaseOptions from '../components/GuessCaseOptions';
import WarningIcon from '../static/scripts/common/components/WarningIcon';
import hydrate from '../utility/hydrate';
import FormRowTextList from '../components/FormRowTextList';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowCheckbox from '../components/FormRowCheckbox';
import ISRCBubble from '../components/ISRCBubble';
import AddStandaloneRecording from '../edit/details/AddStandaloneRecording';
import EditRecording from '../edit/details/EditRecording';

type Props = {
  editEntity?: RecordingT,
  entityType: string,
  form: RecordingFormT,
  formType: string,
  relationshipEditorHTML: string,
  uri: string,
  usedByTracks: boolean,
};

const EditForm = ({
  editEntity,
  entityType,
  form,
  formType,
  relationshipEditorHTML,
  uri,
  usedByTracks,
}: Props) => {
  const guess = MB.GuessCase[entityType];
  console.log(form);

  const [name, setName] = useState(form.field.name.value ? form.field.name : {...form.field.name, value: ''});
  const [comment, setComment] = useState(form.field.comment);
  const [length, setLength] = useState(form.field.length);
  const [video, setVideo] = useState(form.field.video);
  const [isrcs, setIsrcs] = useState(form.field.isrcs);

  useEffect(() => {
    const $ = require('jquery');
    const $options = $('#guesscase-options');
    if ($options.length && !$options.data('ui-dialog')) {
      $options.dialog({autoOpen: false, title: l('Guess Case Options')});
      ReactDOM.render(<GuessCaseOptions />, $options[0]);
    }
  }, []);

  function generateAddPreviewData() {
    return {
      display_data: {
        comment: comment.value,
        length: length.value,
        name: name.value,
        recording: {
          comment: comment.value,
          length: length.value,
          name: name.value,
          video: video.value,
        },
        video: video.value,
      },
    };
  }

  function generateEditPreviewData() {
    return {
      display_data: {
        comment: {
          new: comment.value,
          old: form.field.comment.value,
        },
        length: {
          new: length.value,
          old: form.field.length.value,
        },
        name: {
          new: name.value,
          old: form.field.name.value,
        },
        recording: editEntity,
        video: {
          new: video.value,
          old: form.field.video.value,
        },
      },
    };
  }

  return (
    <>
      <div className="various-artists warning" style={{display: 'none'}}>
        <WarningIcon />
        <p>
          {l('<strong>Warning</strong>:')}
          {exp.l('You have used the {valink|Various Artists} special purpose artist on this recording.', {valink: '/doc/Style/Unknown_and_untitled/Special_purpose_artist#List_of_official_SPAs'})}
        </p>
        <p>
          {exp.l('{valink|Various Artists} should very rarely be used on recordings, make sure that the artist has been entered correctly.', {valink: '/doc/Style/Unknown_and_untitled/Special_purpose_artist#List_of_official_SPAs'})}
        </p>
      </div>

      <p>{exp.l('For more information, check the {doc_doc|documentation} and {doc_styleguide|style guidelines}.', {doc_doc: '/doc/Recording', doc_styleguide: '/doc/Style/Recording'})}</p>

      <form action={uri} className="edit-recording" method="post">
        <div className="half-width">
          <fieldset>
            <legend>{l('Recording Details')}</legend>
            <FormRowNameWithGuesscase
              field={name}
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
              options={{
                guessfeat: true,
                label: l('Name:'),
              }}
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
            {(form.field.length.has_errors || !usedByTracks)
              ? (
                <FormRowTextLong
                  field={length}
                  label={l('Length:')}
                  onChange={(e) => {
                    setLength({
                      ...length,
                      value: e.target.value,
                    });
                  }}
                />
              ) : (
                <FormRow>
                  <label>{l('Length:')}</label>
                  {exp.l('{recording_length} ({length_info|derived} from the associated track lengths)', {length_info: '/doc/Recording', recording_length: formatTrackLength(length.value)})}
                </FormRow>
              )}
            <FormRowCheckbox
              field={video}
              label={l('Video')}
              onChange={(e) => {
                setVideo({
                  ...video,
                  value: e.target.checked,
                });
              }}
            />
            <FormRowTextList
              field={isrcs}
              itemName={l('ISRCs')}
              label={l('ISRCs:')}
            />
          </fieldset>
          <div dangerouslySetInnerHTML={{__html: relationshipEditorHTML}} />
          <fieldset>
            <legend>{l('External Links')}</legend>
            <div id="external-links-editor-container" />
          </fieldset>
          <fieldset>
            <legend>{l('Changes')}</legend>
            {formType === 'Add'
              ? <AddStandaloneRecording edit={generateAddPreviewData()} />
              : <EditRecording edit={generateEditPreviewData()} />}
          </fieldset>
          <EnterEditNote field={form.field.edit_note} hideHelp />
          <EnterEdit form={form} />
        </div>
        <div className="documentation">
          <ISRCBubble />
        </div>
      </form>
    </>
  );
};

export default hydrate<Props>('div.recording-edit-from', EditForm);
