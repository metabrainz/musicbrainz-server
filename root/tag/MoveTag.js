/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRowText from '../components/FormRowText';

import TagLayout from './TagLayout';

type Props = {
  +$c: CatalystContextT,
  +form: FormT<{
    +tags: ReadOnlyFieldT<string>,
  }>,
  +tag: TagT,
};

const MoveTag = ({
  $c,
  form,
  tag,
}: Props): React.Element<typeof TagLayout> | null => {
  const user = $c.user;

  return user ? (
    <TagLayout page="delete" tag={tag} title={l('Change tag uses')}>
      <h2>{l('Change tag uses')}</h2>
      <p>
        {exp.l(
          `This will change {tag_list|all your votes for tag “{tag}”}
           to the tag or tags you specify.`,
          {
            tag: tag.name,
            tag_list: '/user/' + encodeURIComponent(user.name) +
                      '/tag/' + encodeURIComponent(tag.name),
          },
        )}
      </p>
      <p>
        {l(`If you want to replace the tag with several others,
            enter them separated by commas.`)}
      </p>
      <form action={$c.req.uri} method="post">
        <FormRowText
          field={form.field.tags}
          label={addColonText(l('New tag(s)'))}
          required
          uncontrolled
        >
          {' '}
          <button type="submit">
            {l('Submit')}
          </button>
        </FormRowText>
      </form>


    </TagLayout>
  ) : null;
};

export default MoveTag;
