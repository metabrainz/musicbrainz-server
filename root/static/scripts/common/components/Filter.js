/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import filterIconUrl from '../../../images/icons/filter.png';
import setCookie from '../utility/setCookie.js';

import FilterForm, {type FilterFormT} from './FilterForm.js';

type Props = {
  +ajaxFormUrl: string,
  +initialFilterForm: ?FilterFormT,
};

const Filter = ({ajaxFormUrl, initialFilterForm}: Props) => {
  const [filterForm, setFilterForm] = React.useState<?FilterFormT>(
    initialFilterForm,
  );
  const [hidden, setHidden] = React.useState<boolean>(!initialFilterForm);

  function show() {
    setHidden(false);
    setCookie('filter', '1');
  }

  function hide() {
    setHidden(true);
    setCookie('filter', '');
  }

  function onButtonClick(event: SyntheticMouseEvent<HTMLAnchorElement>) {
    event.preventDefault();

    if (filterForm) {
      hidden ? show() : hide();
    } else {
      const $ = require('jquery');

      $.getJSON(ajaxFormUrl, function (data) {
        setFilterForm(data);
        setHidden(false);
      });
    }
  }

  return (
    <>
      <div style={{float: 'right', marginTop: '-1.5em'}}>
        <a className="filter-button">
          <img
            alt=""
            src={filterIconUrl}
          />
        </a>
        {' '}
        <a className="filter-button" href="#" onClick={onButtonClick}>
          {l('Filter')}
        </a>
      </div>

      {(filterForm && !hidden) ? (
        <FilterForm form={filterForm} />
      ) : null}
    </>
  );
};

export default (
  hydrate<Props>('div.filter', Filter):
  React$AbstractComponent<Props, void>
);
