/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import deepFreeze from 'deep-freeze-strict';
import mutate, {
  type CowContext,
} from 'mutate-cow';
import * as tree from 'weight-balanced-tree';
import {
  type RemoveValue,
  onNotFoundDoNothing,
  REMOVE_VALUE,
} from 'weight-balanced-tree/update';

import {expect} from '../../../utility/invariant.js';
import {VIDEO_ATTRIBUTE_GID} from '../common/constants.js';
import {compare} from '../common/i18n.js';
import linkedEntities from '../common/linkedEntities.mjs';
import {
  getSourceEntityData,
} from '../common/utility/catalyst.js';
import {compareStrings} from '../common/utility/compare.mjs';
import isDatabaseRowId from '../common/utility/isDatabaseRowId.js';
import {
  advanceUniqueId,
  uniqueId,
  uniqueNegativeId,
} from '../common/utility/numbers.js';
import {
  hasSessionStorage,
  sessionStorageWrapper,
} from '../common/utility/storage.js';
import {
  partialDateFromField,
} from '../edit/components/DateRangeFieldset.js';
import * as URLCleanup from '../edit/URLCleanup.js';
import {
  decompactEntityJson,
} from '../edit/utility/compactEntityJson.js';

import {
  createInitialState as createAttributeDialogState,
  reducer as attributeDialogReducer,
} from './components/ExternalLinkAttributeDialog.js';
import cleanupUrl from './utility/cleanupUrl.js';
import getLinkChecker from './utility/getLinkChecker.js';
import getLinkPhrase from './utility/getLinkPhrase.js';
import getUnicodeUrl from './utility/getUnicodeUrl.js';
import isLinkStateEmpty, {
  areLinkRelationshipsEmpty,
} from './utility/isLinkStateEmpty.js';
import shouldShowTypeSelection from './utility/shouldShowTypeSelection.js';
import type {
  LinkRelationshipStateT,
  LinksEditorActionT,
  LinksEditorStateT,
  LinkStateT,
} from './types.js';
import {
  normalizeUrl,
  validateLink,
} from './validation.js';

type SeededUrlShapeT = {
  link_type_id?: string,
  text?: string,
};

export function createInitialState(
  $c: SanitizedCatalystContextT,
): LinksEditorStateT {
  const source = getSourceEntityData($c);
  const state: {...LinksEditorStateT} = {
    focus: '',
    links: tree.empty,
    source,
  };

  let links: tree.ImmutableTree<LinkStateT> = tree.empty;
  if (typeof window !== 'undefined') {
    links = getInitialLinks($c, state, source);
  }
  state.links = links;

  // Perform an initial validation run on each of the links.
  for (const link of tree.iterate(state.links)) {
    const linkCtx = mutate(link);
    // This is safe during initialization only.
    linkCtx.dangerouslySetAsMutable();
    validateLink(state, linkCtx);
    linkCtx.final();
  }

  state.links = ensureEmptyLink(state, links);

  if (__DEV__) {
    deepFreeze(state);
  }

  return state;
}

function compareLinksByKey(a: LinkStateT, b: LinkStateT): number {
  return a.key - b.key;
}

function createLinkRelationshipState(
  props: Partial<LinkRelationshipStateT>,
): LinkRelationshipStateT {
  return {
    attributeDialogState: null,
    beginDate: null,
    editsPending: false,
    endDate: null,
    ended: false,
    entityCredit: '',
    error: null,
    id: props.id === undefined ? uniqueNegativeId() : props.id,
    linkTypeID: null,
    originalState: null,
    removed: false,
    url: '',
    video: false,
    ...props,
  };
}

function compareRelationshipsByTypeName(
  a: LinkRelationshipStateT,
  b: LinkRelationshipStateT,
): number {
  if (a.linkTypeID !== b.linkTypeID) {
    return compare(
      getLinkPhrase(a).toLowerCase(),
      getLinkPhrase(b).toLowerCase(),
    );
  }
  return 0;
}

