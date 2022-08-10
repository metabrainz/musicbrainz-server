/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as ReactDOMServer from 'react-dom/server';

import {QUALITY_UNKNOWN} from '../../../constants.js';
import {CatalystContext} from '../../../context.mjs';
import * as manifest from '../../../static/manifest.mjs';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';
import ReleaseEvents
  from '../../../static/scripts/common/components/ReleaseEvents.js';
import linkedEntities
  from '../../../static/scripts/common/linkedEntities.mjs';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';
import formatBarcode
  from '../../../static/scripts/common/utility/formatBarcode.js';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength.js';
import releaseLabelKey
  from '../../../static/scripts/common/utility/releaseLabelKey.js';
import {Artwork} from '../../../components/Artwork.js';
import CritiqueBrainzLinks from '../../../components/CritiqueBrainzLinks.js';
import LinkSearchableLanguage
  from '../../../components/LinkSearchableLanguage.js';
import LinkSearchableProperty
  from '../../../components/LinkSearchableProperty.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import RemoveLink from './RemoveLink.js';
import SidebarDataQuality from './SidebarDataQuality.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperty, SidebarProperties} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';

type Props = {
  +release: ReleaseT,
};

const ReleaseSidebar = ({release}: Props): React.Element<'div'> | null => {
  const $c = React.useContext(CatalystContext);

  const releaseGroup = release.releaseGroup;
  if (!releaseGroup) {
    return null;
  }

  const {
    combined_format_name: combinedFormatName,
    events: releaseEvents,
    labels: releaseLabels,
    packagingID: packagingId,
    scriptID: scriptId,
    statusID: statusId,
  } = release;

  const releaseArtwork = $c.stash.release_artwork;
  const releaseLength = release.length;
  const barcode = formatBarcode(release.barcode);
  const typeName = releaseGroup.l_type_name;
  const language = release.languageID == null
    ? null
    : linkedEntities.language[release.languageID];
  const script = scriptId == null
    ? null
    : linkedEntities.script[scriptId];

  return (
    <div id="sidebar">
      <div className="cover-art">
        {release.cover_art_presence === 'present' && releaseArtwork ? (
          <Artwork
            artwork={releaseArtwork}
            message={ReactDOMServer.renderToStaticMarkup(exp.l(
              'Front cover image failed to load correctly.' +
              '<br/>{all|View all artwork}.',
              {all: entityHref(release, 'cover-art')},
            ))}
          />
        ) : release.cover_art_presence === 'darkened' ? (
          l(`Cover art for this release has been hidden
             by the Internet Archive because of a takedown request.`)
        ) : (
          <p className="cover-art-note" style={{textAlign: 'left'}}>
            {release.cover_art_presence === 'present' ? (
              <>
                {l('No front cover image available.')}
                <br />
                <a href={entityHref(release, 'cover-art')}>
                  {l('View all artwork')}
                </a>
              </>
            ) : l('No cover art available.')}
          </p>
        )}
      </div>

      <h2 className="release-information">
        {l('Release information')}
      </h2>

      <SidebarProperties>
        {barcode ? (
          <SidebarProperty className="barcode" label={l('Barcode:')}>
            {barcode}
          </SidebarProperty>
        ) : null}

        {nonEmpty(combinedFormatName) ? (
          <SidebarProperty className="format" label={l('Format:')}>
            {combinedFormatName}
          </SidebarProperty>
        ) : null}

        {releaseLength == null ? null : (
          <SidebarProperty className="length" label={l('Length:')}>
            {formatTrackLength(releaseLength)}
          </SidebarProperty>
        )}
      </SidebarProperties>

      <h2 className="additional-details">
        {l('Additional details')}
      </h2>

      <SidebarProperties>
        {nonEmpty(typeName) ? (
          <SidebarProperty className="type" label={l('Type:')}>
            {typeName}
          </SidebarProperty>
        ) : null}

        {packagingId == null ? null : (
          <SidebarProperty className="packaging" label={l('Packaging:')}>
            {lp_attributes(
              linkedEntities.release_packaging[packagingId].name,
              'release_packaging',
            )}
          </SidebarProperty>
        )}

        {statusId == null ? null : (
          <SidebarProperty
            className="status"
            label={lp('Status:', 'release status')}
          >
            {lp_attributes(
              linkedEntities.release_status[statusId].name,
              'release_status',
            )}
          </SidebarProperty>
        )}

        {language ? (
          <SidebarProperty className="language" label={l('Language:')}>
            <LinkSearchableLanguage
              entityType="release"
              language={language}
            />
          </SidebarProperty>
        ) : null}

        {script ? (
          <SidebarProperty className="script" label={l('Script:')}>
            <LinkSearchableProperty
              entityType="release"
              searchField="script"
              searchValue={script.iso_code || ''}
              text={l_scripts(script.name)}
            />
          </SidebarProperty>
        ) : null}

        {release.quality === QUALITY_UNKNOWN ? null : (
          <SidebarDataQuality quality={release.quality} />
        )}
      </SidebarProperties>

      {releaseLabels?.length ? (
        <>
          <h2 className="labels">{l('Labels')}</h2>
          <ul className="links">
            {releaseLabels.map(releaseLabel => (
              <li key={releaseLabelKey(releaseLabel)}>
                {releaseLabel.label ? (
                  <>
                    <EntityLink
                      entity={releaseLabel.label}
                      showDisambiguation={false}
                    />
                    <br />
                  </>
                ) : null}
                {nonEmpty(releaseLabel.catalogNumber) ? (
                  <span className="catalog-number">
                    {releaseLabel.catalogNumber}
                  </span>
                ) : null}
              </li>
            ))}
          </ul>
        </>
      ) : null}

      {releaseEvents?.length ? (
        <>
          <h2 className="release-events">{l('Release events')}</h2>
          <ReleaseEvents abbreviated={false} events={releaseEvents} />
          {manifest.js(
            'common/components/ReleaseEvents',
            {async: 'async'},
          )}
        </>
      ) : null}

      <SidebarRating
        entity={releaseGroup}
        heading={l('Release group rating')}
      />

      {releaseGroup.review_count == null ? null : (
        <>
          <h2 className="reviews">
            {l('Release group reviews')}
          </h2>
          <p>
            <CritiqueBrainzLinks entity={releaseGroup} />
          </p>
        </>
      )}

      <SidebarTags entity={release} />

      <ExternalLinks empty entity={release} />

      <ExternalLinks
        empty={false}
        entity={releaseGroup}
        heading={l('Release group external links')}
      />

      <EditLinks entity={release}>
        <li>
          <a href={entityHref(release, 'edit-relationships')}>
            {l('Edit relationships')}
          </a>
        </li>

        <li>
          <a href={entityHref(release, 'change-quality')}>
            {l('Change data quality')}
          </a>
        </li>

        <AnnotationLinks entity={release} />

        <MergeLink entity={release} />

        <RemoveLink entity={release} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={release} />

      <SidebarLicenses entity={release} />

      <LastUpdated entity={release} />
    </div>
  );
};

export default ReleaseSidebar;
