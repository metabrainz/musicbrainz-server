/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import punycode from 'punycode';

import {captureException} from '@sentry/browser';
import $ from 'jquery';
import ko from 'knockout';
import * as React from 'react';
import * as ReactDOMClient from 'react-dom/client';

import {
  compactEntityJson,
  decompactEntityJson,
} from '../../../utility/compactEntityJson.js';
import invariant from '../../../utility/invariant.js';
import {
  EMPTY_PARTIAL_DATE,
  ENTITIES_WITH_RELATIONSHIP_CREDITS,
  FAVICON_CLASSES,
  VIDEO_ATTRIBUTE_GID,
  VIDEO_ATTRIBUTE_ID,
} from '../common/constants.js';
import {compare, l} from '../common/i18n.js';
import expand2react from '../common/i18n/expand2react.js';
import linkedEntities from '../common/linkedEntities.mjs';
import MB from '../common/MB.js';
import {groupBy, keyBy, uniqBy} from '../common/utility/arrays.js';
import {bracketedText} from '../common/utility/bracketed.js';
import {
  getCatalystContext,
  getSourceEntityData,
} from '../common/utility/catalyst.js';
import {compareDatePeriods} from '../common/utility/compareDates.js';
import formatDatePeriod from '../common/utility/formatDatePeriod.js';
import isDateEmpty from '../common/utility/isDateEmpty.js';
import {hasSessionStorage} from '../common/utility/storage.js';
import {uniqueId} from '../common/utility/strings.js';
import {stripAttributes} from '../edit/utility/linkPhrase.js';
import {
  appendHiddenRelationshipInputs,
} from '../relationship-editor/utility/prepareHtmlFormSubmission.js';
import {isMalware} from '../url/utility/isGreyedOut.js';

import EntityPendingEditsWarning
  from './components/EntityPendingEditsWarning.js';
import ExternalLinkAttributeDialog
  from './components/ExternalLinkAttributeDialog.js';
import HelpIcon from './components/HelpIcon.js';
import RelationshipPendingEditsWarning
  from './components/RelationshipPendingEditsWarning.js';
import RemoveButton from './components/RemoveButton.js';
import URLInputPopover from './components/URLInputPopover.js';
import withLoadedTypeInfo from './components/withLoadedTypeInfo.js';
import isPositiveInteger from './utility/isPositiveInteger.js';
import isShortenedUrl from './utility/isShortenedUrl.js';
import {linkTypeOptions} from './forms.js';
import type {RelationshipTypeT} from './URLCleanup.js';
import * as URLCleanup from './URLCleanup.js';
import * as validation from './validation.js';

type ErrorTarget = $Values<typeof URLCleanup.ERROR_TARGETS>;

const HIGHLIGHTS = {
  ADD: 'rel-add',
  EDIT: 'rel-edit',
  NONE: '',
  REMOVE: 'rel-remove',
};

type HighlightT = $Values<typeof HIGHLIGHTS>;

export type ErrorT = {
  blockMerge?: boolean,
  message: React$Node,
  target: ErrorTarget,
};

type LinkTypeOptionT = {
  data: LinkTypeT,
  disabled?: boolean,
  text: string,
  value: number,
};

export type LinkStateT = $ReadOnly<{
  ...DatePeriodRoleT,
  +deleted: boolean,
  +editsPending: boolean,
  +entity0:
    | RelatableEntityT
    | {
        +entityType: RelatableEntityTypeT,
        +id?: void,
        +isNewEntity?: true,
        +name?: string,
        +orderingTypeID?: number,
        +relationships?: void,
      }
    | null,
  +entity0_credit: string,
  +entity1: RelatableEntityT | null,
  +entity1_credit: string,
  +pendingTypes: $ReadOnlyArray<number> | null,
  +rawUrl: string,
  // New relationships will use a unique string ID like "new-1".
  +relationship: StrOrNum | null,
  +submitted: boolean,
  +type: number | null,
  +url: string,
  +video: boolean,
}>;

type LinkMapT = Map<string, LinkStateT>;

export type LinkRelationshipT = $ReadOnly<{
  ...LinkStateT,
  +error: ErrorT | null,
  +index: number,
  +urlIndex: number,
}>;

