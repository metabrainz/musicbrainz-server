/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useState} from 'react';

import hydrate from '../../../../utility/hydrate';
import setCookie from '../utility/setCookie';

import FilterForm, {type FilterFormT} from './FilterForm';

type Props = {|
  +ajaxFormUrl: string,
  +initialFilterForm: ?FilterFormT,
|};

const Filter = ({ajaxFormUrl, initialFilterForm}: Props) => {
  const [filterForm, setFilterForm] = useState<?FilterFormT>(
    initialFilterForm,
  );
  const [hidden, setHidden] = useState<boolean>(!initialFilterForm);

  function show() {
    setHidden(false);
    setCookie('filter', '1');
  }

  function hide() {
    setHidden(true);
    setCookie('filter', '');
  }

  function onButtonClick(event) {
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
            src={require('../../../images/icons/filter.png')}
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

export default hydrate<Props>('div.filter', Filter);
