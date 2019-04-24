/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React, {useState} from 'react';

import hydrate from '../../../../utility/hydrate';
import Tooltip from '../../edit/components/Tooltip';

import EntityLink, {DeletedLink} from './EntityLink';

type Props = {
  +artistCredit: ArtistCreditT,
  +plain?: boolean,
  +showDeleted?: boolean,
  +target?: '_blank',
};

type MpIconProps = {|
  +artistCredit: ArtistCreditT,
|};

const MpIcon = hydrate<MpIconProps>('span.ac-mp', ({artistCredit}: MpIconProps) => {
  const [hover, setHover] = useState(false);

  let editSearch =
    '/search/edits?auto_edit_filter=&order=desc&negation=0' +
    '&combinator=and&conditions.0.field=type&conditions.0.operator=%3D' +
    '&conditions.0.args=9&conditions.1.field=status' +
    '&conditions.1.operator=%3D&conditions.1.args=1';

  let i = 2;
  for (let name of artistCredit.names) {
    editSearch +=
      `&conditions.${i}.field=artist&conditions.${i}.operator=%3D` +
      `&conditions.${i}.name=${encodeURIComponent(name.artist.name)}` +
      `&conditions.${i}.args.0=${name.artist.id}`;
    i++;
  }

  return (
    <>
      <img
        alt={l('This artist credit has pending edits.')}
        className="info"
        onMouseEnter={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
        src={require('../../../images/icons/information.png')}
      />
      {hover ? (
        <Tooltip
          content={exp.l(
            'This artist credit has {edit_search|pending edits}.',
            {edit_search: editSearch},
          )}
          hoverCallback={setHover}
        />
      ) : null}
    </>
  );
});

const ArtistCreditLink = ({
  artistCredit,
  showDeleted = true,
  ...props
}: Props) => {
  const names = artistCredit.names;
  const parts = [];
  for (let i = 0; i < names.length; i++) {
    const credit = names[i];
    if (props.plain) {
      parts.push(credit.name);
    } else {
      const artist = credit.artist;
      if (artist) {
        parts.push(
          <EntityLink
            content={credit.name}
            entity={artist}
            key={`${artist.id}-${i}`}
            showDeleted={showDeleted}
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
    }
    parts.push(credit.joinPhrase);
  }
  if (artistCredit.editsPending) {
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
