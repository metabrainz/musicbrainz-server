/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import {formatUserDateObject} from '../../../../utility/formatUserDate.js';
import FormCsrfToken from '../../edit/components/FormCsrfToken.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormSubmit from '../../edit/components/FormSubmit.js';

type PreferencesFormT = FormT<{
  +csrf_token: FieldT<string>,
  +datetime_format: FieldT<string>,
  +email_on_abstain: FieldT<boolean>,
  +email_on_no_vote: FieldT<boolean>,
  +email_on_notes: FieldT<boolean>,
  +email_on_vote: FieldT<boolean>,
  +notify_via_email: FieldT<boolean>,
  +public_ratings: FieldT<boolean>,
  +public_subscriptions: FieldT<boolean>,
  +public_tags: FieldT<boolean>,
  +subscribe_to_created_artists: FieldT<boolean>,
  +subscribe_to_created_labels: FieldT<boolean>,
  +subscribe_to_created_series: FieldT<boolean>,
  +subscriptions_email_period: FieldT<string>,
  +timezone: FieldT<string>,
}>;

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'guess-timezone', +options: GroupedOptionsT | SelectOptionsT}
  | {+type: 'set-time-format', +timeFormat: string}
  | {+type: 'set-timezone', +timezone: string};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +form: PreferencesFormT,
};

const allowedDateTimeFormats = [
  '%Y-%m-%d %H:%M %Z',
  '%c',
  '%x %X',
  '%X %x',
  '%A %B %e %Y, %H:%M',
  '%d %B %Y %H:%M',
  '%a %b %e %Y, %H:%M',
  '%d %b %Y %H:%M',
  '%d/%m/%Y %H:%M',
  '%m/%d/%Y %H:%M',
  '%d.%m.%Y %H:%M',
  '%m.%d.%Y %H:%M',
];

function buildDateTimeFormatOptions(
  $c: SanitizedCatalystContextT,
  timezone: string,
) {
  const hereAndNow = new Date();
  return {
    grouped: false as const,
    options: allowedDateTimeFormats.map(a => ({
      label: formatUserDateObject($c, hereAndNow, {format: a, timezone}),
      value: a,
    })),
  };
}

const subscriptionsEmailPeriodOptions = {
  grouped: false as const,
  options: [
    {label: N_l('Daily'), value: 'daily'},
    {label: N_l('Weekly'), value: 'weekly'},
    {label: N_l('Never'), value: 'never'},
  ],
};

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  switch (action.type) {
    case 'guess-timezone': {
      let maybeGuess;
      try {
        maybeGuess = Intl.DateTimeFormat().resolvedOptions().timeZone;
      } catch (ignoredError) {
        // ignored where Intl.DateTimeFormat is unsupported
      }
      const guess = maybeGuess;
      if (nonEmpty(guess)) {
        for (const option of action.options) {
          if (option.value === guess) {
            newStateCtx
              .set('form', 'field', 'timezone', 'value', guess);
            break;
          }
        }
      }
      break;
    }
    case 'set-time-format': {
      newStateCtx
        .set('form', 'field', 'datetime_format', 'value', action.timeFormat);
      break;
    }
    case 'set-timezone': {
      newStateCtx.set('form', 'field', 'timezone', 'value', action.timezone);
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newStateCtx.final();
}

component PreferencesForm(
  form as initialForm: PreferencesFormT,
  timezone_options: MaybeGroupedOptionsT,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    {form: initialForm},
  );

  const handleTimezoneChange = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    const selectedTimezone = event.currentTarget.value;
    dispatch({timezone: selectedTimezone, type: 'set-timezone'});
  }, [dispatch]);

  const handleTimezoneGuess = React.useCallback(() => {
    dispatch({options: timezone_options.options, type: 'guess-timezone'});
  }, [dispatch]);

  const handleDateTimeFormatChange = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    const selectedDateTimeFormat = event.currentTarget.value;
    dispatch({timeFormat: selectedDateTimeFormat, type: 'set-time-format'});
  }, [dispatch]);

  const field = state.form.field;
  return (
    <form method="post">
      <FormCsrfToken form={state.form} />

      <fieldset>
        <legend>{l('Regional settings')}</legend>
        <FormRowSelect
          field={field.timezone}
          helpers={
            <>
              {' '}
              <button
                className="guess-timezone icon"
                onClick={handleTimezoneGuess}
                title={l('Guess timezone')}
                type="button"
              />
            </>
          }
          label={l('Timezone:')}
          onChange={handleTimezoneChange}
          options={timezone_options}
        />
        <SanitizedCatalystContext.Consumer>
          {$c => (
            <FormRowSelect
              field={field.datetime_format}
              label={l('Date/time format:')}
              onChange={handleDateTimeFormatChange}
              options={buildDateTimeFormatOptions(
                $c,
                field.timezone.value,
              )}
            />
          )}
        </SanitizedCatalystContext.Consumer>
      </fieldset>
      <fieldset>
        <legend>{l('Privacy')}</legend>
        {addColonText(l('Allow other users to see'))}
        <FormRowCheckbox
          field={field.public_subscriptions}
          label={l('My subscriptions')}
          uncontrolled
        />
        <FormRowCheckbox
          field={field.public_tags}
          label={lp('My tags and genres', 'folksonomy')}
          uncontrolled
        />
        <FormRowCheckbox
          field={field.public_ratings}
          label={l('My ratings')}
          uncontrolled
        />
      </fieldset>
      <fieldset>
        <legend>{l('Email')}</legend>
        {addColonText(l('Email me about'))}
        <FormRowCheckbox
          field={field.email_on_no_vote}
          label={l('The first “no” vote on any of my edits')}
          uncontrolled
        />
        <FormRowCheckbox
          field={field.email_on_notes}
          label={l('Notes on edits I have left notes on')}
          uncontrolled
        />
        <FormRowCheckbox
          field={field.email_on_vote}
          label={l('Notes on edits I have voted on')}
          uncontrolled
        />
        <FormRowCheckbox
          field={field.email_on_abstain}
          label={l('Notes on edits I have abstained on')}
          uncontrolled
        />
        <br />
        <FormRowSelect
          field={field.subscriptions_email_period}
          label={addColonText(l(
            'Send me mails with edits to my subscriptions',
          ))}
          options={subscriptionsEmailPeriodOptions}
          uncontrolled
        />
      </fieldset>
      <fieldset>
        <legend>{l('Editing')}</legend>
        <div>
          {addColonText(l('Automatically subscribe me when I add'))}
          <FormRowCheckbox
            field={field.subscribe_to_created_artists}
            label={l('Artists')}
            uncontrolled
          />
          <FormRowCheckbox
            field={field.subscribe_to_created_labels}
            label={l('Labels')}
            uncontrolled
          />
          <FormRowCheckbox
            field={field.subscribe_to_created_series}
            label={lp('Series', 'plural')}
            uncontrolled
          />
        </div>
      </fieldset>
      <FormRow hasNoLabel>
        <FormSubmit label={lp('Save', 'interactive')} />
      </FormRow>
    </form>
  );
}

export default (hydrate<React.PropsOf<PreferencesForm>>(
  'div.preferences-form',
  PreferencesForm,
): component(...React.PropsOf<PreferencesForm>));
