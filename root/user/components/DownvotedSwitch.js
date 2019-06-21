/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {AccountLayoutUserT} from '../../components/UserAccountLayout';
import uriWith from '../../utility/uriWith';

type Props = {
  +$c: CatalystContextT,
  +showDownvoted: boolean,
  +tag: TagT,
  +user: AccountLayoutUserT,
};

const DownvotedSwitch = ({
  $c,
  showDownvoted,
  tag,
  user,
}: Props): React.Element<'p'> => (
  <p>
    {showDownvoted ? (
      exp.l(
        `Showing entities where {user} <strong>has voted against</strong>
         “{tag}” (or see {upvotes_link|entities {user}
         has tagged with “{tag}”} instead).`,
        {
          tag: tag.name,
          upvotes_link: uriWith($c.req.uri, {show_downvoted: 0}),
          user: user.name,
        },
      )
    ) : (
      exp.l(
        `Showing entities {user} <strong>has tagged</strong> with “{tag}”
         (or show {downvotes_link|entities where {user}
         has voted against “{tag}”} instead).`,
        {
          downvotes_link: uriWith($c.req.uri, {show_downvoted: 1}),
          tag: tag.name,
          user: user.name,
        },
      )
    )}
  </p>
);

export default DownvotedSwitch;