function ensureEmptyLink(
  state: LinksEditorStateT,
  links: tree.ImmutableTree<LinkStateT>,
): tree.ImmutableTree<LinkStateT> {
  if (links.size) {
    const lastLink = tree.maxValue(links);
    if (empty(lastLink.url) && lastLink.relationships.length === 0) {
      return links;
    }
  }
  return tree.insertOrThrowIfExists(
    links,
    {
      duplicateOf: null,
      error: null,
      isNew: true,
      isSubmitted: false,
      key: uniqueId(),
      originalUrlEntity: null,
      rawUrl: '',
      relationships: [],
      url: '',
      urlPopoverLinkState: null,
    },
    compareLinksByKey,
  );
}

function getInitialLinks(
  $c: SanitizedCatalystContextT,
  state: LinksEditorStateT,
  source: RelatableEntityT,
): tree.ImmutableTree<LinkStateT> {
  if (
    $c.req.method === 'POST' &&
    /*
     * XXX The release editor submits edits asynchronously,
     * and does not save `submittedLinks` in `sessionStorage`.
     */
    source.entityType !== 'release'
  ) {
    if (hasSessionStorage) {
      const submittedLinksKey = getSubmittedLinksKey(source);
      const submittedLinksJson =
        sessionStorageWrapper.get(submittedLinksKey);
      if (submittedLinksJson) {
        const submittedLinks =
          // $FlowIgnore[incompatible-cast]
          decompactEntityJson(JSON.parse(submittedLinksJson))
          as tree.ImmutableTree<LinkStateT>;
        if (submittedLinks) {
          sessionStorageWrapper.remove(submittedLinksKey);
          if (submittedLinks.size) {
            advanceUniqueId(tree.maxValue(submittedLinks).key);
            return submittedLinks;
          }
        }
      }
    }
  }

  const relationships = source.relationships ?? [];
  const backward = source.entityType > 'url';
  type WritableLinkStateT = {
    ...LinkStateT,
    relationships: Array<LinkRelationshipStateT>,
  };
  const links: Array<WritableLinkStateT> = [];
  const linksByGid: Map<string, WritableLinkStateT> = new Map();
  const linksByUrl: Map<string, WritableLinkStateT> = new Map();
  for (const relationship of relationships) {
    if (relationship.target_type !== 'url') {
      continue;
    }
    if (__DEV__) {
      invariant(isDatabaseRowId(relationship.id));
    }
    const urlEntity = relationship.target;
    /*:: invariant(urlEntity.entityType === 'url'); */

    const linkRelationship = createLinkRelationshipState({
      beginDate: relationship.begin_date,
      editsPending: relationship.editsPending,
      endDate: relationship.end_date,
      ended: relationship.ended,
      entityCredit: backward
        ? relationship.entity1_credit
        : relationship.entity0_credit,
      id: relationship.id,
      linkTypeID: relationship.linkTypeID,
      url: urlEntity.name,
      video: relationship.attributes.some(isVideoAttribute),
    });
    // $FlowIgnore[cannot-write] - allow during initialization
    linkRelationship.originalState = linkRelationship;

    const prevLink = linksByGid.get(urlEntity.gid);
    if (prevLink) {
      prevLink.relationships.push(linkRelationship);
      continue;
    }

    const link: WritableLinkStateT = {
      duplicateOf: null,
      error: null,
      isNew: false,
      isSubmitted: true,
      // Keys are assigned after sorting below.
      key: 0,
      originalUrlEntity: urlEntity,
      rawUrl: urlEntity.name,
      relationships: [linkRelationship],
      url: urlEntity.name,
      urlPopoverLinkState: null,
    };
    links.push(link);
    linksByGid.set(urlEntity.gid, link);
    linksByUrl.set(urlEntity.name, link);
    linksByUrl.set(normalizeUrl(urlEntity.name), link);
  }

  for (const link of links) {
    link.relationships.sort(compareRelationshipsByTypeName);
  }

  links.sort((a, b) => (
    compare(
      getLinkPhrase(a.relationships[0]).toLowerCase(),
      getLinkPhrase(b.relationships[0]).toLowerCase(),
    ) ||
    compareStrings(a.url, b.url)
  ));

  /*
   * The `links` tree is ordered by key. The initial sort order is preserved
   * by by assigning incrementing `uniqueId` values.
   */
  for (const link of links) {
    link.key = uniqueId();
  }

  const pushSeededUrl = (
    rawUrl: string,
    linkTypeId: number | null,
  ) => {
    const unicodeUrl = getUnicodeUrl(rawUrl);
    const cleanUrl = URLCleanup.cleanURL(unicodeUrl);
    const relationship = createLinkRelationshipState({
      linkTypeID: linkTypeId,
      url: cleanUrl,
    });

    const existingLink = (
      linksByUrl.get(cleanUrl) ??
      linksByUrl.get(unicodeUrl) ??
      linksByUrl.get(rawUrl)
    );
    if (existingLink) {
      if (
        // Filter out seeded URLs that duplicate existing ones (MBS-13993).
        !existingLink.relationships.some(
          r => r.linkTypeID === relationship.linkTypeID,
        )
      ) {
        existingLink.relationships.push(relationship);
      }
      return;
    }

    const newLink: WritableLinkStateT = {
      duplicateOf: null,
      error: null,
      isNew: true,
      isSubmitted: nonEmpty(cleanUrl),
      key: uniqueId(),
      originalUrlEntity: null,
      rawUrl,
      relationships: [relationship],
      url: cleanUrl,
      urlPopoverLinkState: null,
    };
    links.push(newLink);
    linksByUrl.set(cleanUrl, newLink);
  };

  if (source.entityType === 'release') {
    const seededRelationships =
      $c.stash.seeded_release_data?.seed?.relationships;
    if (seededRelationships) {
      for (const data of seededRelationships) {
        const name = data.target?.name ?? '';
        const linkTypeId = data.linkTypeID ?? null;
        if (nonEmpty(name) || nonEmpty(linkTypeId)) {
          pushSeededUrl(name, linkTypeId);
        }
      }
    }
  }

  /*
   * If the form wasn't posted, extract seeded links from the URL
   * query parameters instead.
   */
  if ($c.req.method !== 'POST') {
    const seededSourceType = source.entityType.replace('_', '-');
    const seededLinkRegex = new RegExp(
      '(?:\\?|&)edit-' + seededSourceType +
        '\\.url\\.([0-9]+)\\.(text|link_type_id)=([^&]+)',
      'g',
    );
    const urls: {[index: string]: SeededUrlShapeT} = {};
    let match;

    while ((match = seededLinkRegex.exec(window.location.search))) {
      const [/* unused */, index, key, value] = match;
      switch (key) {
        case 'link_type_id':
        case 'text':
          (urls[index] ||= {})[key] = decodeURIComponent(value);
          break;
      }
    }

    for (const data of Object.values(urls)) {
      pushSeededUrl(
        data.text ?? '',
        parseInt(data.link_type_id, 10) || null,
      );
    }
  }

  return tree.fromDistinctAscArray(links);
}

