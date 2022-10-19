/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout.js';
import {CatalystContext} from '../context.mjs';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import FormRowEmailLong
  from '../static/scripts/edit/components/FormRowEmailLong.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';
import FormRowURLLong
  from '../static/scripts/edit/components/FormRowURLLong.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

type EditUserFormT = FormT<{
  ...SecureConfirmFormT,
  +account_admin: ReadOnlyFieldT<boolean>,
  +adding_notes_disabled: ReadOnlyFieldT<boolean>,
  +auto_editor: ReadOnlyFieldT<boolean>,
  +banner_editor: ReadOnlyFieldT<boolean>,
  +biography: ReadOnlyFieldT<string>,
  +bot: ReadOnlyFieldT<boolean>,
  +editing_disabled: ReadOnlyFieldT<boolean>,
  +email: ReadOnlyFieldT<string>,
  +link_editor: ReadOnlyFieldT<boolean>,
  +location_editor: ReadOnlyFieldT<boolean>,
  +mbid_submitter: ReadOnlyFieldT<boolean>,
  +no_nag: ReadOnlyFieldT<boolean>,
  +show_exact: ReadOnlyFieldT<boolean>,
  +skip_verification: ReadOnlyFieldT<boolean>,
  +spammer: ReadOnlyFieldT<boolean>,
  +untrusted: ReadOnlyFieldT<boolean>,
  +username: ReadOnlyFieldT<string>,
  +website: ReadOnlyFieldT<string>,
  +wiki_transcluder: ReadOnlyFieldT<boolean>,
}>;

type Props = {
  +form: EditUserFormT,
  +user: AccountLayoutUserT,
};

const EditUser = ({
  form,
  user,
}: Props): React$Element<typeof UserAccountLayout> => {
  const $c = React.useContext(CatalystContext);
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  return (
    <UserAccountLayout
      entity={user}
      page="edit_user"
      title={l('Adjust User Account Flags')}
    >
      <form method="post">
        <FormCsrfToken form={form} />

        <input name="submitted" type="hidden" value="1" />

        <h2>{l('User permissions')}</h2>
        <FormRowCheckbox
          field={form.field.auto_editor}
          label={l('Auto-editor')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.wiki_transcluder}
          label={l('Transclusion editor')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.link_editor}
          label={l('Relationship editor')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.location_editor}
          label={l('Location editor')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.banner_editor}
          label={l('Banner message editor')}
          uncontrolled
        />

        <h2>{l('User sanctions')}</h2>
        <FormRowCheckbox
          field={form.field.spammer}
          label={l('Spammer')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.editing_disabled}
          label={l('Editing/voting disabled')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.adding_notes_disabled}
          label={l('Edit notes disabled')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.untrusted}
          label={l('Untrusted')}
          uncontrolled
        />

        <h2>{l('Technical flags')}</h2>
        <FormRowCheckbox
          field={form.field.bot}
          label={l('Bot')}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.no_nag}
          label={l('No nag')}
          uncontrolled
        />

        <h2>{l('Administration flags')}</h2>
        <FormRowCheckbox
          field={form.field.mbid_submitter}
          label={exp.l(
            '<abbr title="MusicBrainz Identifier">MBID</abbr> submitter',
          )}
          uncontrolled
        />
        <FormRowCheckbox
          disabled={viewingOwnProfile}
          field={form.field.account_admin}
          label={l('Account admin')}
          uncontrolled
        />

        <h2>{l('Edit profile')}</h2>
        <FormRowText
          field={form.field.username}
          label={addColonText(l('Username'))}
          required
          uncontrolled
        />
        <FormRowEmailLong
          field={form.field.email}
          label={addColonText(l('Email'))}
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.skip_verification}
          label={l('Skip verification')}
          uncontrolled
        />
        <FormRowURLLong
          field={form.field.website}
          label={addColonText(l('Website'))}
          uncontrolled
        />
        <FormRowTextArea
          cols={80}
          field={form.field.biography}
          label={l('Bio:')}
          rows={5}
        />

        <FormRow hasNoLabel>
          <FormSubmit label={l('Edit user')} />
        </FormRow>
      </form>
    </UserAccountLayout>
  );
};

export default EditUser;
