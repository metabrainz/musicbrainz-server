/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';

import TagLayout from './TagLayout.js';

type Props = {
  +form: FormT<{
    +tags: FieldT<string>,
  }>,
  +tag: TagT,
};

const MoveTag = ({
  form,
  tag,
}: Props): React.Element<typeof TagLayout> | null => {
  const $c = React.useContext(CatalystContext);
  const user = $c.user;

  return user ? (
    <TagLayout
      page="delete"
      tag={tag}
      title={lp('Change tag uses', 'folksonomy')}
    >
      <h2>{lp('Change tag uses', 'folksonomy')}</h2>
      <p>
        {exp.lp(
          `This will change {tag_list|all your upvotes of tag “{tag}”}
           to the tag or tags you specify.`,
          'folksonomy',
          {
            tag: tag.name,
            tag_list: '/user/' + encodeURIComponent(user.name) +
                      '/tag/' + encodeURIComponent(tag.name),
          },
        )}
      </p>
      <p>
        {lp(
          `If you want to replace the tag with several others,
           enter them separated by commas.`,
          'folksonomy',
        )}
      </p>
      <p>
        {lp(
          'This can take a long time if you change a large amount of tags.',
          'folksonomy',
        )}
      </p>
      <form action={$c.req.uri} method="post">
        <FormRowText
          field={form.field.tags}
          label={addColonText(lp('New tag(s)', 'folksonomy'))}
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
