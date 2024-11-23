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

import CritiqueBrainzLinks from '../../../components/CritiqueBrainzLinks.js';
import LinkSearchableLanguage
  from '../../../components/LinkSearchableLanguage.js';
import LinkSearchableProperty
  from '../../../components/LinkSearchableProperty.js';
import {QUALITY_UNKNOWN} from '../../../constants.js';
import {CatalystContext} from '../../../context.mjs';
import manifest from '../../../static/manifest.mjs';
import {Artwork} from '../../../static/scripts/common/components/Artwork.js';
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
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import PlayOnListenBrainzButton from './PlayOnListenBrainzButton.js';
import RemoveLink from './RemoveLink.js';
import SidebarDataQuality from './SidebarDataQuality.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';

component ReleaseSidebar(release: ReleaseT) {
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
  const isEmpty = release.has_no_tracks;
  const isPresent = release.cover_art_presence === 'present';
  const isDarkened = release.cover_art_presence === 'darkened';

  return (
    <div id="sidebar">
      <div className={'cover-art' + (isPresent ? ' present' : '')}>
        {isPresent && releaseArtwork ? (
          <Artwork
            artwork={releaseArtwork}
            message={ReactDOMServer.renderToStaticMarkup(exp.l(
              'Image failed to load correctly.' +
              '<br/>{all|View all images}.',
              {all: entityHref(release, 'cover-art')},
            ))}
          />
        ) : isDarkened ? (
          l(`Images for this item have been hidden
             by the Internet Archive because of a takedown request.`)
        ) : (
          <p className="cover-art-note" style={{textAlign: 'left'}}>
            {isPresent ? (
              <>
                {l('No front cover image available.')}
                <br />
                <a href={entityHref(release, 'cover-art')}>
                  {l('View all artwork')}
                </a>
              </>
            ) : l('No images available.')}
          </p>
        )}
      </div>

      {isEmpty ? null : (
        <PlayOnListenBrainzButton
          entityType="release"
          mbids={release.gid}
        />
      )}

      <h2 className="release-information">
        {l('Release information')}
      </h2>

      <SidebarProperties>
        {barcode ? (
          <SidebarProperty
            className="barcode"
            label={addColonText(l('Barcode'))}
          >
            {barcode}
          </SidebarProperty>
        ) : null}

        {nonEmpty(combinedFormatName) ? (
          <SidebarProperty
            className="format"
            label={addColonText(l('Format'))}
          >
            {combinedFormatName}
          </SidebarProperty>
        ) : null}

        {releaseLength == null ? null : (
          <SidebarProperty
            className="length"
            label={addColonText(l('Length'))}
          >
            {formatTrackLength(releaseLength)}
          </SidebarProperty>
        )}
      </SidebarProperties>

      <h2 className="additional-details">
        {l('Additional details')}
      </h2>

      <SidebarProperties>
        {nonEmpty(typeName) ? (
          <SidebarProperty className="type" label={addColonText(l('Type'))}>
            {typeName}
          </SidebarProperty>
        ) : null}

        {packagingId == null ? null : (
          <SidebarProperty
            className="packaging"
            label={addColonText(l('Packaging'))}
          >
            {lp_attributes(
              linkedEntities.release_packaging[packagingId].name,
              'release_packaging',
            )}
          </SidebarProperty>
        )}

        {statusId == null ? null : (
          <SidebarProperty
            className="status"
            label={addColonText(lp('Status', 'release'))}
          >
            {lp_attributes(
              linkedEntities.release_status[statusId].name,
              'release_status',
            )}
          </SidebarProperty>
        )}

        {language ? (
          <SidebarProperty
            className="language"
            label={addColonText(l('Language'))}
          >
            <LinkSearchableLanguage
              entityType="release"
              language={language}
            />
          </SidebarProperty>
        ) : null}

        {script ? (
          <SidebarProperty
            className="script"
            label={addColonText(l('Script'))}
          >
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
                      className="wrap-anywhere"
                      entity={releaseLabel.label}
                      showDisambiguation="hover"
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
          {manifest('common/components/ReleaseEvents', {async: 'async'})}
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
            <CritiqueBrainzLinks entity={releaseGroup} isSidebar />
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
}

export default ReleaseSidebar;
