/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout from '../components/UserAccountLayout.js';
import {CatalystContext} from '../context.mjs';
import {
  LOCAL_ACCOUNTS_ENABLED,
} from '../static/scripts/common/DBDefs.mjs';
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
  readonly account_admin: FieldT<boolean>,
  readonly adding_notes_disabled: FieldT<boolean>,
  readonly auto_editor: FieldT<boolean>,
  readonly banner_editor: FieldT<boolean>,
  readonly biography: FieldT<string>,
  readonly bot: FieldT<boolean>,
  readonly editing_disabled: FieldT<boolean>,
  readonly email: FieldT<string>,
  readonly link_editor: FieldT<boolean>,
  readonly location_editor: FieldT<boolean>,
  readonly mbid_submitter: FieldT<boolean>,
  readonly no_nag: FieldT<boolean>,
  readonly show_exact: FieldT<boolean>,
  readonly spammer: FieldT<boolean>,
  readonly untrusted: FieldT<boolean>,
  readonly username: FieldT<string>,
  readonly voting_disabled: FieldT<boolean>,
  readonly website: FieldT<string>,
  readonly wiki_transcluder: FieldT<boolean>,
}>;

component EditUser(form: EditUserFormT, user: AccountLayoutUserT) {
  const $c = React.useContext(CatalystContext);
  const viewingOwnProfile = Boolean($c.user && $c.user.id === user.id);

  return (
    <UserAccountLayout
      entity={user}
      page="edit_user"
      title="Adjust user account flags"
    >
      <form method="post">
        <FormCsrfToken form={form} />

        <input name="submitted" type="hidden" value="1" />

        <h2>{'User permissions'}</h2>
        <FormRowCheckbox
          field={form.field.auto_editor}
          label="Auto-editor"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.wiki_transcluder}
          label="Transclusion editor"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.link_editor}
          label="Relationship editor"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.location_editor}
          label="Location editor"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.banner_editor}
          label="Banner message editor"
          uncontrolled
        />

        <h2>{'User sanctions'}</h2>
        <FormRowCheckbox
          field={form.field.spammer}
          label="Spammer"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.editing_disabled}
          label="Editing disabled"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.voting_disabled}
          label="Voting disabled"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.adding_notes_disabled}
          label="Edit notes disabled"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.untrusted}
          label="Untrusted"
          uncontrolled
        />

        <h2>{'Technical flags'}</h2>
        <FormRowCheckbox
          field={form.field.bot}
          label="Bot"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.no_nag}
          label="No nag"
          uncontrolled
        />

        <h2>{'Administration flags'}</h2>
        <FormRowCheckbox
          field={form.field.mbid_submitter}
          label="MBID submitter"
          uncontrolled
        />
        <FormRowCheckbox
          disabled={viewingOwnProfile}
          field={form.field.account_admin}
          label="Account admin"
          uncontrolled
        />

        <h2>{'Edit profile'}</h2>
        <FormRowText
          field={form.field.username}
          label="Username:"
          required
          uncontrolled
        />
        {LOCAL_ACCOUNTS_ENABLED ? (
          <FormRowEmailLong
            field={form.field.email}
            label="Email:"
            uncontrolled
          />
        ) : null}
        <FormRowURLLong
          field={form.field.website}
          label="Website:"
          uncontrolled
        />
        <FormRowTextArea
          cols={80}
          field={form.field.biography}
          label="Bio:"
          rows={5}
          uncontrolled
        />

        <FormRow hasNoLabel>
          <FormSubmit label="Edit user" />
        </FormRow>
      </form>
    </UserAccountLayout>
  );
}

export default EditUser;
