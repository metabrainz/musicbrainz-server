/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import * as React from 'react';
import * as ReactDOMClient from 'react-dom/client';

import {
  EMPTY_PARTIAL_DATE,
  ENTITIES_WITH_RELATIONSHIP_CREDITS,
  VIDEO_ATTRIBUTE_GID,
} from '../../common/constants.js';
import {compare, l} from '../../common/i18n.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import MB from '../../common/MB.js';
import {groupBy, keyBy, uniqBy} from '../../common/utility/arrays.js';
import {
  getCatalystContext,
  getSourceEntityData,
} from '../../common/utility/catalyst.js';
import {compareDatePeriods} from '../../common/utility/compareDates.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {
  hasSessionStorage,
  sessionStorageWrapper,
} from '../../common/utility/storage.js';
import {uniqueId} from '../../common/utility/strings.js';
import withLoadedTypeInfo from '../../edit/components/withLoadedTypeInfo.js';
import {linkTypeOptions} from '../../edit/forms.js';
import type {RelationshipTypeT} from '../../edit/URLCleanup.js';
import * as URLCleanup from '../../edit/URLCleanup.js';
import {
  compactEntityJson,
  decompactEntityJson,
} from '../../edit/utility/compactEntityJson.js';
import isPositiveInteger from '../../edit/utility/isPositiveInteger.js';
import isShortenedUrl from '../../edit/utility/isShortenedUrl.js';
import * as validation from '../../edit/validation.js';
import {
  appendHiddenRelationshipInputs,
} from '../../relationship-editor/utility/prepareHtmlFormSubmission.js';
import {isMalware} from '../../url/utility/isGreyedOut.js';
import type {
  CreditableEntityOptionsT,
  ErrorT,
  HighlightT,
  LinkMapT,
  LinkRelationshipT,
  LinksEditorPropsT,
  LinksEditorStateT,
  LinkStateT,
  LinkTypeOptionT,
  SeededUrlShapeT,
} from '../types.js';
import getUnicodeUrl from '../utility/getUnicodeUrl.js';
import isValidURL from '../utility/isValidURL.js';

import ExternalLink, {type ExternalLinkPropsT} from './ExternalLink.js';

const HIGHLIGHTS = {
  ADD: 'rel-add' as HighlightT,
  EDIT: 'rel-edit' as HighlightT,
  NONE: '' as HighlightT,
  REMOVE: 'rel-remove' as HighlightT,
};