export function getSubmittedLinksKey(source: RelatableEntityT): string {
  const sourceId = isDatabaseRowId(source.id) ? source.id : 'new';
  return `submittedLinks_${source.entityType}_${sourceId}`;
}

function isLinkRelationshipRemoved(
  relationship: LinkRelationshipStateT,
): boolean {
  return relationship.removed;
}

export function isLinkRemoved(link: LinkStateT): boolean {
  return !link.isNew && link.relationships.every(isLinkRelationshipRemoved);
}

const isVideoAttribute =
  (attr: LinkAttrT) => attr.type.gid === VIDEO_ATTRIBUTE_GID;

function moveFocusToNextLink(
  ctx: CowContext<LinksEditorStateT>,
  link: LinkStateT,
): void {
  const links = ctx.read().links;
  const nextLink = links.size ? (
    tree.findNext(
      ctx.read().links,
      link,
      compareLinksByKey,
      null,
    ) ??
    tree.maxValue(links)
  ) : null;
  ctx.set('focus', nextLink ? `#external-link-${nextLink.key}` : 'empty');
}

function toggleRemoveMatchingRelationships(
  relationshipsCtx: CowContext<$ReadOnlyArray<LinkRelationshipStateT>>,
  matchCallback: (LinkRelationshipStateT) => boolean,
  removed: boolean,
): void {
  relationshipsCtx.set(
    relationshipsCtx.read().reduce((result, relationship) => {
      if (matchCallback(relationship)) {
        const originalState = relationship.originalState;
        if (originalState) {
          if (__DEV__) {
            invariant(isDatabaseRowId(relationship.id));
          }
          if (relationship.removed === removed) {
            result.push(relationship);
          } else {
            result.push({...originalState, removed});
          }
        }
      } else {
        result.push(relationship);
      }
      return result;
    }, [] as Array<LinkRelationshipStateT>),
  );
}

