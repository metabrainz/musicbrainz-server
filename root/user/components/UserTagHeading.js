/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import TagLink from '../../static/scripts/common/components/TagLink';
import {bracketedText} from '../../static/scripts/common/utility/bracketed';
import {formatPluralEntityTypeName}
  from '../../static/scripts/common/utility/formatEntityTypeName';

type Props = {
  +entityType?: string,
  +showDownvoted: boolean,
  +tag: TagT,
};

const UserTagHeading = ({
  entityType,
  showDownvoted,
  tag,
}: Props): React.Element<'h2'> => {
  const tagElement = <TagLink tag={tag.name} />;
  return (
    <h2>
      {showDownvoted
        ? exp.l('Votes against tag “{tag}”', {tag: tagElement})
        : exp.l('Votes for tag “{tag}”', {tag: tagElement})}
      {' '}
      {bracketedText(formatPluralEntityTypeName(entityType))}
    </h2>
  );
};

export default UserTagHeading;
