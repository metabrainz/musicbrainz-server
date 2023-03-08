/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {CatalystContext} from '../context.mjs';
import escapeLuceneValue
  from '../static/scripts/common/utility/escapeLuceneValue.js';

type Props = {
  +entityType: string,
  +searchField: string,
  +searchValue: string,
  +text?: string,
};

const LinkSearchableProperty = ({
  entityType,
  searchField,
  searchValue,
  text = searchValue,
}: Props): React$MixedElement => (
  <CatalystContext.Consumer>
    {$c => {
      const url = new URL($c.req.uri);
      url.pathname = '/search';
      url.search =
        'query=' +
        encodeURIComponent(
          (searchValue === '*' ? '-' + searchField : searchField) + ':"' +
          escapeLuceneValue(searchValue) + '"',
        ) +
        '&type=' + encodeURIComponent(entityType) +
        '&limit=25&method=advanced';
      return <a href={url.toString()}>{text}</a>;
    }}
  </CatalystContext.Consumer>
);

export default LinkSearchableProperty;
