/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import WarningIcon from '../../common/components/WarningIcon.js';

/*
 * Rendered hidden next to an artist's or label's area field. The area
 * control (MB/Control/Area.js) shows it while the selected area is smaller
 * than a country.
 */
component SmallAreaWarning(entityType: 'artist' | 'label') {
  return (
    <div className="small-area-warning warning" style={{display: 'none'}}>
      <WarningIcon />
      <p>
        <strong>{l('Did you know:')}</strong>
        {' '}
        {entityType === 'artist' ? (
          exp.l(
            `The artist area should almost always be set to the country
             that they are most commonly associated with, not smaller areas
             like cities or towns, unless they are very strongly associated
             with a smaller area: for instance, the Berliner Philharmoniker
             is an exception and has the area Berlin.
             {doc|Click here to read the guidelines.}`,
            {doc: {href: '/doc/Style/Artist#Main_area', target: '_blank'}},
          )
        ) : (
          exp.l(
            `The label area field describes in which country a label was
             created, not smaller areas like cities or towns.
             {doc|Click here to read the documentation.}`,
            {doc: {href: '/doc/Label/Country', target: '_blank'}},
          )
        )}
      </p>
    </div>
  );
}

export default SmallAreaWarning;