function updateLink(
  stateCtx: CowContext<LinksEditorStateT>,
  link: LinkStateT,
  callback: (CowContext<LinkStateT>) => RemoveValue | void,
): void {
  const state = stateCtx.read();
  stateCtx.set('links', ensureEmptyLink(
    state,
    tree.update<LinkStateT, LinkStateT>(state.links, {
      cmp: compareLinksByKey,
      key: link,
      onConflict: (existingLink) => {
        const ctx = mutate(existingLink);
        const result = callback(ctx);
        if (result === REMOVE_VALUE) {
          ctx.final();
          return REMOVE_VALUE;
        }
        validateLink(stateCtx.read(), ctx);
        return ctx.final();
      },
      onNotFound: onNotFoundDoNothing,
    }),
  ));
}

function updateLinkRelationship(
  stateCtx: CowContext<LinksEditorStateT>,
  link: LinkStateT,
  relationship: LinkRelationshipStateT,
  callback: (
    existingLinkCtx: CowContext<LinkStateT>,
    existingRelationship: LinkRelationshipStateT,
    index: number,
  ) => void,
): void {
  updateLink(stateCtx, link, (linkCtx) => {
    const index = linkCtx.read().relationships
      .findIndex(r => r.id === relationship.id);
    if (index === -1) {
      return;
    }
    callback(linkCtx, relationship, index);
  });
}

