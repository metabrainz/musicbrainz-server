/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import mutate from 'mutate-cow';

import FormCsrfToken from '../../../../components/FormCsrfToken';
import FormRow from '../../../../components/FormRow';
import FormRowCheckbox from '../../../../components/FormRowCheckbox';
import FormRowSelect from '../../../../components/FormRowSelect';
import FormSubmit from '../../../../components/FormSubmit';
import {SanitizedCatalystContext} from '../../../../context';
import {formatUserDateObject} from '../../../../utility/formatUserDate';
import hydrate from '../../../../utility/hydrate';

type PreferencesFormT = FormT<{
  +csrf_token: FieldT<string>,
  +datetime_format: FieldT<string>,
  +email_on_no_vote: FieldT<boolean>,
  +email_on_notes: FieldT<boolean>,
  +email_on_vote: FieldT<boolean>,
  +notify_via_email: FieldT<boolean>,
  +public_ratings: FieldT<boolean>,
  +public_subscriptions: FieldT<boolean>,
  +public_tags: FieldT<boolean>,
  +show_gravatar: FieldT<boolean>,
  +subscribe_to_created_artists: FieldT<boolean>,
  +subscribe_to_created_labels: FieldT<boolean>,
  +subscribe_to_created_series: FieldT<boolean>,
  +subscriptions_email_period: FieldT<string>,
  +timezone: FieldT<string>,
}>;

type Props = {
  +form: PreferencesFormT,
  +timezone_options: MaybeGroupedOptionsT,
};

type State = {
  form: PreferencesFormT,
  timezoneOptions: MaybeGroupedOptionsT,
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

function buildDateTimeFormatOptions($c, timezone) {
  const hereAndNow = new Date();
  return {
    grouped: false,
    options: allowedDateTimeFormats.map(a => ({
      label: formatUserDateObject($c, hereAndNow, {format: a, timezone}),
      value: a,
    })),
  };
}

const subscriptionsEmailPeriodOptions = {
  grouped: false,
  options: [
    {label: N_l('Daily'), value: 'daily'},
    {label: N_l('Weekly'), value: 'weekly'},
    {label: N_l('Never'), value: 'never'},
  ],
};

class PreferencesForm extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {form: props.form, timezoneOptions: props.timezone_options};
    this.handleTimezoneChange = this.handleTimezoneChange.bind(this);
    this.handleTimezoneGuess = this.handleTimezoneGuess.bind(this);
    this.handleDateTimeFormatChange =
      this.handleDateTimeFormatChange.bind(this);
    this.handleSubscriptionsEmailPeriodChange =
      this.handleSubscriptionsEmailPeriodChange.bind(this);
  }

  handleTimezoneChange: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleTimezoneChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedTimezone = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.timezone.value = selectedTimezone;
    }));
  }

  handleTimezoneGuess: () => void;

  handleTimezoneGuess() {
    let maybeGuess;
    try {
      maybeGuess = Intl.DateTimeFormat().resolvedOptions().timeZone;
    } catch (e) {
      // ignored where Intl.DateTimeFormat is unsupported
    }
    const guess = maybeGuess;
    if (guess) {
      for (const option of this.state.timezoneOptions.options) {
        if (option.value === guess) {
          this.setState(prevState => mutate<State, _>(prevState, newState => {
            newState.form.field.timezone.value = guess;
          }));
          break;
        }
      }
    }
  }

  handleDateTimeFormatChange: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleDateTimeFormatChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedDateTimeFormat = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.datetime_format.value = selectedDateTimeFormat;
    }));
  }

  handleSubscriptionsEmailPeriodChange: (e: SyntheticEvent<HTMLSelectElement>)
    => void;

  handleSubscriptionsEmailPeriodChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedSubscriptionsEmailPeriod = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.subscriptions_email_period.value =
        selectedSubscriptionsEmailPeriod;
    }));
  }

  render() {
    const field = this.state.form.field;
    return (
      <form method="post">
        <FormCsrfToken form={this.state.form} />

        <fieldset>
          <legend>{l('Regional settings')}</legend>
          <FormRowSelect
            field={field.timezone}
            helpers={
              <>
                {' '}
                <button
                  className="guess-timezone icon"
                  onClick={this.handleTimezoneGuess}
                  title={l('Guess timezone')}
                  type="button"
                />
              </>
            }
            label={l('Timezone:')}
            onChange={this.handleTimezoneChange}
            options={this.state.timezoneOptions}
          />
          <SanitizedCatalystContext.Consumer>
            {$c => (
              <FormRowSelect
                field={field.datetime_format}
                label={l('Date/time format:')}
                onChange={this.handleDateTimeFormatChange}
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
          <FormRowCheckbox
            field={field.public_subscriptions}
            label={l('Allow other users to see my subscriptions')}
          />
          <FormRowCheckbox
            field={field.public_tags}
            label={l('Allow other users to see my tags')}
          />
          <FormRowCheckbox
            field={field.public_ratings}
            label={l('Allow other users to see my ratings')}
          />
          <FormRowCheckbox
            field={field.show_gravatar}
            label={l('Show my Gravatar')}
          />
        </fieldset>
        <fieldset>
          <legend>{l('Email')}</legend>
          <FormRowCheckbox
            field={field.email_on_no_vote}
            label={l(
              `Mail me when one of my edits gets a "no" vote.
               (Note: the email is only sent for the first "no" vote,
               not each one)`,
            )}
          />
          <FormRowCheckbox
            field={field.email_on_notes}
            label={l(
              `When I add a note to an edit,
               mail me all future notes for that edit.`,
            )}
          />
          <FormRowCheckbox
            field={field.email_on_vote}
            label={l(
              `When I vote on an edit,
               mail me all future notes for that edit.`,
            )}
          />
          <FormRowSelect
            field={field.subscriptions_email_period}
            label={l('Send me mails with edits to my subscriptions:')}
            onChange={this.handleSubscriptionsEmailPeriodChange}
            options={subscriptionsEmailPeriodOptions}
          />
        </fieldset>
        <fieldset>
          <legend>{l('Editing')}</legend>
          <FormRowCheckbox
            field={field.subscribe_to_created_artists}
            label={l('Automatically subscribe me to artists I create.')}
          />
          <FormRowCheckbox
            field={field.subscribe_to_created_labels}
            label={l('Automatically subscribe me to labels I create.')}
          />
          <FormRowCheckbox
            field={field.subscribe_to_created_series}
            label={l('Automatically subscribe me to series I create.')}
          />
        </fieldset>
        <FormRow hasNoLabel>
          <FormSubmit label={l('Save')} />
        </FormRow>
      </form>
    );
  }
}

export type PreferencesFormPropsT = Props;

export default (hydrate<Props>(
  'div.preferences-form',
  PreferencesForm,
): React.AbstractComponent<Props, void>);
