/*
 * @flow strict
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import informationIconUrl from '../../../images/icons/information.png';
import Tooltip from '../../edit/components/Tooltip.js';
import isolateText from '../utility/isolateText.js';

import EntityLink, {DeletedLink} from './EntityLink.js';

component _MpIcon(artistCredit: ArtistCreditT) {
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
        'This artist credit has {edit_search|open edits}.',
        {edit_search: editSearch},
      )}
      target={
        <img
          alt={l('This artist credit has open edits.')}
          className="info"
          src={informationIconUrl}
        />
      }
    />
  );
}

export const MpIcon = (hydrate<React.PropsOf<_MpIcon>>(
  'span.ac-mp',
  _MpIcon,
): component(...React.PropsOf<_MpIcon>));

component ArtistCreditLink(
  artistCredit: ArtistCreditT,
  showDeleted: boolean = true,
  showDisambiguation: boolean = false,
  showEditsPending: boolean = true,
  showIcon: boolean = false,
  target?: '_blank',
) {
  const names = artistCredit.names;
  const parts: Array<React.Node> = [];
  for (let i = 0; i < names.length; i++) {
    const credit = names[i];
    const artist = credit.artist;
    if (artist) {
      parts.push(
        <EntityLink
          content={credit.name}
          entity={artist}
          key={`${artist.id}-${i}`}
          shouldIsolate={false}
          showDeleted={showDeleted}
          showDisambiguation={showDisambiguation}
          showEditsPending={showEditsPending && !artistCredit.editsPending}
          showIcon={showIcon}
          target={target}
        />,
      );
    } else {
      parts.push(
        <DeletedLink
          allowNew={false}
          key={`deleted-${i}`}
          name={credit.name}
          shouldIsolate={false}
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
  return isolateText(parts);
}

export default ArtistCreditLink;
