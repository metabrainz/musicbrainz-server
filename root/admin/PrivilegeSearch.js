/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';
import {l_admin} from '../static/scripts/common/i18n/admin.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import UserList from './components/UserList.js';

type Props = {
  +form: FormT<{
    +account_admin: ReadOnlyFieldT<boolean>,
    +adding_notes_disabled: ReadOnlyFieldT<boolean>,
    +auto_editor: ReadOnlyFieldT<boolean>,
    +banner_editor: ReadOnlyFieldT<boolean>,
    +bot: ReadOnlyFieldT<boolean>,
    +editing_disabled: ReadOnlyFieldT<boolean>,
    +link_editor: ReadOnlyFieldT<boolean>,
    +location_editor: ReadOnlyFieldT<boolean>,
    +mbid_submitter: ReadOnlyFieldT<boolean>,
    +no_nag: ReadOnlyFieldT<boolean>,
    +show_exact: ReadOnlyFieldT<boolean>,
    +spammer: ReadOnlyFieldT<boolean>,
    +untrusted: ReadOnlyFieldT<boolean>,
    +wiki_transcluder: ReadOnlyFieldT<boolean>,
  }>,
  +pager?: PagerT,
  +results: $ReadOnlyArray<UnsanitizedEditorT> | null,
};

const PrivilegeSearch = ({
  form,
  pager,
  results,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title="Search users by privileges">
    <div id="content">
      <h1>{'Search users by privileges'}</h1>

      <form action="/admin/privilege-search" method="get">
        <p>
          {l_admin(`Select the flags you want to match. Editors which have
                    other flags in addition to the selected ones will also be
                    shown, unless you select “Exact match only” below.`)}
        </p>

        <div className="checkbox-block">
          <FormRowCheckbox
            field={form.field.show_exact}
            label="Exact match only"
            uncontrolled
          />
        </div>

        <h2>{'User permissions'}</h2>
        <div className="checkbox-block">
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
        </div>

        <h2>{'User sanctions'}</h2>
        <div className="checkbox-block">
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
        </div>

        <h2>{'Technical flags'}</h2>
        <div className="checkbox-block">
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
        </div>

        <h2>{'Administration flags'}</h2>
        <div className="checkbox-block">
          <FormRowCheckbox
            field={form.field.mbid_submitter}
            label="MBID submitter"
            uncontrolled
          />
          <FormRowCheckbox
            field={form.field.account_admin}
            label="Account admin"
            uncontrolled
          />
        </div>

        <div className="row no-margin">
          <FormSubmit label="Search" />
        </div>

        {pager ? (
          <PaginatedResults pager={pager}>
            <UserList users={results || []} />
          </PaginatedResults>
        ) : null}
      </form>
    </div>
  </Layout>
);

export default PrivilegeSearch;
