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
  from '../../../components/LinkSearchableLanguage';
import CodeLink from '../../../static/scripts/common/components/CodeLink';
import commaOnlyList from '../../../static/scripts/common/i18n/commaOnlyList';
import CommonsImage from
  '../../../static/scripts/common/components/CommonsImage';
import linkedEntities from '../../../static/scripts/common/linkedEntities';
import {kebabCase} from '../../../static/scripts/common/utility/strings';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {
  +$c: CatalystContextT,
  +work: WorkT,
};

const WorkSidebar = ({$c, work}: Props): React.Element<'div'> => {
  const {attributes, iswcs, languages, typeID} = work;
  const showInfo = Boolean(
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
                label={addColonText(l('Lyrics Languages'))}
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

            {iswcs.length ? (
              iswcs.map((iswc) => (
                <SidebarProperty
                  className="iswc"
                  key={iswc.iswc}
                  label={l('ISWC:')}
                >
                  <CodeLink code={iswc} />
                </SidebarProperty>
              ))
            ) : null}

            {attributes.length ? (
              attributes.map((attr) => {
                const type = linkedEntities.work_attribute_type[attr.typeID];
                return (
                  <SidebarProperty
                    className={'work-attribute work-attribute-' +
                      kebabCase(type.name)}
                    key={attr.id}
                    label={addColonText(
                      lp_attributes(type.name, 'work_attribute_type'),
                    )}
                  >
                    {attr.value_id == null
                      ? attr.value
                      : lp_attributes(
                        attr.value, 'work_attribute_type_allowed_value',
                      )}
                  </SidebarProperty>
                );
              })
            ) : null}
          </SidebarProperties>
        </>
      ) : null}

      <SidebarRating entity={work} />

      <SidebarTags
        $c={$c}
        aggregatedTags={$c.stash.top_tags}
        entity={work}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

      <ExternalLinks empty entity={work} />

      <EditLinks entity={work}>
        <AnnotationLinks entity={work} />

        <MergeLink entity={work} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks $c={$c} entity={work} />

      <SidebarLicenses entity={work} />

      <LastUpdated entity={work} />
    </div>
  );
};

export default WorkSidebar;
