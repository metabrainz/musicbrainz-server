/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import noop from 'lodash/noop';

import FormRow from '../../components/FormRow';
import FormRowText from '../../components/FormRowText';
import FormRowURLLong from '../../components/FormRowURLLong';
import FormSubmit from '../../components/FormSubmit';
import Layout from '../../layout';
import {addColon, l} from '../../static/scripts/common/i18n';
import {Lens, prop, set, compose3} from '../../static/scripts/common/utility/lens';
import getSelectValue from '../../utility/getSelectValue';
import hydrate from '../../utility/hydrate';

import type {OauthTypeT, ApplicationFormT} from './types';

type Props = {|
  +form: ApplicationFormT,
|};

const EditApplication = ({form}: Props) => (
  <Layout fullWidth title={l('Edit Application')}>
    <h1>{l('Edit Application')}</h1>
    <form method="post">
      <FormRowText
        field={form.field.name}
        label={addColon(l('Name'))}
        required
      />
      {form.field.oauth_type.value === 'web' ? (
        <FormRowURLLong
          field={form.field.oauth_redirect_uri}
          label={l('Callback URL:')}
        />
      ) : null}
      <input
        name="application.oauth_type"
        type="hidden"
        value={form.field.oauth_type.value}
      />
      <FormRow hasNoLabel>
        <FormSubmit label={l('Update')} />
      </FormRow>
    </form>
  </Layout>
);

export default EditApplication;
