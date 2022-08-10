/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import TracklistAndCredits
  from '../static/scripts/release/components/TracklistAndCredits.js';
import type {CreditsModeT} from '../static/scripts/release/types.js';

import ReleaseLayout from './ReleaseLayout.js';

type PropsT = {
  +creditsMode: CreditsModeT,
  +noScript: boolean,
  +numberOfRevisions: number,
  +release: ReleaseWithMediumsT,
};

const ReleaseIndex = ({
  creditsMode,
  noScript,
  numberOfRevisions,
  release,
}: PropsT): React.Element<typeof ReleaseLayout> => {
  const {
    link_attribute_type: linkAttributeTypes,
    link_type: linkTypes,
  } = linkedEntities;

  return (
    <ReleaseLayout entity={release} page="index">
      <Annotation
        annotation={release.latest_annotation}
        collapse
        entity={release}
        numberOfRevisions={numberOfRevisions}
      />
      <TracklistAndCredits
        initialCreditsMode={creditsMode}
        initialLinkedEntities={{
          link_attribute_type: linkAttributeTypes,
          link_type: linkTypes,
        }}
        noScript={noScript}
        release={release}
      />
      {manifest.js('release/index', {async: 'async'})}
    </ReleaseLayout>
  );
};

export default ReleaseIndex;
