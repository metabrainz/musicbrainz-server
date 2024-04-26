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
  +account_admin: FieldT<boolean>,
  +adding_notes_disabled: FieldT<boolean>,
  +auto_editor: FieldT<boolean>,
  +banner_editor: FieldT<boolean>,
  +biography: FieldT<string>,
  +bot: FieldT<boolean>,
  +editing_disabled: FieldT<boolean>,
  +email: FieldT<string>,
  +link_editor: FieldT<boolean>,
  +location_editor: FieldT<boolean>,
  +mbid_submitter: FieldT<boolean>,
  +no_nag: FieldT<boolean>,
  +show_exact: FieldT<boolean>,
  +skip_verification: FieldT<boolean>,
  +spammer: FieldT<boolean>,
  +untrusted: FieldT<boolean>,
  +username: FieldT<string>,
  +website: FieldT<string>,
  +wiki_transcluder: FieldT<boolean>,
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
          label="Editing/voting disabled"
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
        <FormRowEmailLong
          field={form.field.email}
          label="Email:"
          uncontrolled
        />
        <FormRowCheckbox
          field={form.field.skip_verification}
          label="Skip verification"
          uncontrolled
        />
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
        />

        <FormRow hasNoLabel>
          <FormSubmit label="Edit user" />
        </FormRow>
      </form>
    </UserAccountLayout>
  );
}

export default EditUser;
