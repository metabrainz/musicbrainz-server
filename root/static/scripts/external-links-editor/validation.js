/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import * as tree from 'weight-balanced-tree';

import areDatesEqual from '../common/utility/areDatesEqual.js';
import isObjectEmpty from '../common/utility/isObjectEmpty.js';
import memoize from '../common/utility/memoize.js';
import * as URLCleanup from '../edit/URLCleanup.js';
import isShortenedUrl from '../edit/utility/isShortenedUrl.js';
import getRelationshipLinkType
  from '../relationship-editor/utility/getRelationshipLinkType.js';
import {isMalware} from '../url/utility/isGreyedOut.js';

import getLinkChecker from './utility/getLinkChecker.js';
import isLinkStateEmpty from './utility/isLinkStateEmpty.js';
import isValidURL from './utility/isValidURL.js';
import type {
  ErrorT,
  LinkRelationshipStateT,
  LinksEditorStateT,
  LinkStateT,
} from './types.js';

type LinkRelationshipStatusT = {
  +changes: {
    +beginDate?: CompT<PartialDateT | null>,
    +endDate?: CompT<PartialDateT | null>,
    +ended?: CompT<boolean>,
    +entityCredit?: CompT<string>,
    +linkTypeID?: CompT<number | null>,
    +url?: CompT<string>,
    +video?: CompT<boolean>,
  },
  +isNew: boolean,
  +linkType: LinkTypeT | null,
  +removed: boolean,
};

export const getLinkRelationshipStatus: (
  relationship: LinkRelationshipStateT,
) => LinkRelationshipStatusT = memoize((
  relationship: LinkRelationshipStateT,
): LinkRelationshipStatusT => {
  const originalState = relationship.originalState;
  const removed = relationship.removed;
  const isNew = originalState === null;
  const changes: {...LinkRelationshipStatusT['changes']} = {};
  if (!isNew) {
    /*:: invariant(originalState !== null); */
    if (!areDatesEqual(relationship.beginDate, originalState.beginDate)) {
      changes.beginDate = {
        new: relationship.beginDate,
        old: originalState.beginDate,
      };
    }
    if (!areDatesEqual(relationship.endDate, originalState.endDate)) {
      changes.endDate = {
        new: relationship.endDate,
        old: originalState.endDate,
      };
    }
    if (relationship.ended !== originalState.ended) {
      changes.ended = {new: relationship.ended, old: originalState.ended};
    }
    if (relationship.entityCredit !== originalState.entityCredit) {
      changes.entityCredit = {
        new: relationship.entityCredit,
        old: originalState.entityCredit,
      };
    }
    if (relationship.linkTypeID !== originalState.linkTypeID) {
      changes.linkTypeID = {
        new: relationship.linkTypeID,
        old: originalState.linkTypeID,
      };
    }
    if (relationship.url !== originalState.url) {
      changes.url = {new: relationship.url, old: originalState.url};
    }
    if (relationship.video !== originalState.video) {
      changes.video = {new: relationship.video, old: originalState.video};
    }
  }
  return {
    changes,
    isNew,
    linkType: getRelationshipLinkType(relationship),
    removed,
  };
});

function isNewOrChangedLink(link: LinkStateT): boolean {
  return link.isNew ||
    link.relationships.some(isNewOrChangedLinkRelationship);
}

function isNewOrChangedLinkRelationship(
  relationship: LinkRelationshipStateT,
): boolean {
  return relationship.originalState == null ||
    !isObjectEmpty(getLinkRelationshipStatus(relationship).changes);
}

export function hasErrorsOnNewOrChangedLink(link: LinkStateT): boolean {
  return isNewOrChangedLink(link) && linkContainsErrors(link);
}

export function hasErrorsOnNewOrChangedLinks(
  links: tree.ImmutableTree<LinkStateT>,
): boolean {
  let hasErrors = false;
  for (const link of tree.iterate(links)) {
    hasErrors ||= hasErrorsOnNewOrChangedLink(link);
  }
  return hasErrors;
}

function isGoogleAmp(url: string) {
  return /^https?:\/\/([^/]+\.)?google\.[^/]+\/amp/.test(url);
}

