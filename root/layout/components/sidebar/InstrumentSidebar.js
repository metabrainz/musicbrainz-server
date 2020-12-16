/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage';
import IrombookImage
  from '../../../static/scripts/common/components/IrombookImage';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperties} from './SidebarProperties';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {
  +$c: CatalystContextT,
  +instrument: InstrumentT,
};

const InstrumentSidebar = ({$c, instrument}: Props): React.Element<'div'> => {
  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={instrument}
      />

      <IrombookImage entity={instrument} />

      {instrument.typeID == null ? null : (
        <>
          <h2 className="instrument-information">
            {l('Instrument information')}
          </h2>

          <SidebarProperties>
            <SidebarType entity={instrument} typeType="instrument_type" />
          </SidebarProperties>
        </>
      )}

      <SidebarTags
        $c={$c}
        aggregatedTags={$c.stash.top_tags}
        entity={instrument}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

      <ExternalLinks empty entity={instrument} />

      <EditLinks $c={$c} entity={instrument}>
        {$c.user?.is_relationship_editor ? (
          <>
            <AnnotationLinks $c={$c} entity={instrument} />

            <MergeLink entity={instrument} />

            <RemoveLink entity={instrument} />

            <li className="separator" role="separator" />
          </>
        ) : null}
      </EditLinks>

      <CollectionLinks $c={$c} entity={instrument} />

      <SidebarLicenses entity={instrument} />

      <LastUpdated entity={instrument} />
    </div>
  );
};

export default InstrumentSidebar;
