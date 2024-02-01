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
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import TagLayout from './TagLayout.js';

type Props = {
  +deleteDownvoted?: boolean,
  +tag: TagT,
};

const DeleteTag = ({
  deleteDownvoted = false,
  tag,
}: Props): React.Element<typeof TagLayout> | null => {
  const title = deleteDownvoted
    ? lp('Delete tag downvotes', 'folksonomy')
    : lp('Delete tag upvotes', 'folksonomy');
  const $c = React.useContext(CatalystContext);
  const user = $c.user;

  return user ? (
    <TagLayout page="delete" tag={tag} title={title}>
      <h2>{title}</h2>
      <p>
        {exp.l(
          deleteDownvoted ? (
            `Are you sure you want to remove
             {tag_list|all your downvotes of the tag “{tag}”}?`
          ) : (
            `Are you sure you want to remove
             {tag_list|all your upvotes of the tag “{tag}”}?`
          ),
          {
            tag: tag.name,
            tag_list: '/user/' + encodeURIComponent(user.name) +
                      '/tag/' + encodeURIComponent(tag.name) +
                      '?show_downvoted=' + (deleteDownvoted ? '1' : '0'),
          },
        )}
      </p>
      <p>
        {lp(
          'This can take a long time if you delete a large amount of tags.',
          'folksonomy',
        )}
      </p>
      <form action={$c.req.uri} method="post">
        <FormSubmit
          label={
            texp.l(
              deleteDownvoted
                ? 'Delete all my downvotes of “{tag}”'
                : 'Delete all my upvotes of “{tag}”',
              {tag: tag.name},
            )}
        />
      </form>

    </TagLayout>
  ) : null;
};

export default DeleteTag;