function isGoogleSearch(url: string) {
  return /^https?:\/\/(?:[^/?#]+\.)?google\.[^/?#]+\/search/.test(url);
}

function isExample(url: string) {
  return /^https?:\/\/(?:[^/]+\.)?example\.(?:com|org|net)(?:\/.*)?$/.test(url);
}

function isMusicBrainz(url: string) {
  return /^https?:\/\/([^/]+\.)?musicbrainz\.org/.test(url);
}

function isCritiqueBrainz(url: string) {
  return /^https?:\/\/([^/]+\.)?critiquebrainz\.org/.test(url);
}

function linkContainsErrors(link: LinkStateT): boolean {
  return link.error !== null ||
    link.relationships.some(linkRelationshipHasError);
}

function linkRelationshipHasError(
  relationship: LinkRelationshipStateT,
): boolean {
  return relationship.error !== null;
}

const httpsRegExp = /^https:/;

export function normalizeUrl(url: string): string {
  return url.replace(httpsRegExp, 'http:');
}

export function validateLink(
  state: LinksEditorStateT,
  linkCtx: CowContext<LinkStateT>,
): void {
  const {
    key: linkKey,
    url,
    isSubmitted,
  } = linkCtx.read();

  const relationshipsCtx = linkCtx.get('relationships');
  const relationshipCount = relationshipsCtx.read().length;
  for (let i = 0; i < relationshipCount; i++) {
    const relationshipCtx = relationshipsCtx.get(i);
    relationshipCtx.set('error', null);
    relationshipCtx.set('url', url);
  }

  linkCtx.set('error', null);

  if (empty(url)) {
    linkCtx.set('isSubmitted', false);
    if (!isLinkStateEmpty(linkCtx.read())) {
      // The link's URL is empty, but it has relationships.
      linkCtx.set('error', {
        message: l('Required field.'),
        target: URLCleanup.ERROR_TARGETS.URL,
      });
    }
    return;
  }

  let error: ErrorT | null = null;
  if (!isValidURL(url)) {
    error = {
      message: exp.l('Please enter a valid URL, such as “{example_url}”.',
                     {example_url: <span className="url-quote">{'http://example.com/'}</span>}),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isExample(url)) {
    error = {
      message: exp.l(
        `“{example_url}” is just an example.
         Please enter the actual link you want to add.`,
        {example_url: <span className="url-quote">{url}</span>},
      ),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isMusicBrainz(url)) {
    error = {
      message: l(`Links to MusicBrainz URLs are not allowed.
                  Did you mean to paste something else?`),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isCritiqueBrainz(url)) {
    error = {
      message: texp.l(
        `Please don’t enter CritiqueBrainz links — reviews
         are automatically linked from the “{reviews_tab_name}” tab.`,
        {reviews_tab_name: l('Reviews')},
      ),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isMalware(url)) {
    error = {
      message: l(`Links to this website are not allowed
                  because it is known to host malware.`),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isShortenedUrl(url)) {
    error = {
      message: l(`Please don’t enter bundled/shortened URLs,
                  enter the destination URL(s) instead.`),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isGoogleAmp(url)) {
    error = {
      message: l(`Please don’t enter Google AMP links,
                  since they are effectively an extra redirect.
                  Enter the destination URL instead.`),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  } else if (isGoogleSearch(url)) {
    error = {
      message: l(`Please don’t enter links to search results.
                  If you’ve found any links through your search
                  that seem useful, do enter those instead.`),
      target: URLCleanup.ERROR_TARGETS.URL,
    };
  }

  let duplicateOf = null;
  if (isNewOrChangedLink(linkCtx.read())) {
    let duplicateIndex = 0;
    for (const otherLink of tree.iterate(state.links)) {
      if (
        otherLink.key !== linkKey &&
        /*
         * There's no reason why we should allow adding the same relationship
         * twice when the only difference is http vs https, so normalize this
         * for the check.
         */
        normalizeUrl(otherLink.url) === normalizeUrl(url)
      ) {
        duplicateOf = {
          index: duplicateIndex,
          link: otherLink,
        };
        /*
         * If a link was previously submitted, and became a duplicate after
         * editing via `URLInputPopover`, unmark it as submitted. This makes
         * it easier to edit, and ensures the "To merge, press enter ..."
         * message isn't wrong/confusing.
         */
        if (linkCtx.read().isNew) {
          linkCtx.set('isSubmitted', false);
        }
        break;
      }
      duplicateIndex++;
    }
  }
  linkCtx.set('duplicateOf', duplicateOf);

  const checker = getLinkChecker(state.source.entityType, linkCtx.read());
  const selectedTypes: Array<string> = [];
  let relationshipsWithErrors = 0;

  for (let i = 0; i < relationshipCount; i++) {
    const relationshipCtx = relationshipsCtx.get(i);
    const status = getLinkRelationshipStatus(relationshipCtx.read());
    if (status.removed) {
      continue;
    }
    if (status.linkType) {
      selectedTypes.push(status.linkType.gid);
    }
    const relError = getRelationshipError(
      linkCtx.read(),
      relationshipCtx.read(),
      status,
      checker,
    );
    if (relError) {
      if (relError.target === URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
        relationshipCtx.set('error', relError);
      } else {
        error ??= relError;
      }
      relationshipsWithErrors++;
    }
  }

  if (
    error === null &&
    relationshipsWithErrors === 0 &&
    isSubmitted &&
    selectedTypes.length
  ) {
    /*
     * Only validate type combination when every single type has passed
     * validation.
     */
    const check =
      checker.checkRelationships(selectedTypes, checker.possibleTypes);
    if (!check.result) {
      error = {
        message: check.error ??
          l('This relationship type combination is invalid.'),
        target: check.target ?? URLCleanup.ERROR_TARGETS.URL,
      };
    }
  }

  linkCtx.set('error', error);
}

function getRelationshipError(
  link: LinkStateT,
  relationship: LinkRelationshipStateT,
  status: LinkRelationshipStatusT,
  checker: URLCleanup.Checker,
): ErrorT | null {
  const linkType = status.linkType;

  if (linkType == null) {
    return {
      message: l(`Please select a link type for the URL
                  you’ve entered.`),
      target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
    };
  }

  if (
    linkType.deprecated &&
    (status.isNew || status.changes.linkTypeID != null)
  ) {
    return {
      message: l(`This relationship type is deprecated
                  and should not be used.`),
      target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
    };
  }

  const isDuplicate = (other: LinkRelationshipStateT): boolean => {
    if (
      other.originalState != null &&
      other !== other.originalState &&
      isDuplicate(other.originalState)
    ) {
      return true;
    }
    return (
      relationship.id !== other.id &&
      relationship.linkTypeID === other.linkTypeID
    );
  };

  const duplicateOf = link.duplicateOf;
  if (
    (
      duplicateOf != null &&
      duplicateOf.link.relationships.some(isDuplicate)
    ) ||
    link.relationships.some(isDuplicate)
  ) {
    return {
      blockMerge: true,
      message: l('This relationship already exists.'),
      target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
    };
  }

  if (!(status.isNew || status.changes.url != null)) {
    return null;
  }

  const check = checker.checkRelationship(linkType.gid);
  if (!check.result) {
    const error: {...ErrorT} = {
      message: check.error ?? '',
      target: check.target ?? URLCleanup.ERROR_TARGETS.NONE,
    };
    if (error.target === URLCleanup.ERROR_TARGETS.URL) {
      error.message = l(
        `This URL is not allowed for the selected link type,
         or is incorrectly formatted.`,
      );
    } else if (error.target === URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
      error.message =
        l(`This URL is not allowed for the selected link type.`);
    } else if (error.target === URLCleanup.ERROR_TARGETS.ENTITY) {
      switch (checker.entityType) {
        case 'area':
          error.message = l(`This URL is not allowed for areas.`);
          break;
        case 'artist':
          error.message = l(`This URL is not allowed for artists.`);
          break;
        case 'event':
          error.message = l(`This URL is not allowed for events.`);
          break;
        case 'instrument':
          error.message = l(`This URL is not allowed for instruments.`);
          break;
        case 'label':
          error.message = l(`This URL is not allowed for labels.`);
          break;
        case 'place':
          error.message = l(`This URL is not allowed for places.`);
          break;
        case 'recording':
          error.message = l(`This URL is not allowed for recordings.`);
          break;
        case 'release':
          error.message = l(`This URL is not allowed for releases.`);
          break;
        case 'release_group':
          error.message = l(`This URL is not allowed for release
                             groups.`);
          break;
        case 'series':
          error.message = l(`This URL is not allowed for series.`);
          break;
        case 'work':
          error.message = l(`This URL is not allowed for works.`);
          break;
      }
    }
    return error;
  }

  return null;
}
