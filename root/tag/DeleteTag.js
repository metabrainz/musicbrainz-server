/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormSubmit from '../components/FormSubmit';

import TagLayout from './TagLayout';

type Props = {
  +$c: CatalystContextT,
  +deleteDownvoted?: boolean,
  +tag: TagT,
};

const DeleteTag = ({
  $c,
  deleteDownvoted = false,
  tag,
}: Props): React.Element<typeof TagLayout> | null => {
  const title = deleteDownvoted
    ? l('Delete tag downvotes')
    : l('Delete tag uses');
  const user = $c.user;

  return user ? (
    <TagLayout page="delete" tag={tag} title={title}>
      <h2>{title}</h2>
      <p>
        {exp.l(
          deleteDownvoted ? (
            `Are you sure you want to remove
             {tag_list|all your votes against the tag “{tag}”}?`
          ) : (
            `Are you sure you want to remove
             {tag_list|all your uses of the tag “{tag}”}?`
          ),
          {
            tag: tag.name,
            tag_list: '/user/' + encodeURIComponent(user.name) +
                      '/tag/' + encodeURIComponent(tag.name) +
                      '?show_downvoted=' + (deleteDownvoted ? '1' : '0'),
          },
        )}
      </p>
      <form action={$c.req.uri} method="post">
        <FormSubmit
          label={
            texp.l(
              deleteDownvoted
                ? 'Delete all my votes against “{tag}”'
                : 'Delete all my uses of “{tag}”',
              {tag: tag.name},
            )}
        />
      </form>

    </TagLayout>
  ) : null;
};

export default DeleteTag;
