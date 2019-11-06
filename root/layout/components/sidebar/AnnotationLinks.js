/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import returnUri from '../../../utility/returnUri';

type Props = {
  +$c: CatalystContextT,
  +entity: CoreEntityT,
};

const AnnotationLinks = ({$c, entity}: Props) => (
  <>
    <li>
      <a
        href={returnUri(
          $c,
          entityHref(entity, 'edit_annotation'),
          'returnto',
          $c.req.uri,
        )}
      >
        {entity.latest_annotation && entity.latest_annotation.text
          ? l('Edit annotation')
          : l('Add annotation')}
      </a>
    </li>
    {$c.stash.number_of_revisions ? (
      <li>
        <a href={entityHref(entity, 'annotations')}>
          {l('View annotation history')}
        </a>
      </li>
    ) : null}
  </>
);

export default withCatalystContext(AnnotationLinks);
