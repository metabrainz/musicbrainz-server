/*
 * @flow strict
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import informationIconUrl from '../../../images/icons/information.png';
import Tooltip from '../../edit/components/Tooltip.js';

import EntityLink, {DeletedLink} from './EntityLink.js';

type Props = {
  +artistCredit: ArtistCreditT,
  +showDeleted?: boolean,
  +showDisambiguation?: boolean,
  +showEditsPending?: boolean,
  +showIcon?: boolean,
  +target?: '_blank',
};

type MpIconProps = {
  +artistCredit: ArtistCreditT,
};

export const MpIcon = (hydrate<MpIconProps>('span.ac-mp', (
  {artistCredit}: MpIconProps,
): React$MixedElement => {
  let editSearch =
    '/search/edits?auto_edit_filter=&order=desc&negation=0' +
    '&combinator=and&conditions.0.field=type&conditions.0.operator=%3D' +
    '&conditions.0.args=9&conditions.1.field=status' +
    '&conditions.1.operator=%3D&conditions.1.args=1';

  let i = 2;
  for (const name of artistCredit.names) {
    editSearch +=
      `&conditions.${i}.field=artist&conditions.${i}.operator=%3D` +
      `&conditions.${i}.name=${encodeURIComponent(name.artist.name)}` +
      `&conditions.${i}.args.0=${name.artist.id}`;
    i++;
  }

  return (
    <Tooltip
      content={exp.l(
        'This artist credit has {edit_search|pending edits}.',
        {edit_search: editSearch},
      )}
      target={
        <img
          alt={l('This artist credit has pending edits.')}
          className="info"
          src={informationIconUrl}
        />
      }
    />
  );
}): React.AbstractComponent<MpIconProps, void>);

const ArtistCreditLink = ({
  artistCredit,
  showDeleted = true,
  showDisambiguation = false,
  showEditsPending = true,
  showIcon = false,
  ...props
}: Props): React$Node => {
  const names = artistCredit.names;
  const parts: Array<React$Node> = [];
  for (let i = 0; i < names.length; i++) {
    const credit = names[i];
    const artist = credit.artist;
    if (artist) {
      parts.push(
        <EntityLink
          content={credit.name}
          entity={artist}
          key={`${artist.id}-${i}`}
          showDeleted={showDeleted}
          showDisambiguation={showDisambiguation}
          showEditsPending={showEditsPending && !artistCredit.editsPending}
          showIcon={showIcon}
          target={props.target}
        />,
      );
    } else {
      parts.push(
        <DeletedLink
          allowNew={false}
          key={`deleted-${i}`}
          name={credit.name}
        />,
      );
    }
    parts.push(credit.joinPhrase);
  }
  if (showEditsPending && artistCredit.editsPending /*:: === true */) {
    return (
      <span className="mp">
        {parts}
        <MpIcon artistCredit={artistCredit} />
      </span>
    );
  }
  return parts;
};

export default ArtistCreditLink;
