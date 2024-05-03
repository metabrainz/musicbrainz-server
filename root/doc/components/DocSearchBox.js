/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

component DocSearchBox() {
  return (
    <div className="wikidoc-search">
      <form action="/search" method="get">
        <input name="type" type="hidden" value="doc" />
        <input
          name="query"
          placeholder={l('Search the documentation...')}
          type="text"
        />
        {' '}
        <FormSubmit className="inline" label={l('Search')} />
      </form>
    </div>
  );
}

export default DocSearchBox;
