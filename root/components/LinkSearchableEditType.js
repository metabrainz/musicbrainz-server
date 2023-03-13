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

type Props = {
  +editTypeId: string,
  +text: string,
};

const LinkSearchableEditType = ({
  editTypeId,
  text,
}: Props): React$MixedElement => {
  const $c = React.useContext(CatalystContext);
  const url = new URL($c.req.uri);
  url.pathname = 'search/edits';
  url.search =
    '?auto_edit_filter=&order=desc&negation=0&combinator=and' +
    '&conditions.0.field=type&conditions.0.operator=%3D' +
    '&conditions.0.args=' + editTypeId;
  return <a href={url.toString()}>{text}</a>;
};

export default LinkSearchableEditType;