type LinksEditorProps = {
  +errorObservable?: (boolean) => void,
  +isNewEntity: boolean,
  +sourceData:
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

type LinksEditorState = {
  +links: $ReadOnlyArray<LinkStateT>,
};

export class _ExternalLinksEditor
  extends React.Component<LinksEditorProps, LinksEditorState> {
  creditableEntityProp: 'entity0_credit' | 'entity1_credit' | null;

  tableRef: {current: HTMLTableElement | null};

  generalLinkTypes: $ReadOnlyArray<LinkTypeOptionT>;

  oldLinks: LinkMapT;

  +errorObservable: (boolean) => void;

  +initialLinks: $ReadOnlyArray<LinkStateT>;

  +sourceType: RelatableEntityTypeT;

  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>;

  constructor(props: LinksEditorProps) {
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
        if (hasSessionStorage) {
          const submittedLinks =
            window.sessionStorage.getItem('submittedLinks');
          if (submittedLinks) {
            initialLinks = ((
              decompactEntityJson(JSON.parse(submittedLinks))
            ): any).filter(l => !isEmpty(l)).map(newLinkState);
            window.sessionStorage.removeItem('submittedLinks');
          }
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
        const urls: {[index: string]: SeededUrlShape} = {};
        let match;

        while ((match = seededLinkRegex.exec(window.location.search))) {
          const [/* unused */, index, key, value] = match;
          switch (key) {
            case 'link_type_id':
            case 'text':
              (urls[index] = urls[index] || {})[key] =
                decodeURIComponent(value);
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

    initialLinks = initialLinks.map(function (link) {
      /*
       * Only run the URL cleanup on seeded URLs, i.e. URLs that don't have an
       * existing relationship ID.
       */
      if (!isPositiveInteger(link.relationship)) {
        const url = getUnicodeUrl(link.url);
        return {
          ...link,
          relationship: uniqueId('new-'),
          url: URLCleanup.cleanURL(url) || url,
        };
      }
      return link;
    });

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
      // $FlowIgnore[prop-missing]
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
        const possibleTypes = checker.getPossibleTypes();
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
         * $FlowIssue[incompatible-type]: relatedTarget is EventTarget
         * Don't merge when user clicks on delete icon,
         * otherwise UI change will prevent the deletion.
         */
        const relatedTarget: HTMLElement = event.relatedTarget;
        const clickingDeleteIcon =
        relatedTarget && relatedTarget.dataset.index === urlIndex.toString();
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
    const type = +event.currentTarget.value || null;
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
     * $FlowIssue[incompatible-type]: relatedTarget is EventTarget
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
      newLinks: newLinks,
      oldLinks: oldLinks,
    };
  }

  getFormData(
    startingPrefix: string,
    startingIndex: number,
    pushInput: (string, string, string) => void,
  ) {
    let index = 0;
    const backward = this.sourceType > 'url';
    const {oldLinks, newLinks, allLinks} = this.getEditData();

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

      if (this.creditableEntityProp) {
        pushInput(
          prefix,
          this.creditableEntityProp,
          link[this.creditableEntityProp] || '',
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
    checker = checker ||
      new URLCleanup.Checker(link.url, this.sourceType);
    const oldLink = this.oldLinks.get(String(link.relationship));
    const isNewLink = !isPositiveInteger(link.relationship);
    const linkChanged = oldLink && link.url !== oldLink.url;
    const isNewOrChangedLink = (isNewLink || linkChanged);
    const linkTypeChanged = oldLink && +link.type !== +oldLink.type;

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
        error.message = check.error || error.message;
      }
    }
    return error;
  }

  filterTypeOptions(
    possibleTypes: $ReadOnlyArray<RelationshipTypeT> | false,
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
    const linkTypeChanged = oldLink && +link.type !== +oldLink.type;
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
      +link.type !== +oldLink.type;

    return Boolean(linkChanged || linkTypeChanged);
  }

  render(): React$Element<'table'> {
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
            const possibleTypes = checker.getPossibleTypes();
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
                  // $FlowIgnore[cannot-write]
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
            let urlMatchesType = !!links[0].pendingTypes;
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
              urlMatchesType = possibleTypes && possibleTypes.length === 1;
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
                    firstLinkIndex, !!duplicate, event, index, canMerge,
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
                    linkIndex, event, !!duplicate, index, canMerge,
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

type LinkTypeSelectPropsT = {
  +handleTypeBlur:
    (SyntheticFocusEvent<HTMLSelectElement>) => void,
  +handleTypeChange:
    (SyntheticEvent<HTMLSelectElement>) => void,
  +options: Array<LinkTypeOptionT>,
  +type: number | null,
};

const LinkTypeSelect = ({
  handleTypeBlur,
  handleTypeChange,
  options,
  type,
}: LinkTypeSelectPropsT): React$Element<'select'> => {
  const optionAvailable = options.some(option => option.value === type);
  // If the selected type is not available, display it as placeholder
  const linkType = type ? linkedEntities.link_type[type] : null;
  const placeholder = (optionAvailable || !linkType)
    ? '\xA0'
    : l_relationships(
      linkType.link_phrase,
    );

  return (
    <select
      // If the selected type is not available, display an error indicator
      className={optionAvailable || !type ? 'link-type' : 'link-type error'}
      onBlur={handleTypeBlur}
      onChange={handleTypeChange}
      value={type || ''}
    >
      <option value="">{placeholder}</option>
      {options.map(option => (
        <option
          disabled={option.disabled}
          key={option.value}
          value={option.value}
        >
          {option.text}
        </option>
      ))}
    </select>
  );
};

type TypeDescriptionProps = {
  +type: number | null,
  +url: string,
};

const TypeDescription =
  (props: TypeDescriptionProps): React$Element<typeof HelpIcon> => {
    const linkType = props.type ? linkedEntities.link_type[props.type] : null;
    let typeDescription: Expand2ReactOutput = '';

    if (linkType && linkType.description) {
      typeDescription = exp.l('{description} ({url|more documentation})', {
        description: expand2react(l_relationships(linkType.description)),
        url: '/relationship/' + linkType.gid,
      });
    }

    return (
      <HelpIcon
        content={
          <div style={{textAlign: 'left'}}>{typeDescription}</div>
        }
      />
    );
  };

type ExternalLinkRelationshipProps = {
  +creditableEntityProp: 'entity0_credit' | 'entity1_credit' | null,
  +hasUrlError: boolean,
  +highlight: HighlightT,
  +isOnlyRelationship: boolean,
  +link: LinkRelationshipT,
  +onAttributesChange: (number, $ReadOnly<Partial<LinkStateT>>) => void,
  +onLinkRemove: (number) => void,
  +onTypeBlur: (number, SyntheticFocusEvent<HTMLSelectElement>) => void,
  +onTypeChange: (number, SyntheticEvent<HTMLSelectElement>) => void,
  +onVideoChange: (number, SyntheticEvent<HTMLInputElement>) => void,
  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>,
  +urlMatchesType: boolean,
};

const ExternalLinkRelationship =
  (props: ExternalLinkRelationshipProps): React$Element<'tr'> => {
    const {
      creditableEntityProp,
      link,
      hasUrlError,
      highlight,
      urlMatchesType,
    } = props;
    const linkType = link.type ? linkedEntities.link_type[link.type] : null;
    const backward = linkType && linkType.type1 > 'url';
    const hasDate = !isDateEmpty(link.begin_date) ||
                    !isDateEmpty(link.end_date) ||
                    link.ended;

    const showTypeSelection = (link.error || hasUrlError)
      ? true
      : !(urlMatchesType || isEmpty(link));

    const creditedName = creditableEntityProp
      ? link[creditableEntityProp]
      : null;

    return (
      <tr className="relationship-item" key={link.relationship}>
        <td />
        <td className="link-actions">
          {!props.isOnlyRelationship && !props.urlMatchesType ? (
            <RemoveButton
              onClick={() => props.onLinkRemove(link.index)}
              title={lp('Remove relationship', 'interactive')}
            />
          ) : null}
          <ExternalLinkAttributeDialog
            creditableEntityProp={creditableEntityProp}
            onConfirm={
              (attributes) => props.onAttributesChange(link.index, attributes)
            }
            relationship={link}
          />
        </td>
        <td>
          <div className={`relationship-content ${highlight}`}>
            <label>{addColonText(l('Type'))}</label>
            <label className="relationship-name">
              {/* If the URL matches its type or is just empty,
                  display either a favicon
                  or a prompt for a new link as appropriate. */
                showTypeSelection
                  ? (
                    <LinkTypeSelect
                      handleTypeBlur={
                        (event) => props.onTypeBlur(link.index, event)
                      }
                      handleTypeChange={
                        (event) => props.onTypeChange(link.index, event)
                      }
                      options={
                        props.typeOptions.reduce((options, option, index) => {
                          const nextOption = props.typeOptions[index + 1];
                          if (!option.disabled ||
                          /*
                           * Ignore empty groups by checking
                           * if the next option is an item in current group,
                           * if not, then it's an empty group.
                           */
                          (nextOption &&
                            nextOption.data.parent_id === option.value)) {
                            options.push(option);
                          }
                          return options;
                        }, [])}
                      type={link.type}
                    />
                  ) : (
                    linkType ? (
                      backward ? (
                        stripAttributes(
                          linkType,
                          linkType.l_reverse_link_phrase ?? '',
                        )
                      ) : (
                        stripAttributes(
                          linkType,
                          linkType.l_link_phrase ?? '',
                        )
                      )
                    ) : null
                  )
              }
              {link.url && !link.error && !hasUrlError
                ? <TypeDescription type={link.type} url={link.url} />
                : null}
              <RelationshipPendingEditsWarning relationship={link} />
              {hasDate ? (
                <span className="date-period">
                  {' '}
                  {bracketedText(formatDatePeriod(link))}
                </span>
              ) : null}
              {nonEmpty(creditedName) ? (
                <span className="entity-credit">
                  {' '}
                  {bracketedText(texp.lp(
                    'credited as “{credit}”',
                    'relationship credit',
                    {credit: creditedName},
                  ))}
                </span>
              ) : null}
            </label>
          </div>
          {linkType &&
            hasOwnProp(
              linkType.attributes,
              String(VIDEO_ATTRIBUTE_ID),
            ) ? (
              <div className="attribute-container">
                <label>
                  <input
                    checked={link.video}
                    onChange={
                      (event) => props.onVideoChange(link.index, event)
                    }
                    style={{verticalAlign: 'text-top'}}
                    type="checkbox"
                  />
                  {' '}
                  {l('video')}
                </label>
              </div>
            ) : null}
          {link.error ? (
            <div className="error field-error" data-visible="1">
              {link.error.message}
            </div>
          ) : null}
        </td>
      </tr>
    );
  };

type CreditableEntityOptionsT = 'entity0_credit' | 'entity1_credit' | null;

type LinkProps = {
  +canMerge: boolean,
  +cleanupUrl: (string) => string,
  +creditableEntityProp: CreditableEntityOptionsT,
  +duplicate: number | null,
  +error: ErrorT | null,
  +getRelationshipHighlightType: (
    LinkRelationshipT,
    CreditableEntityOptionsT
  ) => HighlightT,
  +handleAttributesChange: (number, $ReadOnly<Partial<LinkStateT>>) => void,
  +handleLinkRemove: (number) => void,
  +handleLinkSubmit: (SyntheticKeyboardEvent<HTMLInputElement>) => void,
  +handleUrlBlur: (SyntheticFocusEvent<HTMLInputElement>) => void,
  +handleUrlChange: (string) => void,
  +highlight: HighlightT,
  +index: number,
  +isLastLink: boolean,
  +isOnlyLink: boolean,
  +onAddRelationship: (string) => void,
  +onTypeBlur: (number, SyntheticFocusEvent<HTMLSelectElement>) => void,
  +onTypeChange: (number, SyntheticEvent<HTMLSelectElement>) => void,
  +onUrlRemove: () => void,
  +onVideoChange:
    (number, SyntheticEvent<HTMLInputElement>) => void,
  +rawUrl: string,
  +relationships: $ReadOnlyArray<LinkRelationshipT>,
  +typeOptions: $ReadOnlyArray<LinkTypeOptionT>,
  +url: string,
  +urlEntity: RelatableEntityT | null,
  +urlMatchesType: boolean,
  +validateLink: (LinkRelationshipT | LinkStateT) => ErrorT | null,
};

export class ExternalLink extends React.Component<LinkProps> {
  handleKeyDown(event: SyntheticKeyboardEvent<HTMLInputElement>) {
    if (event.key === 'Enter' && this.props.url) {
      /*
       * If there's a link, prevent default and submit it,
       * otherwise allow submitting the form from empty field.
       */
      event.preventDefault();
      this.props.handleLinkSubmit(event);
    }
  }

  highlightDuplicate(index: number | null) {
    if (index === null) {
      return;
    }
    const target = document.getElementById(`external-link-${index}`);
    if (!target) {
      return;
    }
    target.scrollIntoView();
    target.style.backgroundColor = 'yellow';
    setTimeout(() => target.style.backgroundColor = 'initial', 1000);
  }

  render(): React.MixedElement {
    const props = this.props;
    const notEmpty = props.relationships.some(link => {
      return !isEmpty(link);
    });
    const firstLink = props.relationships[0];

    let faviconClass: string | void;
    for (const key of Object.keys(FAVICON_CLASSES)) {
      if (props.url.indexOf(key) > 0) {
        faviconClass = FAVICON_CLASSES[key];
        break;
      }
    }
    if (notEmpty && !faviconClass) {
      const isHomepage = props.relationships.some(link => {
        const linkType = link.type
          ? linkedEntities.link_type[link.type]
          : null;
        if (linkType) {
          return /^official (?:homepage|site)$/.test(linkType.name);
        }
        return false;
      });
      if (isHomepage) {
        faviconClass = 'home';
      } else {
        const isBlog = props.relationships.some(link => {
          const linkType = link.type
            ? linkedEntities.link_type[link.type]
            : null;
          if (linkType) {
            return /^blog$/.test(linkType.name);
          }
          return false;
        });
        if (isBlog) {
          faviconClass = 'blog';
        } else {
          faviconClass = 'no';
        }
      }
    }

    return (
      <React.Fragment>
        <tr
          className="external-link-item"
          id={`external-link-${props.index}`}
        >
          <td>
            {faviconClass ? (
              <span
                className={'favicon ' + faviconClass + '-favicon'}
              />
            ) : null}
          </td>
          <td className="link-actions">
            {notEmpty ? (
              <RemoveButton
                dataIndex={props.index}
                onClick={() => props.onUrlRemove()}
                title={l('Remove link')}
              />
            ) : null}
            {isEmpty(props) ? null : (
              <URLInputPopover
                cleanupUrl={props.cleanupUrl}
                /*
                 * Randomly choose a link because relationship errors
                 * are not displayed, thus link type doesn't matter.
                 */
                link={firstLink}
                onConfirm={props.handleUrlChange}
                validateLink={props.validateLink}
              />
            )}
          </td>
          <td>
            {/* Links that are not submitted will not be grouped,
              * so it's safe to check the first link only.
              */}
            {(!firstLink.submitted || !props.url) ? (
              <input
                className="value with-button"
                data-index={props.index}
                onBlur={props.handleUrlBlur}
                onChange={(event) => {
                  props.handleUrlChange(event.currentTarget.value);
                }}
                onKeyDown={(event) => this.handleKeyDown(event)}
                placeholder={props.isOnlyLink
                  ? l('Add link')
                  : (
                    props.isLastLink
                      ? l('Add another link')
                      : ''
                  )}
                type="url"
                // Don't interrupt user input with clean URL
                value={props.rawUrl}
              />
            ) : (
              <a
                className={`url ${props.highlight}`}
                href={props.url}
                rel="noreferrer"
                style={{overflowWrap: 'anywhere'}}
                target="_blank"
              >
                {props.url}
              </a>
            )}
            {props.urlEntity ? (
              <EntityPendingEditsWarning entity={props.urlEntity} />
            ) : null}
            {props.url && props.duplicate !== null ? (
              <div
                className="error field-error"
                data-visible="1"
              >
                {exp.l(
                  props.canMerge
                    ? `Note: This link already exists 
                       at position {position}. 
                       To merge, press enter or select a type.`
                    : `Note: This link already exists 
                       at position {position}.`,
                  {
                    position: (
                      <a
                        href={`#external-link-${props.duplicate}`}
                        onClick={
                          () => this.highlightDuplicate(props.duplicate)
                        }
                      >
                        {`#${props.duplicate + 1}`}
                      </a>
                    ),
                  },
                )}
              </div>
            ) : null}
            {props.error ? (
              <div
                className={`error field-error target-${props.error.target}`}
                data-visible="1"
              >
                {props.error.message}
              </div>
            ) : null}
          </td>
        </tr>
        {notEmpty &&
          props.relationships.map((link, index) => (
            <ExternalLinkRelationship
              creditableEntityProp={props.creditableEntityProp}
              hasUrlError={props.error != null}
              highlight={props.getRelationshipHighlightType(
                link,
                props.creditableEntityProp,
              )}
              isOnlyRelationship={props.relationships.length === 1}
              key={index}
              link={link}
              onAttributesChange={props.handleAttributesChange}
              onLinkRemove={props.handleLinkRemove}
              onTypeBlur={props.onTypeBlur}
              onTypeChange={props.onTypeChange}
              onVideoChange={props.onVideoChange}
              typeOptions={props.typeOptions}
              urlMatchesType={props.urlMatchesType}
            />
        ))}
        {firstLink.pendingTypes &&
          firstLink.pendingTypes.map((type) => {
            const relType = linkedEntities.link_type[type];
            return (
              <tr className="relationship-item" key={type}>
                <td />
                <td>
                  <div className="relationship-content">
                    <label>{addColonText(l('Type'))}</label>
                    <label className="relationship-name">
                      {stripAttributes(
                        relType,
                        relType.l_link_phrase ?? '',
                      )}
                    </label>
                  </div>
                </td>
              </tr>
            );
          })}
        {/*
          * Hide the button when link is not submitted
          * or link type is auto-selected.
          */}
        {notEmpty && firstLink.submitted && !props.urlMatchesType ? (
          <tr className="add-relationship">
            <td />
            <td />
            <td className="add-item">
              <button
                className="add-item with-label"
                onClick={() => props.onAddRelationship(props.url)}
                type="button"
              >
                {l('Add another relationship')}
              </button>
            </td>
          </tr>
        ) : null}
      </React.Fragment>
    );
  }
}

export const ExternalLinksEditor:
  React$AbstractComponent<LinksEditorProps, _ExternalLinksEditor> =
  withLoadedTypeInfo<LinksEditorProps, _ExternalLinksEditor>(
    _ExternalLinksEditor,
    new Set(['link_type', 'link_attribute_type']),
  );

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

function isEmpty(link: LinkStateT | LinkRelationshipT | LinkProps) {
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

const protocolRegex = /^(https?|ftp):$/;
const hostnameRegex = /^(([A-z\d]|[A-z\d][A-z\d\-]*[A-z\d])\.)*([A-z\d]|[A-z\d][A-z\d\-]*[A-z\d])$/;

export function getUnicodeUrl(url: string): string {
  if (!isValidURL(url)) {
    return url;
  }

  const urlObject = new URL(url);
  const unicodeHostname = punycode.toUnicode(urlObject.hostname);
  const unicodeUrl = url.replace(urlObject.hostname, unicodeHostname);

  return unicodeUrl;
}

function isValidURL(url: string) {
  const a = document.createElement('a');
  a.href = url;

  const hostname = a.hostname;

  // To compare with the url we need to decode the Punycode if present
  const unicodeHostname = punycode.toUnicode(hostname);
  if (url.indexOf(hostname) < 0 && url.indexOf(unicodeHostname) < 0) {
    return false;
  }

  if (!hostnameRegex.test(hostname)) {
    return false;
  }

  if (hostname.indexOf('.') < 0) {
    return false;
  }

  /*
   * Check if protocol string is in URL and is valid
   * Protocol of URL like "//google.com" is inferred as "https:"
   * but the URL is invalid
   */
  if (!url.startsWith(a.protocol) || !protocolRegex.test(a.protocol)) {
    return false;
  }

  return true;
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

type SeededUrlShape = {
  link_type_id?: string,
  text?: string,
};

export function createExternalLinksEditor(
  options?: InitialOptionsT,
): {
  +externalLinksEditorRef: {current: _ExternalLinksEditor | null},
  +root: {+unmount: () => void, ...},
} {
  const sourceData = options?.sourceData ?? getSourceEntityData();
  invariant(sourceData);

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
      externalLinksEditor.getFormData(formName + '.url', 0, pushInput);

      const links = externalLinksEditor.state.links;
      if (hasSessionStorage && links.length) {
        try {
          window.sessionStorage.setItem(
            'submittedLinks',
            JSON.stringify(compactEntityJson(links)),
          );
        } catch (error) {
          captureException(error);
        }
      }
    },
  );
}
