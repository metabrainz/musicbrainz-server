/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import CommonsImage from '../../../static/scripts/common/components/CommonsImage';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {
  +$c: CatalystContextT,
  +instrument: InstrumentT,
};

const InstrumentSidebar = ({$c, instrument}: Props) => {
  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={instrument}
      />

      {instrument.typeID ? (
        <>
          <h2 className="instrument-information">
            {l('Instrument information')}
          </h2>

          <SidebarProperties>
            <SidebarType entity={instrument} typeType="instrument_type" />
          </SidebarProperties>
        </>
      ) : null}

      <SidebarTags
        aggregatedTags={$c.stash.top_tags}
        entity={instrument}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

      <ExternalLinks empty entity={instrument} />

      <EditLinks entity={instrument}>
        {$c.user && $c.user.is_relationship_editor ? (
          <>
            <AnnotationLinks entity={instrument} />

            <MergeLink entity={instrument} />

            <RemoveLink entity={instrument} />

            <li className="separator" role="separator" />
          </>
        ) : null}
      </EditLinks>

      <CollectionLinks entity={instrument} />

      <SidebarLicenses entity={instrument} />

      <LastUpdated entity={instrument} />
    </div>
  );
};

export default withCatalystContext(InstrumentSidebar);