export class _ExternalLinksEditor
  extends React.Component<LinksEditorPropsT, LinksEditorStateT> {
  creditableEntityProp: 'entity0_credit' | 'entity1_credit' | null;

  tableRef: {current: HTMLTableElement | null};

  generalLinkTypes: $ReadOnlyArray<LinkTypeOptionT>;

  oldLinks: LinkMapT;

  +errorObservable: (boolean) => void;

  +initialLinks: $ReadOnlyArray<LinkStateT>;

  +sourceType: RelatableEntityTypeT;

  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>;

  +submittedLinksWrapper: {
    get(): ?Array<LinkStateT>,
    remove(): void,
    set(links: $ReadOnlyArray<LinkStateT>): void,
  };

  constructor(props: LinksEditorPropsT) {
    super(props);

    const sourceData = props.sourceData;
    const sourceType = sourceData.entityType;
    const entityTypes = [sourceType, 'url'].sort().join('-');
    let initialLinks = parseRelationships(sourceData);

    initialLinks.sort(function (a, b) {
      const typeA = a.type && linkedEntities.link_type[a.type];
      const typeB = b.type && linkedEntities.link_type[b.type];

      return compare(
        typeA ? l_relationships(typeA.link_phrase).toLowerCase() : '',
        typeB ? l_relationships(typeB.link_phrase).toLowerCase() : '',
      );
    });

    const sourceId = isDatabaseRowId(sourceData.id) ? sourceData.id : 'new';
    const submittedLinksKey = `submittedLinks_${sourceType}_${sourceId}`;
    this.submittedLinksWrapper = {
      get() {
        if (hasSessionStorage) {
          const submittedLinksJson =
            sessionStorageWrapper.get(submittedLinksKey);
          if (submittedLinksJson) {
            return ((
              decompactEntityJson(JSON.parse(submittedLinksJson))
            ): any).filter(l => !isEmpty(l)).map(newLinkState);
          }
        }
        return undefined;
      },
      remove() {
        sessionStorageWrapper.remove(submittedLinksKey);
      },
      set(links) {
        if (hasSessionStorage) {
          sessionStorageWrapper.set(
            submittedLinksKey,
            JSON.stringify(compactEntityJson(links)),
          );
        }
      },
    };

    if (typeof window !== 'undefined') {
      const $c = getCatalystContext();
      if (
        $c.req.method === 'POST' &&
        /*
         * XXX The release editor submits edits asynchronously,
         * and does not save `submittedLinks` in `sessionStorage`.
         */
        sourceType !== 'release'
      ) {
        const submittedLinks = this.submittedLinksWrapper.get();
        if (submittedLinks) {
          initialLinks = submittedLinks;
          this.submittedLinksWrapper.remove();
        }
      } else {
        /*
         * If the form wasn't posted, extract seeded links from the URL
         * query parameters instead.
         */
        const seededSourceType = sourceType === 'release_group'
          ? 'release-group'
          : sourceType;
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
          initialLinks.push(newLinkState({
            rawUrl: data.text || '',
            relationship: uniqueId('new-'),
            type: parseInt(data.link_type_id, 10) || null,
            url: getUnicodeUrl(data.text || ''),
          }));
        }
      }
    }

    const existingInitialLinks = [];
    const pendingInitialLinks = [];
    for (const link of initialLinks) {
      if (isPositiveInteger(link.relationship)) {
        existingInitialLinks.push(link);
      } else {
        /*
         * Only run the URL cleanup on seeded URLs, i.e. URLs that don't have
         * an existing relationship ID.
         */
        const url = getUnicodeUrl(link.url);
        pendingInitialLinks.push({
          ...link,
          relationship: uniqueId('new-'),
          url: URLCleanup.cleanURL(url) || url,
        });
      }
    }

    // Filter out seeded URLs that duplicate existing ones (MBS-13993).
    const existingInitialLinksByTypeAndUrl = groupBy(
      existingInitialLinks,
      linkTypeAndUrlString,
    );
    initialLinks = existingInitialLinks.concat(
      pendingInitialLinks.filter(
        link => !existingInitialLinksByTypeAndUrl.has(
          linkTypeAndUrlString(link),
        ),
      ),
    );

    this.typeOptions = linkTypeOptions(
      {children: linkedEntities.link_type_tree[entityTypes]},
      /^url-/.test(entityTypes),
    );

    this.sourceType = sourceType;
    this.initialLinks = initialLinks;
    if (ENTITIES_WITH_RELATIONSHIP_CREDITS[sourceType]) {
      this.creditableEntityProp = sourceType < 'url'
        ? 'entity0_credit'
        : 'entity1_credit';
    } else {
      this.creditableEntityProp = null;
    }
    this.state = {links: withOneEmptyLink(initialLinks)};
    this.tableRef = React.createRef();
    this.oldLinks = this.getOldLinksHash();
    this.generalLinkTypes = this.typeOptions.filter(
      // Keep disabled options for grouping
      (option) => option.disabled ||
      !URLCleanup.RESTRICTED_LINK_TYPES.includes(option.data.gid),
    );
    this.errorObservable = props.errorObservable ||
      validation.errorField(ko.observable(false));
    this.copyEditDataToReleaseEditor();
  }

  copyEditDataToReleaseEditor() {
    const releaseEditor = MB._releaseEditor;
    if (releaseEditor) {
      /*
       * `externalLinksEditData` is an observable hooked into the release
       * editor's edit generation code.
       */
      // $FlowFixMe[prop-missing]
      releaseEditor.externalLinksEditData(this.getEditData());
    }
  }

  componentDidUpdate() {
    this.copyEditDataToReleaseEditor();
  }

  setLinkState(
    index: number,
    state: $ReadOnly<Partial<LinkStateT>>,
    callback?: () => void,
  ) {
    const newLinks: Array<LinkStateT> = this.state.links.slice(0);
    newLinks[index] = {...newLinks[index], ...state};
    this.setState({links: newLinks}, callback);
  }

  cleanupUrl(url: string): string {
    if (url.match(/^\w+\./)) {
      url = 'http://' + url;
    }
    return URLCleanup.cleanURL(url) || url;
  }

  handleUrlChange(
    linkIndexes: $ReadOnlyArray<number>,
    urlIndex: number,
    rawUrl: string,
  ) {
    let url = rawUrl;
    if (url === '') {
      this.removeLinks(linkIndexes, urlIndex);
      return;
    }

    this.setState(prevState => {
      const newLinks = [...prevState.links];
      linkIndexes.forEach(index => {
        const link = newLinks[index];

        // Allow adding spaces while typing, they'll be trimmed on blur
        if (url.trim() !== link.url.trim()) {
          url = this.cleanupUrl(url);
        }

        const newLink = {...newLinks[index], rawUrl, url};
        const checker = new URLCleanup.Checker(url, this.sourceType);
        const guessedType = checker.guessType();
        const possibleTypes = checker.possibleTypes;
        const typeOptions = this.filterTypeOptions(possibleTypes);
        // Clear selection if current type is not allowed
        if (link.type &&
          !typeOptions.some(option => option.data.id === link.type)) {
          newLink.type = null;
        }
        if (!newLink.type && guessedType) {
          if (typeof guessedType === 'string') { // Is a single type
            newLink.type = linkedEntities.link_type[guessedType].id;
          } else {
            // Is a type combination, set one and add other relationships
            newLink.type = linkedEntities.link_type[guessedType[0]].id;
            newLink.pendingTypes = guessedType
              .slice(1)
              .map(type => linkedEntities.link_type[type].id);
          }
        }
        newLinks[index] = newLink;
      });
      return {links: withOneEmptyLink(newLinks, -1)};
    });
  }

  handleUrlBlur(
    index: number,
    isDuplicate: boolean,
    event: SyntheticFocusEvent<HTMLInputElement>,
    urlIndex: number,
    canMerge: boolean,
  ) {
    const link: {...LinkStateT} = {...this.state.links[index]};
    const url = event.currentTarget.value;
    const trimmed = url.trim();
    const unicodeUrl = getUnicodeUrl(trimmed);

    if (url !== unicodeUrl) {
      link.url = unicodeUrl;
    }

    /*
     * Don't add link to list if it's empty,
     * has error, or is a duplicate without type.
     */
    if (url !== '' && canMerge && (!isDuplicate || link.type)) {
      link.submitted = true;
      if (isDuplicate) {
        /*
         * $FlowExpectedError[incompatible-type]: relatedTarget is EventTarget
         * Don't merge when user clicks on delete icon,
         * otherwise UI change will prevent the deletion.
         */
        const relatedTarget: HTMLElement = event.relatedTarget;
        const clickingDeleteIcon =
          relatedTarget &&
          relatedTarget.dataset.index === urlIndex.toString();
        if (clickingDeleteIcon) {
          link.submitted = false;
        }
        this.setLinkState(index, link, () => {
          if (link.submitted) {
            this.submitPendingTypes(link, index);
          }
          // Return focus to the input box after merging
          $(this.tableRef.current)
            .find("input[type='url']")
            .eq(0)
            .focus();
        });
      } else {
        this.setLinkState(index, link, () => {
          if (link.submitted) {
            this.submitPendingTypes(link, index);
          }
        });
      }
    } else {
      this.setLinkState(index, link);
    }
  }

  submitPendingTypes(link: LinkStateT, index: number) {
    const pendingTypes = link.pendingTypes;
    if (!pendingTypes) {
      return;
    }
    this.setState(prevState => {
      let newLinks = [...prevState.links];
      newLinks[index] = {...newLinks[index], pendingTypes: null};
      const emptyLinkIndex = newLinks.findIndex(link => {
        const isNewLink = !isPositiveInteger(link.relationship);
        return isNewLink && isEmpty(link);
      });
      // Remove existing empty links first to maintain the order
      if (emptyLinkIndex > 0) {
        newLinks.splice(emptyLinkIndex);
      }
      newLinks = newLinks.concat(pendingTypes.map(type => {
        const linkState = {
          submitted: true,
          type,
          url: link.url,
        };
        return newLinkState({
          ...linkState,
          relationship: uniqueId('new-'),
        });
      }));
      return {links: withOneEmptyLink(newLinks, -1)};
    });
  }

  handleLinkSubmit(
    index: number,
    urlIndex: number,
    event: SyntheticEvent<HTMLInputElement>,
    canMerge: boolean,
  ) {
    const link: {...LinkStateT} = {...this.state.links[index]};
    const url = event.currentTarget.value;
    const trimmed = url.trim();
    const unicodeUrl = getUnicodeUrl(trimmed);

    if (url !== unicodeUrl) {
      link.url = unicodeUrl;
    }
    // Don't add link to list if it's empty or has error
    if (url !== '' && canMerge) {
      link.submitted = true;
      this.setLinkState(index, link, () => {
        this.submitPendingTypes(link, index);
        // Redirect focus instead of staying on the current link
        if (link.type) {
          // If type is selected, jump to the next item(either input or link)
          $(this.tableRef.current)
            .find(`tr.external-link-item:eq(${urlIndex + 1})`)
            .find('a,input')
            .eq(0)
            .focus();
        } else {
          // If type is not selected, jump to type selector
          $(this.tableRef.current)
            .find(`tr.external-link-item:eq(${urlIndex})
                  + tr.relationship-item`)
            .find('select.link-type')
            .focus();
        }
      });
    } else {
      this.setLinkState(index, link);
    }
  }

  handleTypeChange(
    index: number,
    event: SyntheticEvent<HTMLSelectElement>,
  ) {
    const type = Number(event.currentTarget.value) || null;
    const link = {...this.state.links[index]};
    link.type = type;
    this.setLinkState(index, link);
  }

  handleTypeBlur(
    index: number,
    event: SyntheticFocusEvent<HTMLSelectElement>,
    isDuplicate: boolean,
    urlIndex: number,
    canMerge: boolean,
  ) {
    if (!isDuplicate || !canMerge) {
      return;
    }
    /*
     * $FlowExpectedError[incompatible-type]: relatedTarget is EventTarget
     * Don't merge when user clicks on delete icon,
     * otherwise UI change will prevent the deletion.
     */
    const relatedTarget: HTMLElement = event.relatedTarget;
    const clickingDeleteIcon =
      relatedTarget && relatedTarget.dataset.index === urlIndex.toString();
    if (clickingDeleteIcon) {
      return;
    }

    const link: {...LinkStateT} = {...this.state.links[index]};
    if (link.url && link.type) {
      link.submitted = true;
    }
    this.setLinkState(index, link, () => {
      this.submitPendingTypes(link, index);
      // Return focus to the input box after merging
      $(this.tableRef.current)
        .find("input[type='url']")
        .eq(0)
        .focus();
    });
  }

  handleVideoChange(index: number, event: SyntheticEvent<HTMLInputElement>) {
    this.setLinkState(index, {video: event.currentTarget.checked});
  }

  removeLink(index: number) {
    this.setState(prevState => {
      const newLinks = prevState.links.slice(0);
      const link = newLinks[index];
      if (isPositiveInteger(link.relationship)) { // Old link, toggle deleted
        newLinks[index] = {...link, deleted: !link.deleted};
      } else {
        newLinks.splice(index, 1);
      }
      return {links: newLinks};
    });
  }

  removeLinks(indexes: $ReadOnlyArray<number>, urlIndex: number) {
    this.setState(prevState => {
      const newLinks = [...prevState.links];
      // Iterate from the end to avoid messing up indexes
      for (let i = indexes.length - 1; i >= 0; --i) {
        const index = indexes[i];
        const link = newLinks[index];
        // Old link, toggle deleted
        if (isPositiveInteger(link.relationship)) {
          newLinks[index] = {...link, deleted: !link.deleted};
        } else {
          newLinks.splice(index, 1);
        }
      }
      return {links: withOneEmptyLink(newLinks, -1)};
    }, () => {
      // Return focus to the next item
      $(this.tableRef.current)
        .find(`tr.external-link-item:eq(${urlIndex})`)
        .find('button.edit-item, input')
        .eq(0)
        .focus();
    });
  }

  addRelationship(url: string, urlIndex: number) {
    this.setState(prevState => {
      const links = [...prevState.links];
      const linkCount = links.length;
      const lastLink = links[linkCount - 1];
      /*
       * If the last (latest-added) link is empty, then use it
       * to maintain the order that the empty link should be at the end.
       */
      if (lastLink.url === '') {
        links[linkCount - 1] = {...lastLink, submitted: true, url};
        return {links: withOneEmptyLink(links)};
      }
      // Otherwise create a new link with the given URL
      const newRelationship = newLinkState({
        relationship: uniqueId('new-'), submitted: true, url,
      });
      return {links: prevState.links.concat([newRelationship])};
    }, () => {
      // Return focus to the new type select
      $(this.tableRef.current)
        .find(`tr.add-relationship:eq(${urlIndex})`)
        .prev()
        .find('select.link-type')
        .focus();
    });
  }

  getOldLinksHash(): LinkMapT {
    return keyBy<LinkStateT, string>(
      this.initialLinks
        .filter(link => isPositiveInteger(link.relationship)),
      x => String(x.relationship),
    );
  }

  getEditData(): {
    allLinks: LinkMapT,
    newLinks: LinkMapT,
    oldLinks: LinkMapT,
    } {
    const oldLinks = this.getOldLinksHash();
    const newLinks: LinkMapT = keyBy(
      this.state.links.filter(link => !link.deleted),
      x => String(x.relationship),
    );

    return {
      allLinks: new Map([...oldLinks, ...newLinks]),
      newLinks,
      oldLinks,
    };
  }

  validateLink(
    link: LinkRelationshipT | LinkStateT,
    checker?: URLCleanup.Checker,
  ): ErrorT | null {
    const linksByTypeAndUrl = groupBy(
      uniqBy(
        this.state.links.concat(this.initialLinks),
        link => link.relationship,
      ),
      linkTypeAndUrlString,
    );
    let error: ErrorT | null = null;

    const linkType = link.type
      ? linkedEntities.link_type[link.type] : null;
    // Use existing checker if possible, otherwise create a new one
    checker ||= new URLCleanup.Checker(link.url, this.sourceType);
    const oldLink = this.oldLinks.get(String(link.relationship));
    const isNewLink = !isPositiveInteger(link.relationship);
    const linkChanged = oldLink && link.url !== oldLink.url;
    const isNewOrChangedLink = (isNewLink || linkChanged);
    const linkTypeChanged = oldLink &&
      Number(link.type) !== Number(oldLink.type);

    if (isEmpty(link)) {
      error = null;
    } else if (!link.url) {
      error = {
        message: l('Required field.'),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && !isValidURL(link.url)) {
      error = {
        message: exp.l('Please enter a valid URL, such as “{example_url}”.',
                       {example_url: <span className="url-quote">{'http://example.com/'}</span>}),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isExample(link.url)) {
      error = {
        message: exp.l(
          `“{example_url}” is just an example.
           Please enter the actual link you want to add.`,
          {example_url: <span className="url-quote">{link.url}</span>},
        ),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isMusicBrainz(link.url)) {
      error = {
        message: l(`Links to MusicBrainz URLs are not allowed.
                    Did you mean to paste something else?`),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isCritiqueBrainz(link.url)) {
      error = {
        message: texp.l(
          `Please don’t enter CritiqueBrainz links — reviews
           are automatically linked from the “{reviews_tab_name}” tab.`,
          {reviews_tab_name: l('Reviews')},
        ),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isMalware(link.url)) {
      error = {
        message: l(`Links to this website are not allowed
                    because it is known to host malware.`),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isShortenedUrl(link.url)) {
      error = {
        message: l(`Please don’t enter bundled/shortened URLs,
                    enter the destination URL(s) instead.`),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isGoogleAmp(link.url)) {
      error = {
        message: l(`Please don’t enter Google AMP links,
                    since they are effectively an extra redirect.
                    Enter the destination URL instead.`),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (isNewOrChangedLink && isGoogleSearch(link.url)) {
      error = {
        message: l(`Please don’t enter links to search results.
                    If you’ve found any links through your search
                    that seem useful, do enter those instead.`),
        target: URLCleanup.ERROR_TARGETS.URL,
      };
    } else if (!link.type) {
      error = {
        message: l(`Please select a link type for the URL
                    you’ve entered.`),
        target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
      };
    } else if (
      linkType &&
      linkType.deprecated &&
      (isNewLink || linkTypeChanged)
    ) {
      error = {
        message: l(`This relationship type is deprecated 
                    and should not be used.`),
        target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
      };
    } else if (
      (linksByTypeAndUrl.get(linkTypeAndUrlString(link)) ||
        []).length > 1
    ) {
      error = {
        blockMerge: true,
        message: l('This relationship already exists.'),
        target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
      };
    } else if (linkType && isNewOrChangedLink) {
      const check = checker.checkRelationship(linkType.gid);
      if (!check.result) {
        error = ({
          message: '',
          target: URLCleanup.ERROR_TARGETS.NONE,
        }: ErrorT);
        error.target = check.target || URLCleanup.ERROR_TARGETS.NONE;
        if (error.target === URLCleanup.ERROR_TARGETS.URL) {
          error.message = l(`This URL is not allowed
                             for the selected link type,
                             or is incorrectly formatted.`);
        }
        if (error.target === URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
          error.message = l(`This URL is not allowed 
                             for the selected link type.`);
        }
        if (error.target === URLCleanup.ERROR_TARGETS.ENTITY) {
          error.message = match (checker) {
            {entityType: 'area', ...} =>
              l('This URL is not allowed for areas.'),
            {entityType: 'artist', ...} =>
              l('This URL is not allowed for artists.'),
            {entityType: 'event', ...} =>
              l('This URL is not allowed for events.'),
            {entityType: 'genre', ...} =>
              l('This URL is not allowed for genres.'),
            {entityType: 'instrument', ...} =>
              l('This URL is not allowed for instruments.'),
            {entityType: 'label', ...} =>
              l('This URL is not allowed for labels.'),
            {entityType: 'place', ...} =>
              l('This URL is not allowed for places.'),
            {entityType: 'recording', ...} =>
              l('This URL is not allowed for recordings.'),
            {entityType: 'release', ...} =>
              l('This URL is not allowed for releases.'),
            {entityType: 'release_group', ...} =>
              l('This URL is not allowed for release groups.'),
            {entityType: 'series', ...} =>
              l('This URL is not allowed for series.'),
            {entityType: 'work', ...} =>
              l('This URL is not allowed for works.'),
            // URLs don't themselves have an external links editor
            {entityType: 'url', ...} => '',
          };
        }
        error.message = check.error || error.message;
      }
    }
    return error;
  }

  filterTypeOptions(
    possibleTypes: $ReadOnlyArray<RelationshipTypeT> | null,
  ): $ReadOnlyArray<LinkTypeOptionT> {
    if (!possibleTypes) {
      return this.generalLinkTypes;
    }
    return this.typeOptions.filter((option) => {
      // Keep disabled options for grouping
      if (option.disabled) {
        return true;
      }
      return possibleTypes.some((types) => {
        if (typeof types === 'string') {
          return types === option.data.gid;
        }
        return types.includes(option.data.gid);
      });
    });
  }

  getURLHighlightType(relationships: Array<LinkRelationshipT>): HighlightT {
    const link = relationships[0];
    if (this.props.isNewEntity) {
      return HIGHLIGHTS.NONE;
    }
    const oldLink = this.oldLinks.get(String(link.relationship));
    const linkChanged = oldLink && link.url !== oldLink.url;
    if (linkChanged) {
      return HIGHLIGHTS.EDIT;
    }
    if (relationships.every(link => !isPositiveInteger(link.relationship))) {
      return HIGHLIGHTS.ADD;
    }
    if (relationships.every(link => link.deleted)) {
      return HIGHLIGHTS.REMOVE;
    }
    return HIGHLIGHTS.NONE;
  }

  getRelationshipHighlightType(
    link: LinkRelationshipT,
    creditableEntityProp: CreditableEntityOptionsT,
  ): HighlightT {
    if (this.props.isNewEntity) {
      return HIGHLIGHTS.NONE;
    }
    if (link.deleted) {
      return HIGHLIGHTS.REMOVE;
    }
    if (!isPositiveInteger(link.relationship)) {
      return HIGHLIGHTS.ADD;
    }
    const oldLink = this.oldLinks.get(String(link.relationship));
    const linkTypeChanged = oldLink &&
      Number(link.type) !== Number(oldLink.type);
    const creditChanged =
      oldLink && creditableEntityProp &&
      oldLink[creditableEntityProp] !== link[creditableEntityProp];
    const datePeriodTypeChanged =
      oldLink && compareDatePeriods(oldLink, link);
    if (linkTypeChanged || creditChanged || datePeriodTypeChanged) {
      return HIGHLIGHTS.EDIT;
    }
    return HIGHLIGHTS.NONE;
  }

  isNewOrChangedLink(link: LinkRelationshipT): boolean {
    const isNewLink = !isPositiveInteger(link.relationship);

    if (isNewLink) {
      return true;
    }

    const oldLink = this.oldLinks.get(String(link.relationship));
    const linkChanged = oldLink && link.url !== oldLink.url;
    const linkTypeChanged = oldLink &&
      Number(link.type) !== Number(oldLink.type);

    return Boolean(linkChanged || linkTypeChanged);
  }

  render(): React.MixedElement {
    this.errorObservable(false);

    const linksArray = this.state.links;
    const linksGroupMap = groupLinksByUrl(linksArray);
    const linksByUrl = Array.from(linksGroupMap);

    return (
      <table
        className="row-form"
        id="external-links-editor"
        ref={this.tableRef}
      >
        <tbody>
          {linksByUrl.map((item, index) => {
            const relationships = item[1];
            /*
             * The first element of tuple `item` is not the URL
             * when the URL is not submitted therefore isn't grouped.
             */
            const {url, rawUrl, entity1} = relationships[0];
            const isLastLink = index === linksByUrl.length - 1;
            const links = [...relationships];
            const linkIndexes = [];

            // Check duplicates and show notice
            const duplicate = links[0].submitted
              ? null : linksGroupMap.get(url);

            let urlError: ErrorT | null = null;
            let hasError = false;
            let canMerge = true;
            const checker = new URLCleanup.Checker(
              url, this.sourceType,
            );
            const possibleTypes = checker.possibleTypes;
            const selectedTypes: Array<string> = [];
            const typeOptions = this.filterTypeOptions(possibleTypes);
            links.forEach(link => {
              linkIndexes.push(link.index);
              const linkType = link.type
                ? linkedEntities.link_type[link.type] : null;
              if (linkType) {
                selectedTypes.push(linkType.gid);
              }

              /*
               * FIXME: Why are links validated on every render, rather than
               * when they're modified?
               */
              const error = this.validateLink(link, checker);
              if (error) {
                if (this.isNewOrChangedLink(link)) {
                  this.errorObservable(true);
                  hasError = true;
                }
                if (error.target === URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
                  /*
                   * FIXME: This should be read-only! See question above.
                   */
                  // $FlowFixMe[cannot-write]
                  link.error = error;
                } else {
                  canMerge = false;
                  urlError = error;
                }
                if (error.blockMerge) {
                  canMerge = false;
                }
              }
            });

            // If a link has pending types, it must have only 1 possible type
            let urlMatchesType = links[0].pendingTypes != null;
            /*
             * Only validate type combination
             * when every single type has passed validation.
             */
            const check =
              checker.checkRelationships(selectedTypes, possibleTypes);
            /*
             * Only validate type combination when
             * the type or the URL has changed
             * or there's a new relationship.
             */
            const shouldValidateTypeCombination =
              links.some(link => this.isNewOrChangedLink(link));
            if (check.result) {
              /*
               * Now that selected types are valid, if there's only one
               * possible type, then it's a match.
               */
              urlMatchesType = possibleTypes != null &&
                possibleTypes.length === 1;
            } else if (shouldValidateTypeCombination &&
              links[0].submitted &&
              selectedTypes.length > 0 &&
              !hasError) {
              this.errorObservable(true);
              urlError = {
                message: check.error ||
                    l('This relationship type combination is invalid.'),
                target:
                    check.target || URLCleanup.ERROR_TARGETS.RELATIONSHIP,
              };
            }
            const firstLinkIndex = linkIndexes[0];

            return (
              <ExternalLink
                canMerge={canMerge}
                cleanupUrl={(url) => this.cleanupUrl(url)}
                creditableEntityProp={this.creditableEntityProp}
                duplicate={duplicate ? duplicate[0].urlIndex : null}
                error={urlError}
                getRelationshipHighlightType={
                  (link) => this.getRelationshipHighlightType(
                    link, this.creditableEntityProp,
                  )
                }
                handleAttributesChange={
                  (index, attributes) => this.setLinkState(index, attributes)
                }
                handleLinkRemove={(index) => this.removeLink(index)}
                handleLinkSubmit={
                  (event) => this.handleLinkSubmit(
                    firstLinkIndex, index, event, canMerge,
                  )
                }
                handleUrlBlur={
                  (event) => this.handleUrlBlur(
                    firstLinkIndex, duplicate != null, event, index, canMerge,
                  )
                }
                handleUrlChange={
                  (rawUrl) => this.handleUrlChange(linkIndexes, index, rawUrl)
                }
                highlight={this.getURLHighlightType(links)}
                index={index}
                isLastLink={isLastLink}
                isOnlyLink={linksByUrl.length === 1}
                key={index}
                onAddRelationship={(url) => this.addRelationship(url, index)}
                onTypeBlur={
                  (linkIndex, event) => this.handleTypeBlur(
                    linkIndex, event, duplicate != null, index, canMerge,
                  )
                }
                onTypeChange={
                  (index, event) => this.handleTypeChange(index, event)
                }
                onUrlRemove={() => this.removeLinks(linkIndexes, index)}
                onVideoChange={
                  (index, event) => this.handleVideoChange(index, event)
                }
                rawUrl={rawUrl}
                relationships={links}
                typeOptions={typeOptions}
                url={url}
                urlEntity={entity1}
                urlMatchesType={urlMatchesType}
                validateLink={(link) => this.validateLink(link)}
              />
            );
          })}
        </tbody>
      </table>
    );
  }
}

const ExternalLinksEditor:
  component(
    ref: React.RefSetter<_ExternalLinksEditor>,
    ...LinksEditorPropsT
  ) =
    withLoadedTypeInfo<LinksEditorPropsT, _ExternalLinksEditor>(
      _ExternalLinksEditor,
      new Set(['link_type', 'link_attribute_type']),
    );

export default ExternalLinksEditor;

const defaultLinkState: LinkStateT = {
  begin_date: EMPTY_PARTIAL_DATE,
  deleted: false,
  editsPending: false,
  end_date: EMPTY_PARTIAL_DATE,
  ended: false,
  entity0: null,
  entity0_credit: '',
  entity1: null,
  entity1_credit: '',
  pendingTypes: null,
  rawUrl: '',
  relationship: null,
  submitted: false,
  type: null,
  url: '',
  video: false,
};

function newLinkState(state: $ReadOnly<Partial<LinkStateT>>) {
  return {...defaultLinkState, ...state};
}

function linkTypeAndUrlString(link: LinkStateT | LinkRelationshipT) {
  /*
   * There's no reason why we should allow adding the same relationship
   * twice when the only difference is http vs https, so normalize this
   * for the check.
   */
  const httpUrl = link.url.replace(/^https/, 'http');
  return (link.type || '') + '\0' + httpUrl;
}

function isEmpty(link: LinkStateT | LinkRelationshipT | ExternalLinkPropsT) {
  return !(link.type || link.url);
}

function withOneEmptyLink(
  links: $ReadOnlyArray<LinkStateT>,
  dontRemove?: number,
) {
  let emptyCount = 0;
  let canRemoveCount = 0;
  const canRemove: {[index: number]: boolean} = {};

  links.forEach(function (link, index) {
    if (isEmpty(link)) {
      ++emptyCount;
      if (index !== dontRemove) {
        canRemove[index] = true;
        canRemoveCount++;
      }
    }
  });

  if (emptyCount === 0) {
    return links.concat(newLinkState({relationship: uniqueId('new-')}));
  } else if (emptyCount > 1 && canRemoveCount > 0) {
    return links.filter((link, index) => !canRemove[index]);
  }
  return links;
}

const isVideoAttribute =
  (attr: LinkAttrT) => attr.type.gid === VIDEO_ATTRIBUTE_GID;

export function parseRelationships(
  sourceData?:
  | RelatableEntityT
  | {
      +entityType: RelatableEntityTypeT,
      +id?: void,
      +isNewEntity?: true,
      +name?: string,
      +orderingTypeID?: number,
      +relationships?: void,
    },
): Array<LinkStateT> {
  const relationships = sourceData?.relationships;
  if (!relationships) {
    return [];
  }
  return relationships.reduce(function (accum, data) {
    const target = data.target;
    if (target.entityType === 'url') {
      accum.push({
        begin_date: data.begin_date || EMPTY_PARTIAL_DATE,
        deleted: false,
        editsPending: data.editsPending,
        end_date: data.end_date || EMPTY_PARTIAL_DATE,
        ended: data.ended || false,
        entity0: sourceData || null,
        entity0_credit: data.entity0_credit || '',
        entity1: target,
        entity1_credit: data.entity1_credit || '',
        pendingTypes: null,
        rawUrl: target.name,
        relationship: data.id,
        submitted: true,
        type: data.linkTypeID ?? null,
        url: target.name,
        video: data.attributes
          ? data.attributes.some(isVideoAttribute)
          : false,
      });
    }

    return accum;
  }, []);
}

function groupLinksByUrl(
  links: $ReadOnlyArray<LinkStateT>,
): Map<string, Array<LinkRelationshipT>> {
  const map = new Map<string, Array<LinkRelationshipT>>();
  const urlTypePairs = new Set<string>();
  let urlIndex = 0;
  links.forEach((link, index) => {
    const relationship = {
      ...link,
      error: null,
      index,
      urlIndex: index,
    };
    // Don't group links that are duplicates or not submitted
    const urlTypePair = `${link.url}-${link.type ?? ''}`;
    const key = link.submitted && !urlTypePairs.has(urlTypePair)
      ? link.url
      : String(link.relationship);
    const relationships = map.get(key);
    if (relationships) {
      relationship.urlIndex = relationships[0].urlIndex;
      relationships.push(relationship);
    } else {
      relationship.urlIndex = urlIndex++;
      map.set(key, [relationship]);
    }
    urlTypePairs.add(urlTypePair);
  });
  return map;
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

type InitialOptionsT = {
  errorObservable?: (boolean) => void,
  sourceData?:
    | RelatableEntityT
    | {
        +entityType: RelatableEntityTypeT,
        +id?: void,
        +isNewEntity?: true,
        +name?: string,
        +orderingTypeID?: number,
        +relationships?: void,
      },
};

export function createExternalLinksEditor(
  options?: InitialOptionsT,
): {
  +externalLinksEditorRef: {current: _ExternalLinksEditor | null},
  +root: {+unmount: () => void, ...},
} {
  const sourceData = options?.sourceData ??
    getSourceEntityData(getCatalystContext());

  const mountPoint = $('#external-links-editor-container')[0];
  let root = $(mountPoint).data('react-root');
  if (!root) {
    root = ReactDOMClient.createRoot(mountPoint);
    $(mountPoint).data('react-root', root);
  }
  const externalLinksEditorRef = React.createRef<_ExternalLinksEditor>();
  root.render(
    <ExternalLinksEditor
      errorObservable={options?.errorObservable}
      isNewEntity={!sourceData.id}
      ref={externalLinksEditorRef}
      sourceData={sourceData}
    />,
  );
  return {externalLinksEditorRef, root};
}

export function createExternalLinksEditorForHtmlForm(
  formName: string,
): void {
  const {
    externalLinksEditorRef,
  } = createExternalLinksEditor();
  $(document).on('submit', '#page form', function () {
    const externalLinksEditor = externalLinksEditorRef.current;
    /*
     * If externalLinksEditor isn't set, then it's likely that the form was
     * submitted before `withLoadedTypeInfo` finished loading.
     */
    if (externalLinksEditor) {
      prepareExternalLinksHtmlFormSubmission(
        formName,
        externalLinksEditor,
      );
    }
  });
}

function getFormData(
  sourceType: RelatableEntityTypeT,
  editData: {
    allLinks: LinkMapT,
    newLinks: LinkMapT,
    oldLinks: LinkMapT,
  },
  startingPrefix: string,
  startingIndex: number,
  pushInput: (string, string, string) => void,
) {
  let index = 0;
  const backward = sourceType > 'url';
  const {oldLinks, newLinks, allLinks} = editData;

  for (const [relationship, link] of allLinks) {
    if (!link?.type) {
      return;
    }

    const prefix = startingPrefix + '.' + (startingIndex + (index++));

    if (isPositiveInteger(relationship)) {
      pushInput(prefix, 'relationship_id', String(relationship));

      if (!newLinks.has(relationship)) {
        pushInput(prefix, 'removed', '1');
      }
    }

    pushInput(prefix, 'text', link.url);

    if (link.video) {
      pushInput(prefix + '.attributes.0', 'type.gid', VIDEO_ATTRIBUTE_GID);
    } else if (oldLinks.get(relationship)?.video) {
      pushInput(prefix + '.attributes.0', 'type.gid', VIDEO_ATTRIBUTE_GID);
      pushInput(prefix + '.attributes.0', 'removed', '1');
    }

    if (backward) {
      pushInput(prefix, 'backward', '1');
    }

    pushInput(prefix, 'link_type_id', String(link.type) || '');

    if (ENTITIES_WITH_RELATIONSHIP_CREDITS[sourceType]) {
      const creditableEntityProp = backward
        ? 'entity1_credit'
        : 'entity0_credit';
      pushInput(
        prefix,
        creditableEntityProp,
        link[creditableEntityProp] || '',
      );
    }

    const beginDate = link.begin_date || EMPTY_PARTIAL_DATE;
    const endDate = link.end_date || EMPTY_PARTIAL_DATE;

    pushInput(
      prefix,
      'period.begin_date.year',
      beginDate.year ? String(beginDate.year) : '',
    );
    pushInput(
      prefix,
      'period.begin_date.month',
      beginDate.month ? String(beginDate.month) : '',
    );
    pushInput(
      prefix,
      'period.begin_date.day',
      beginDate.day ? String(beginDate.day) : '',
    );
    pushInput(
      prefix,
      'period.end_date.year',
      endDate.year ? String(endDate.year) : '',
    );
    pushInput(
      prefix,
      'period.end_date.month',
      endDate.month ? String(endDate.month) : '',
    );
    pushInput(
      prefix,
      'period.end_date.day',
      endDate.day ? String(endDate.day) : '',
    );
    pushInput(prefix, 'period.ended', link.ended ? '1' : '0');
  }
}

export function prepareExternalLinksHtmlFormSubmission(
  formName: string,
  externalLinksEditor: _ExternalLinksEditor,
): void {
  let hiddenInputsContainer = document.getElementById(
    'external-links-editor-submission',
  );
  if (!hiddenInputsContainer) {
    hiddenInputsContainer = document.createElement('div');
    hiddenInputsContainer.setAttribute(
      'id',
      'external-links-editor-submission',
    );
    document.querySelector('#page form')?.appendChild(
      hiddenInputsContainer,
    );
  }
  appendHiddenRelationshipInputs(
    'external-links-editor-submission',
    function (pushInput) {
      getFormData(
        externalLinksEditor.sourceType,
        externalLinksEditor.getEditData(),
        formName + '.url',
        0,
        pushInput,
      );

      const links = externalLinksEditor.state.links;
      if (links.length) {
        externalLinksEditor.submittedLinksWrapper.set(links);
      }
    },
  );
}
