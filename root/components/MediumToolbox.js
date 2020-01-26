/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const MediumToolbox = ({
  hasMultipleMedia,
}: {hasMultipleMedia: boolean}): React.Element<'span'> => (
  <span id="medium-toolbox">
    {hasMultipleMedia ? (
      <>
        <button
          className="btn-link"
          id="expand-all-mediums"
          type="button"
        >
          {l('Expand all mediums')}
        </button>
        {' | '}
        <button
          className="btn-link"
          id="collapse-all-mediums"
          type="button"
        >
          {l('Collapse all mediums')}
        </button>
        {' | '}
      </>
    ) : null}
    <button className="btn-link" id="toggle-credits" type="button" />
  </span>
);

export default MediumToolbox;
