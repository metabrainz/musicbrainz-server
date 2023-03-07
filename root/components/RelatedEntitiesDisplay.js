/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Props = {
  +children: React$Node,
  +title: string,
};

const RelatedEntitiesDisplay = (
  {children, title}: Props,
): React$Element<'p'> => (
  <p>
    <strong>{addColonText(title)}</strong>
    {' '}
    {children}
  </p>
);

export default RelatedEntitiesDisplay;
