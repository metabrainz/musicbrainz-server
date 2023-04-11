/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';
import returnUri from '../../../utility/returnUri.js';

type Props = {
  +entity: AnnotatedEntityT,
};

const AnnotationLinks = ({
  entity,
}: Props): React$Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);
  const numberOfRevisions = $c.stash.number_of_revisions ?? 0;

  return (
    <>
      <li>
        <a
          href={returnUri(
            $c,
            entityHref(entity, 'edit_annotation'),
            $c.req.uri,
          )}
        >
          {entity.latest_annotation && nonEmpty(entity.latest_annotation.text)
            ? l('Edit annotation')
            : l('Add annotation')}
        </a>
      </li>
      {numberOfRevisions > 0 ? (
        <li>
          <a href={entityHref(entity, 'annotations')}>
            {l('View annotation history')}
          </a>
        </li>
      ) : null}
    </>
  );
};

export default AnnotationLinks;
