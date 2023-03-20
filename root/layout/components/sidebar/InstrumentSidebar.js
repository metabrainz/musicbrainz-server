/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage.js';
import IrombookImage
  from '../../../static/scripts/common/components/IrombookImage.js';
import {isRelationshipEditor}
  from '../../../static/scripts/common/utility/privileges.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import RemoveLink from './RemoveLink.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties} from './SidebarProperties.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';

type Props = {
  +instrument: InstrumentT,
};

const InstrumentSidebar = ({instrument}: Props): React$Element<'div'> => {
  const $c = React.useContext(CatalystContext);

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

      <SidebarTags entity={instrument} />

      <ExternalLinks empty entity={instrument} />

      <EditLinks entity={instrument} requiresPrivileges>
        {isRelationshipEditor($c.user) ? (
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

export default InstrumentSidebar;
