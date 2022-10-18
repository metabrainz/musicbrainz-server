/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import Layout from '../layout/index.js';
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
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Search users by privileges')}>
    <div id="content">
      <h1>{l('Search users by privileges')}</h1>

      <form action="/admin/privilege-search" method="get">
        <p>
          {l(`Select the flags you want to match. Editors which have
              other flags in addition to the selected ones will also be shown,
              unless you select “Exact match only” below.`)}
        </p>

        <div className="checkbox-block">
          <FormRowCheckbox
            field={form.field.show_exact}
            label={l('Exact match only')}
            uncontrolled
          />
        </div>

        <h2>{l('User permissions')}</h2>
        <div className="checkbox-block">
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
        </div>

        <h2>{l('User sanctions')}</h2>
        <div className="checkbox-block">
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
        </div>

        <h2>{l('Technical flags')}</h2>
        <div className="checkbox-block">
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
        </div>

        <h2>{l('Administration flags')}</h2>
        <div className="checkbox-block">
          <FormRowCheckbox
            field={form.field.mbid_submitter}
            label={l('MBID submitter')}
            uncontrolled
          />
          <FormRowCheckbox
            field={form.field.account_admin}
            label={l('Account admin')}
            uncontrolled
          />
        </div>

        <div className="row no-margin">
          <FormSubmit label={l('Search')} />
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
