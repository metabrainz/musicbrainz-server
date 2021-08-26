/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import commaOnlyList, {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList';
import bracketed from '../static/scripts/common/utility/bracketed';
import displayLinkAttribute
  from '../static/scripts/common/utility/displayLinkAttribute';
import {artistCreditsAreEqual}
  from '../static/scripts/common/immutable-entities';
import semicolonOnlyList
  from '../static/scripts/common/i18n/semicolonOnlyList';
import type {
  DatedExtraAttributes,
  RelationshipTargetGroupT,
} from '../utility/groupRelationships';
import isDisabledLink from '../utility/isDisabledLink';
import relationshipDateText from '../utility/relationshipDateText';

export function displayDatedExtraAttributes(
  pair: DatedExtraAttributes,
): React.MixedElement | string {
  const renderedDatePeriods = commaOnlyListText(
    pair.datePeriods.map(datePeriod => (
      relationshipDateText(datePeriod, false /* bracketEnded */)
    )),
  );
  const renderedExtraAttributes = commaOnlyList(
    pair.attributes.map(displayLinkAttribute),
  );
  if (renderedDatePeriods) {
    if (renderedExtraAttributes) {
      return (
        <>
          {addColon(renderedDatePeriods)}
          {' '}
          {renderedExtraAttributes}
        </>
      );
    }
    return renderedDatePeriods;
  }
  return renderedExtraAttributes;
}

type Props = {
  +hiddenArtistCredit?: ?ArtistCreditT,
  +relationship: RelationshipTargetGroupT,
};

const RelationshipTargetLinks = ({
  hiddenArtistCredit,
  relationship,
}: Props): React.MixedElement => {
  const target = relationship.target;
  const targetCredit = relationship.targetCredit;
  const disableLink = isDisabledLink(relationship.earliestDatePeriod, target);
  let link;
  if (hiddenArtistCredit &&
      target.artistCredit &&
      artistCreditsAreEqual(hiddenArtistCredit, target.artistCredit)) {
    link = <EntityLink content={targetCredit} entity={target} showIcon />;
  } else {
    link = (
      <DescriptiveLink
        content={targetCredit}
        disableLink={disableLink}
        entity={target}
        showIcon
      />
    );
  }
  const datesAndAttributes = semicolonOnlyList(
    relationship.datedExtraAttributesList.map(displayDatedExtraAttributes),
  );
  let result = (
    <>
      {link}
      {datesAndAttributes ? (
        <>
          {' '}
          {bracketed(datesAndAttributes)}
        </>
      ) : null}
    </>
  );
  if (relationship.editsPending) {
    result = <span className="mp mp-rel">{result}</span>;
  }
  return result;
};

export default RelationshipTargetLinks;