export function reducer(
  state: LinksEditorStateT,
  action: LinksEditorActionT,
): LinksEditorStateT {
  const source = state.source;
  const ctx = mutate(state);

  switch (action.type) {
    case 'add-relationship': {
      const relationshipId = uniqueNegativeId();
      updateLink(ctx, action.link, linkCtx => {
        linkCtx.get('relationships').write().push(
          createLinkRelationshipState({id: relationshipId}),
        );
      });
      ctx.set('focus', '#url-link-type-' + relationshipId);
      break;
    }

    case 'set-focus': {
      ctx.set('focus', action.focus);
      break;
    }

    case 'cancel-url-input-popover': {
      updateLink(ctx, action.link, linkCtx => {
        linkCtx.set('urlPopoverLinkState', null);
      });
      break;
    }

    case 'handle-url-change': {
      const {link, rawUrl} = action;
      updateLink(ctx, link, linkCtx => {
        if (
          empty(rawUrl) &&
          linkCtx.read().isNew &&
          areLinkRelationshipsEmpty(linkCtx.read())
        ) {
          moveFocusToNextLink(ctx, link);
          return REMOVE_VALUE;
        }

        let newUrl = linkCtx.read().url;
        // Allow adding spaces while typing, they'll be trimmed on blur.
        if (newUrl !== rawUrl.trim()) {
          newUrl = cleanupUrl(rawUrl.trim());
        }

        linkCtx
          .set('rawUrl', rawUrl)
          .set('url', newUrl);

        const relationshipsCtx = linkCtx.get('relationships');
        const checker = getLinkChecker(source.entityType, linkCtx.read());
        const possibleTypes = checker.possibleTypes;

        if (possibleTypes.length) {
          // Remove relationships having disallowed types.
          toggleRemoveMatchingRelationships(
            relationshipsCtx,
            relationship => {
              const linkTypeId = relationship.linkTypeID;
              return linkTypeId !== null &&
                !possibleTypes.includes(
                  linkedEntities.link_type[linkTypeId].gid,
                );
            },
            true,
          );
        }

        const existingTypesIds = new Set<number | null>(
          relationshipsCtx.read().map(r => r.linkTypeID),
        );
        const newRelationships = [];
        let guessedTypeGids = checker.guessType();
        if (guessedTypeGids) {
          if (typeof guessedTypeGids === 'string') {
            guessedTypeGids = [guessedTypeGids];
          }
          for (const gid of guessedTypeGids) {
            const linkTypeID = linkedEntities.link_type[gid].id;
            if (!existingTypesIds.has(linkTypeID)) {
              newRelationships.push(
                createLinkRelationshipState({
                  linkTypeID,
                  url: newUrl,
                }),
              );
            }
          }
        }

        if (newRelationships.length) {
          // Remove empty relationships & merge new ones.
          toggleRemoveMatchingRelationships(
            relationshipsCtx,
            relationship => relationship.linkTypeID === null,
            true,
          );
          relationshipsCtx.write().push(...newRelationships);
        } else if (newUrl && relationshipsCtx.read().length === 0) {
          // Add at least one empty relationship.
          relationshipsCtx.set([createLinkRelationshipState({})]);
        }

        return undefined;
      });
      break;
    }

    case 'merge-link': {
      const duplicate = action.link;
      invariant(duplicate.isNew);
      const duplicateOf = duplicate.duplicateOf;
      if (!duplicateOf) {
        return state;
      }
      moveFocusToNextLink(ctx, duplicate);
      ctx.set('links', tree.remove(
        state.links,
        duplicate,
        compareLinksByKey,
      ));
      updateLink(ctx, duplicateOf.link, existingLinkCtx => {
        const existingRelationships = existingLinkCtx.read().relationships;
        const existingRelationshipTypeIds =
          new Set(existingRelationships.map(r => r.linkTypeID));
        existingLinkCtx.set(
          'relationships',
          existingRelationships.concat(
            duplicate.relationships.filter(
              r => r.linkTypeID == null ||
                !existingRelationshipTypeIds.has(r.linkTypeID),
            ),
          ),
        );
      });
      break;
    }

    case 'open-url-input-popover': {
      updateLink(ctx, action.link, linkCtx => {
        linkCtx.set('urlPopoverLinkState', linkCtx.read());
      });
      break;
    }

    case 'toggle-remove-link': {
      updateLink(ctx, action.link, linkCtx => {
        const relationshipsCtx = linkCtx.get('relationships');
        toggleRemoveMatchingRelationships(
          relationshipsCtx,
          () => true,
          !isLinkRemoved(linkCtx.read()),
        );
        if (relationshipsCtx.read().length) {
          const originalUrlEntity = linkCtx.read().originalUrlEntity;
          invariant(originalUrlEntity != null);
          linkCtx
            .set('url', originalUrlEntity.name)
            .set('rawUrl', originalUrlEntity.name);
          return undefined;
        }
        // If there were no existing relationships, remove the whole link.
        moveFocusToNextLink(ctx, action.link);
        return REMOVE_VALUE;
      });
      break;
    }

    case 'toggle-remove-relationship': {
      const relationship = action.relationship;
      updateLink(
        ctx,
        action.link,
        (linkCtx) => {
          const relationshipsCtx = linkCtx.get('relationships');
          // Move focus to the next <select>.
          if (!isDatabaseRowId(relationship.id)) {
            const relationships = relationshipsCtx.read();
            const nextRelationship = relationships.find((r, i) => (
              i > 0 && relationships[i - 1].id === relationship.id
            )) ?? relationships[relationships.length - 2];
            if (nextRelationship) {
              ctx.set('focus', `#url-link-type-${nextRelationship.id}`);
            }
          }
          toggleRemoveMatchingRelationships(
            relationshipsCtx,
            other => other.id === relationship.id,
            !relationship.removed,
          );
        },
      );
      break;
    }

    case 'set-type': {
      updateLinkRelationship(
        ctx,
        action.link,
        action.relationship,
        (linkCtx, relationship, index) => {
          linkCtx.set(
            'relationships', index, 'linkTypeID', action.linkTypeID,
          );
        },
      );
      break;
    }

    case 'submit-link': {
      const link = action.link;
      if (!(
        link.isSubmitted ||
        isLinkStateEmpty(link) ||
        link.error ||
        link.duplicateOf
      )) {
        updateLink(
          ctx,
          link,
          linkCtx => {
            const cleanUrl = linkCtx.read().url.trim();
            linkCtx
              .set('isSubmitted', true)
              .set('rawUrl', cleanUrl)
              .set('url', getUnicodeUrl(cleanUrl));

            const updatedLink = linkCtx.read();
            const relationshipToFocus = updatedLink.relationships.find(
              r => shouldShowTypeSelection(source.entityType, updatedLink, r),
            );
            if (relationshipToFocus) {
              ctx.set('focus', `#url-link-type-${relationshipToFocus.id}`);
            } else {
              moveFocusToNextLink(ctx, updatedLink);
            }
          },
        );
      }
      break;
    }

    case 'set-video': {
      const {link, relationship, video} = action;
      updateLinkRelationship(
        ctx,
        link,
        relationship,
        (linkCtx, existingRelationship, index) => {
          linkCtx.set('relationships', index, 'video', video);
        },
      );
      break;
    }

    case 'update-url-input-popover-url': {
      const {link, rawUrl} = action;
      updateLink(ctx, link, linkCtx => {
        const pendingLink = linkCtx.read().urlPopoverLinkState ?? link;
        const updatedPendingLink = mutate(pendingLink)
          .set('rawUrl', rawUrl)
          .set('url', cleanupUrl(rawUrl))
          .final();
        linkCtx.set('urlPopoverLinkState', updatedPendingLink);
      });
      break;
    }

    case 'accept-url-input-popover': {
      updateLink(ctx, action.link, linkCtx => {
        const {
          urlPopoverLinkState: acceptedLink,
        } = linkCtx.read();
        invariant(acceptedLink != null);
        if (acceptedLink.isNew && empty(acceptedLink.url)) {
          moveFocusToNextLink(ctx, action.link);
          return REMOVE_VALUE;
        }
        linkCtx
          .set(acceptedLink)
          .set('urlPopoverLinkState', null);
        return undefined;
      });
      /*
       * `validateLink` (which runs after the `updateLink` callback)
       * may have marked the link as unsubmitted if it's a duplicate.
       * In that case, the edit button will be disabled, so focus cannot
       * return to it. Return focus to the URL input instead.
       */
      const link = tree.find(
        ctx.read().links,
        action.link,
        compareLinksByKey,
      );
      if (link && !link.isSubmitted) {
        ctx.set('focus', '#external-link-' + link.key + ' input[type=url]');
      }
      break;
    }

    case 'update-attribute-dialog': {
      updateLinkRelationship(
        ctx,
        action.link,
        action.relationship,
        (linkCtx, existingRelationship, index) => {
          linkCtx.set(
            'relationships',
            index,
            'attributeDialogState',
            attributeDialogReducer(
              expect(existingRelationship.attributeDialogState),
              action.action,
            ),
          );
        },
      );
      break;
    }

    case 'accept-attribute-dialog': {
      const {link, relationship} = action;
      const attributeDialogState = expect(relationship.attributeDialogState);
      const dateFields = attributeDialogState.datePeriodField.field;
      updateLinkRelationship(
        ctx,
        link,
        relationship,
        (linkCtx, existingRelationship, index) => {
          linkCtx.update('relationships', index, ctx => {
            ctx
              .set('attributeDialogState', null)
              .set('beginDate', partialDateFromField(dateFields.begin_date))
              .set('endDate', partialDateFromField(dateFields.end_date))
              .set('ended', dateFields.ended.value)
              .set('entityCredit',
                   attributeDialogState.creditField.value ?? '');
          });
        },
      );
      break;
    }

    case 'toggle-attribute-dialog': {
      updateLinkRelationship(
        ctx,
        action.link,
        action.relationship,
        (linkCtx, existingRelationship, index) => {
          linkCtx.set(
            'relationships',
            index,
            'attributeDialogState',
            action.open
              ? createAttributeDialogState(existingRelationship)
              : null,
          );
        },
      );
      break;
    }

    default: {
      /*:: action.type as empty; */
    }
  }

  return ctx.final();
}
