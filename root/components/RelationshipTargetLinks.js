/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import DescriptiveLink from '../static/scripts/common/components/DescriptiveLink';
import bracketed, {bracketedText} from '../static/scripts/common/utility/bracketed';
import formatDatePeriod from '../static/scripts/common/utility/formatDatePeriod';
import {artistCreditsAreEqual} from '../static/scripts/common/immutable-entities';
import * as linkPhrase from '../static/scripts/edit/utility/linkPhrase';

type Props = {
  +forGrouping: boolean,
  +hiddenArtistCredit?: ?ArtistCreditT,
  +relationship: RelationshipT,
};

const RelationshipTargetLinks = ({
  forGrouping,
  hiddenArtistCredit,
  relationship,
}: Props) => {
  const target = relationship.target;
  const targetCredit = relationship.direction === 'backward'
    ? relationship.entity0_credit
    : relationship.entity1_credit;
  let link;
  if (hiddenArtistCredit &&
      target.artistCredit &&
      artistCreditsAreEqual(hiddenArtistCredit, target.artistCredit)) {
    link = <EntityLink content={targetCredit} entity={target} />;
  } else {
    link = <DescriptiveLink content={targetCredit} entity={target} />;
  }
  const extraAttributes = linkPhrase.getExtraAttributes(
    relationship,
    'link_phrase',
    forGrouping,
  );
  const datePeriod = formatDatePeriod(relationship);
  let result = (
    <>
      {link}
      {extraAttributes ? ' ' : null}
      {extraAttributes ? bracketed(extraAttributes) : null}
      {datePeriod ? ' ' + bracketedText(datePeriod) : null}
    </>
  );
  if (relationship.editsPending) {
    result = <span className="mp mp-rel">{result}</span>;
  }
  return result;
};

export default RelationshipTargetLinks;
