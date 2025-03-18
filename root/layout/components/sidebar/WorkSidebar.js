/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LinkSearchableLanguage
  from '../../../components/LinkSearchableLanguage.js';
import {CatalystContext} from '../../../context.mjs';
import manifest from '../../../static/manifest.mjs';
import AttributeList
  from '../../../static/scripts/common/components/AttributeList.js';
import CommonsImage from
  '../../../static/scripts/common/components/CommonsImage.js';
import IswcList from '../../../static/scripts/common/components/IswcList.js';
import commaOnlyList
  from '../../../static/scripts/common/i18n/commaOnlyList.js';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength.js';
import InformationIcon
  from '../../../static/scripts/edit/components/InformationIcon.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';

component WorkSidebar(work: WorkT) {
  const $c = React.useContext(CatalystContext);
  const {attributes, iswcs, languages, length, typeID} = work;
  const showInfo = Boolean(
    length != null ||
    attributes.length ||
    iswcs.length ||
    languages.length ||
    typeID,
  );

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={work}
      />

      {showInfo ? (
        <>
          <h2 className="work-information">
            {l('Work information')}
          </h2>

          <SidebarProperties>
            <SidebarType entity={work} typeType="work_type" />

            {languages.length ? (
              <SidebarProperty
                className="lyrics-language"
                label={addColonText(l('Lyrics languages'))}
              >
                {commaOnlyList(
                  languages.map((wl) => (
                    <LinkSearchableLanguage
                      entityType="work"
                      key={wl.language.id}
                      language={wl.language}
                    />
                  )),
                )}
              </SidebarProperty>
            ) : null}

            {length == null ? null : (
              <SidebarProperty
                className="work-length"
                label={addColonText(l('Median length'))}
              >
                {formatTrackLength(length)}
                {' '}
                <InformationIcon
                  className="align-top"
                  title={l(
                    `Autocalculated from all non-partial, non-medley,
                     non-cover recordings linked only to this work.
                     If the data seems off, it’s likely some
                     recording relationships need to be marked as
                     partial or medley, or that this is a brief work
                     meant to be played one or more times in a row.`,
                  )}
                />
              </SidebarProperty>
            )}

            {iswcs.length ? (
              <>
                <IswcList isSidebar iswcs={iswcs} />
                {manifest('common/components/IswcList', {async: 'async'})}
              </>
            ) : null}
          </SidebarProperties>

          {attributes.length ? (
            <>
              <h2 className="work-attributes">{l('Work attributes')}</h2>
              <AttributeList attributes={attributes} isSidebar />
              {manifest('common/components/AttributeList', {async: 'async'})}
            </>
          ) : null}
        </>
      ) : null}

      <SidebarRating entity={work} />

      <SidebarTags entity={work} />

      <ExternalLinks empty entity={work} />

      <EditLinks entity={work}>
        <AnnotationLinks entity={work} />

        <MergeLink entity={work} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={work} />

      <SidebarLicenses entity={work} />

      <LastUpdated entity={work} />
    </div>
  );
}

export default WorkSidebar;
