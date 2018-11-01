/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {URL} from 'url';

import React from 'react';

import {withCatalystContext} from '../context';

type Props = {|
  +$c: CatalystContextT,
  +entityType: string,
  +searchField: string,
  +searchValue: string,
  +text?: string,
|};

const LinkSearchableProperty = ({
  $c,
  entityType,
  searchField,
  searchValue,
  text = searchValue,
}: Props) => {
  searchField = searchValue === '*' ? '-' + searchField : searchField;
  const url = new URL($c.req.uri);
  url.pathname = '/search';
  url.search =
    'query=' + encodeURIComponent(searchField + ':' + searchValue) +
    '&type=' + encodeURIComponent(entityType) +
    '&limit=25&method=advanced';
  return <a href={url.toString()}>{text}</a>;
};

export default withCatalystContext(LinkSearchableProperty);
