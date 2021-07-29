/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import punycode from 'punycode';

import $ from 'jquery';
import ko from 'knockout';
import * as React from 'react';
import * as ReactDOM from 'react-dom';

import {
  FAVICON_CLASSES,
  VIDEO_ATTRIBUTE_ID,
  VIDEO_ATTRIBUTE_GID,
} from '../common/constants';
import {compare} from '../common/i18n';
import expand2react from '../common/i18n/expand2react';
import linkedEntities from '../common/linkedEntities';
import MB from '../common/MB';
import {groupBy, keyBy, uniqBy} from '../common/utility/arrays';
import {hasSessionStorage} from '../common/utility/storage';
import {uniqueId} from '../common/utility/strings';
import {isMalware} from '../../../url/utility/isGreyedOut';

import isPositiveInteger from './utility/isPositiveInteger';
import HelpIcon from './components/HelpIcon';
import RemoveButton from './components/RemoveButton';
import URLInputPopover from './components/URLInputPopover';
import {linkTypeOptions} from './forms';
import * as URLCleanup from './URLCleanup';
import validation from './validation';

type ErrorTarget = $Values<typeof URLCleanup.ERROR_TARGETS>;

type ErrorT = {
  message: React.Node,
  target: ErrorTarget,
};

type LinkStateT = {
  rawUrl: string,
  // New relationships will use a unique string ID like "new-1".
  relationship: StrOrNum | null,
  type: number | null,
  url: string,
  video: boolean,
  ...
};

type LinkMapT = Map<string, LinkStateT>;

type LinkRelationshipT = {
  error: ErrorT | null,
  index: number,
  rawUrl: string,
  relationship: number | string | null,
  type: number | null,
  url: string,
  urlMatchesType?: boolean,
  video: boolean,
  ...
};

type LinksEditorProps = {
  errorObservable: (boolean) => void,
  initialLinks: Array<LinkStateT>,
  sourceType: string,
  typeOptions: Array<React.Element<'option'>>,
};

type LinksEditorState = {
  links: Array<LinkStateT>,
};

export class ExternalLinksEditor
  extends React.Component<LinksEditorProps, LinksEditorState> {
  tableRef: {current: HTMLTableElement | null};

  constructor(props: LinksEditorProps) {
    super(props);
    this.state = {links: withOneEmptyLink(props.initialLinks)};
    this.tableRef = React.createRef();
  }

  setLinkState(
    index: number,
    state: $Shape<LinkStateT>,
    callback?: () => void,
  ) {
    const newLinks: Array<LinkStateT> = this.state.links.concat();
    newLinks[index] = Object.assign({}, newLinks[index], state);
    this.setState({links: newLinks}, callback);
  }

  handleCancelEdit(links: Array<LinkRelationshipT>) {
    const newLinks: Array<LinkStateT> = this.state.links.concat();
    links.forEach((link) => {
      const {index, type, url, rawUrl} = link;
      newLinks[index] = Object.assign({}, newLinks[index], {
        rawUrl,
        url,
        type,
      });
    });
    this.setState({links: newLinks});
  }

  appendEmptyLink() {
    this.setState({
      links: this.state.links.concat(
        newLinkState({relationship: uniqueId('new-')}),
      ),
    });
  }

  handleUrlChange(
    linkIndexes: Array<number>,
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    const rawUrl = event.currentTarget.value;
    let url = rawUrl;

    this.setState(prevState => {
      let newLinks = [...prevState.links];
      linkIndexes.forEach(index => {
        const link = newLinks[index];

        // Allow adding spaces while typing, they'll be trimmed on blur
        if (url.trim() !== link.url.trim()) {
          if (url.match(/^\w+\./)) {
            url = 'http://' + url;
          }
          url = URLCleanup.cleanURL(url) || url;
        }

        let newLink = Object.assign({}, newLinks[index], {url, rawUrl});
        if (!link.type) {
          const type = URLCleanup.guessType(this.props.sourceType, url);

          if (type) {
            newLink.type = linkedEntities.link_type[type].id;
          }
        }
        newLinks[index] = newLink;
      });
      return {links: newLinks};
    });
  }

  handleUrlBlur(
    index: number,
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    const url = event.currentTarget.value;
    const trimmed = url.trim();
    const unicodeUrl = getUnicodeUrl(trimmed);

    if (url !== unicodeUrl) {
      this.setLinkState(index, {url: unicodeUrl});
    }
    // Don't add link to list if it's empty
    if (url !== '') {
      this.appendEmptyLink();
    }
  }

  handlePressEnter(event: SyntheticKeyboardEvent<HTMLInputElement>) {
    const url = event.currentTarget.value;
    // Don't add link to list if it's empty
    if (url !== '') {
      this.appendEmptyLink();
    }
  }

  handleTypeChange(index: number, event: SyntheticEvent<HTMLSelectElement>) {
    const type = +event.currentTarget.value || null;
    this.setLinkState(index, {type}, () => {
      const link = this.state.links[index];
      const isLastLink = index === this.state.links.length - 1;
      if (isLastLink && link.url && type) {
        this.appendEmptyLink();
      }
    });
  }

  handleVideoChange(index: number, event: SyntheticEvent<HTMLInputElement>) {
    this.setLinkState(index, {video: event.currentTarget.checked});
  }

  removeLink(index: number) {
    this.setState(prevState => {
      const newLinks = prevState.links.concat();
      newLinks.splice(index, 1);
      return {links: newLinks};
    }, () => {
      $(this.tableRef.current)
        .find('tr:gt(' + (index - 1) + ') button.remove:first, ' +
              'tr:lt(' + (index + 1) + ') button.remove:last')
        .eq(0)
        .focus();
    });
  }

  removeLinks(indexes: Array<number>) {
    this.setState(prevState => {
      const newLinks = [...prevState.links];
      // Iterate from the end to avoid messing up indexes
      for (let i = indexes.length - 1; i >= 0; --i) {
        newLinks.splice(indexes[i], 1);
      }
      return {links: withOneEmptyLink(newLinks, -1)};
    });
  }

  addRelationship(url: string) {
    this.setState(prevState => {
      const links = [...prevState.links];
      const linkCount = links.length;
      const lastLink = links[linkCount - 1];
      /*
       * If the last (latest-added) link is empty, then use it
       * to maintain the order that the empty link should be at the end.
       */
      if (lastLink.url === '') {
        links[linkCount - 1] = Object.assign(
          {}, lastLink, {url},
        );
        return {links: withOneEmptyLink(links)};
      }
      // Otherwise create a new link with the given URL
      const newRelationship = newLinkState({
        url, relationship: uniqueId('new-'),
      });
      return {links: prevState.links.concat([newRelationship])};
    });
  }

  getOldLinksHash(): LinkMapT {
    return keyBy<LinkStateT, string>(
      this.props.initialLinks
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
      this.state.links,
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
    const backward = this.props.sourceType > 'url';
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
    }
  }

  render(): React.Element<'table'> {
    this.props.errorObservable(false);

    const oldLinks = this.getOldLinksHash();
    const linksArray = this.state.links;
    const linksByUrl = Array.from(groupLinksByUrl(linksArray));
    const linksByTypeAndUrl = groupBy(
      uniqBy(
        linksArray.concat(this.props.initialLinks),
        link => link.relationship,
      ),
      linkTypeAndUrlString,
    );

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
             * when the URL is empty.
             */
            const {url, rawUrl} = relationships[0];
            const isLastLink = index === linksByUrl.length - 1;
            let links = [...relationships];
            const linkIndexes = links.map(link => link.index);
            let urlError = null;
            links.forEach(link => {
              let error = null;

              const linkType = link.type
                ? linkedEntities.link_type[link.type] : {};
              const checker = URLCleanup.validationRules[linkType.gid];
              const oldLink = oldLinks[link.relationship];
              const isNewLink = !isPositiveInteger(link.relationship);
              const linkChanged = oldLink && link.url !== oldLink.url;
              const isNewOrChangedLink = (isNewLink || linkChanged);
              const linkTypeChanged = oldLink && +link.type !== +oldLink.type;
              link.url = getUnicodeUrl(link.url);

              if (isEmpty(link)) {
                error = null;
              } else if (!link.url) {
                error = {
                  message: l('Required field.'),
                  target: URLCleanup.ERROR_TARGETS.URL,
                };
              } else if (isNewOrChangedLink && !isValidURL(link.url)) {
                error = {
                  message: l('Enter a valid url e.g. "http://google.com/"'),
                  target: URLCleanup.ERROR_TARGETS.URL,
                };
              } else if (isNewOrChangedLink && isMusicBrainz(link.url)) {
                error = {
                  message: l(`Links to MusicBrainz URLs are not allowed.
                          Did you mean to paste something else?`),
                  target: URLCleanup.ERROR_TARGETS.URL,
                };
              } else if (isNewOrChangedLink && isMalware(link.url)) {
                error = {
                  message: l(`Links to this website are not allowed
                          because it is known to host malware.`),
                  target: URLCleanup.ERROR_TARGETS.URL,
                };
              } else if (isNewOrChangedLink && isShortened(link.url)) {
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
              } else if (!link.type) {
                error = {
                  message: l(`Please select a link type for the URL
                          you’ve entered.`),
                  target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
                };
              } else if (
                linkType.deprecated && (isNewLink || linkTypeChanged)
              ) {
                error = {
                  message: l(`This relationship type is deprecated 
                          and should not be used.`),
                  target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
                };
              } else if (
                (linksByTypeAndUrl[linkTypeAndUrlString(link)] ||
                  []).length > 1
              ) {
                error = {
                  message: l('This relationship already exists.'),
                  target: URLCleanup.ERROR_TARGETS.RELATIONSHIP,
                };
              } else if (isNewOrChangedLink && checker) {
                const check = checker(link.url);
                if (!check.result) {
                  error = {
                    message: '',
                    target: URLCleanup.ERROR_TARGETS.NONE,
                  };
                  error.target = check.target ||
                    URLCleanup.ERROR_TARGETS.NONE;
                  if (error.target === URLCleanup.ERROR_TARGETS.URL) {
                    error.message = l(
                      `This URL is not allowed for the selected link type,
                      or is incorrectly formatted.`,
                    );
                  }
                  if (error.target ===
                    URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
                    error.message = l(`This URL is not allowed 
                              for the selected link type.`);
                  }
                  error.message = check.error || error.message;
                }
              }

              if (error) {
                this.props.errorObservable(true);
                if (error.target === URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
                  link.error = error;
                } else {
                  urlError = error;
                }
              }

              link.urlMatchesType = linkType.gid === URLCleanup.guessType(
                this.props.sourceType, url,
              );
            });

            return (
              <ExternalLink
                error={urlError}
                handleLinkRemove={(index) => this.removeLink(index)}
                handlePressEnter={
                  (event) => this.handlePressEnter(event)
                }
                handleUrlBlur={
                  (event) => this.handleUrlBlur(index, event)
                }
                handleUrlChange={
                  (event) => this.handleUrlChange(linkIndexes, event)
                }
                index={index}
                isLastLink={isLastLink}
                isOnlyLink={linksByUrl.length === 1}
                key={index}
                onAddRelationship={(url) => this.addRelationship(url)}
                onCancelEdit={
                  (links) => this.handleCancelEdit(links)
                }
                onTypeChange={
                  (index, event) => this.handleTypeChange(index, event)
                }
                onUrlRemove={() => this.removeLinks(linkIndexes)}
                onVideoChange={this.handleVideoChange}
                rawUrl={rawUrl}
                relationships={links}
                typeOptions={this.props.typeOptions}
                url={url}
              />
            );
          })}
        </tbody>
      </table>
    );
  }
}

type LinkTypeSelectProps = {
  children: Array<React.Element<'option'>>,
  handleTypeChange:
    (SyntheticEvent<HTMLSelectElement>) => void,
  type: number | null,
};

class LinkTypeSelect extends React.Component<LinkTypeSelectProps> {
  render() {
    return (
      <select
        className="link-type"
        onChange={this.props.handleTypeChange}
        value={this.props.type || ''}
      >
        <option value="">{'\xA0'}</option>
        {this.props.children}
      </select>
    );
  }
}

type TypeDescriptionProps = {
  type: number | null,
  url: string,
};

const TypeDescription =
  (props: TypeDescriptionProps): React.Element<typeof HelpIcon> => {
    const linkType = props.type ? linkedEntities.link_type[props.type] : null;
    let typeDescription = '';

    if (linkType && linkType.description) {
      typeDescription = exp.l('{description} ({url|more documentation})', {
        description: expand2react(l_relationships(linkType.description)),
        url: '/relationship/' + linkType.gid,
      });
    }

    return <HelpIcon content={typeDescription} />;
  };

type ExternalLinkRelationshipProps = {
  hasUrlError: boolean,
  isOnlyRelationship: boolean,
  link: LinkRelationshipT,
  onLinkRemove: (number) => void,
  onTypeChange: (number, SyntheticEvent<HTMLSelectElement>) => void,
  onVideoChange:
  (number, SyntheticEvent<HTMLInputElement>) => void,
  typeOptions: Array<React.Element<'option'>>,
};

const ExternalLinkRelationship =
  (props: ExternalLinkRelationshipProps): React.Element<'tr'> => {
    const {link, hasUrlError} = props;
    const linkType = link.type ? linkedEntities.link_type[link.type] : null;
    let faviconClass: string | void;
    const backward = linkType && linkType.type1 > 'url';

    const showTypeSelection = (link.error || hasUrlError)
      ? true
      : !(link.urlMatchesType || isEmpty(link));

    if (!showTypeSelection && link.urlMatchesType) {
      for (const key of Object.keys(FAVICON_CLASSES)) {
        if (link.url.indexOf(key) > 0) {
          faviconClass = FAVICON_CLASSES[key];
          break;
        }
      }
    }

    return (
      <tr className="relationship-item" key={link.relationship}>
        <td />
        <td className="relationship-name">
          <label>{l('Type:')}</label>
          {/* If the URL matches its type or is just empty,
              display either a favicon
              or a prompt for a new link as appropriate. */
            showTypeSelection
              ? (
                <LinkTypeSelect
                  handleTypeChange={
                    (event) => props.onTypeChange(link.index, event)
                  }
                  type={link.type}
                >
                  {props.typeOptions}
                </LinkTypeSelect>
              ) : (
                <label>
                  {faviconClass &&
                  <span
                    className={'favicon ' + faviconClass + '-favicon'}
                  />}
                  {linkType ? (
                    backward
                      ? l_relationships(linkType.reverse_link_phrase)
                      : l_relationships(linkType.link_phrase)
                  ) : null}
                </label>
              )
          }
          {linkType &&
            hasOwnProp(
              linkType.attributes,
              String(VIDEO_ATTRIBUTE_ID),
            ) &&
            <div className="attribute-container">
              <label>
                <input
                  checked={link.video}
                  onChange={
                    (event) => props.onVideoChange(link.index, event)
                  }
                  type="checkbox"
                />
                {' '}
                {l('video')}
              </label>
            </div>}
          {link.error &&
            <div className="error field-error" data-visible="1">
              {link.error.message}
            </div>}
        </td>
        <td className="link-actions" style={{minWidth: '34px'}}>
          {link.url && !link.error && !hasUrlError &&
            <TypeDescription type={link.type} url={link.url} />}
          {!props.isOnlyRelationship &&
            <RemoveButton
              onClick={() => props.onLinkRemove(link.index)}
              title={l('Remove Relationship')}
            />}
        </td>
      </tr>
    );
  };

type LinkProps = {
  error: ErrorT | null,
  handleLinkRemove: (number) => void,
  handleUrlBlur: (number, SyntheticEvent<HTMLInputElement>) => void,
  handleUrlChange: (Array<number>, SyntheticEvent<HTMLInputElement>) => void,
  index: number,
  isLastLink: boolean,
  isOnlyLink: boolean,
  onAddRelationship: (string) => void,
  onCancelEdit: (Array<LinkRelationshipT>) => void,
  onTypeChange: (number, SyntheticEvent<HTMLSelectElement>) => void,
  onUrlRemove: () => void,
  onVideoChange:
    (number, SyntheticEvent<HTMLInputElement>) => void,
  relationships: Array<LinkRelationshipT>,
  typeOptions: Array<React.Element<'option'>>,
  url: string,
};

type ExternalLinkState = {
  isPopoverOpen: boolean,
  originalProps: LinkProps,
};

export class ExternalLink
  extends React.Component<LinkProps, ExternalLinkState> {
  constructor(props: LinkProps) {
    super(props);
    this.state = {
      isPopoverOpen: false,
      originalProps: props,
    };
  }

  handleKeyDown(event: SyntheticKeyboardEvent<HTMLInputElement>) {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.props.handlePressEnter(event);
    }
  }

  onTogglePopover(open: boolean) {
    if (open) {
      // Backup original link state
      this.setState({originalProps: this.props});
    }
    this.setState({isPopoverOpen: open});
  }

  handleCancelEdit() {
    const props = this.state.originalProps;
    // Restore original link state when cancelled
    this.props.onCancelEdit(props.relationships);
  }

  render(): React.Element<'tr'> {
    // Temporarily hide changes while editing
    const props =
      this.state.isPopoverOpen ? this.state.originalProps : this.props;
    const notEmpty = props.relationships.some(link => {
      return !isEmpty(link);
    });

    return (
      <React.Fragment>
        <tr className="external-link-item">
          <td>
            <label>
              {props.isOnlyLink
                ? l('Add link:')
                : (
                  props.isLastLink
                    ? l('Add another link:')
                    : props.index + 1
                )}
            </label>
          </td>
          <td>
            {(props.isLastLink || !props.url) ? (
              <input
                className="value with-button"
                onBlur={props.handleUrlBlur}
                onChange={props.handleUrlChange}
                onKeyDown={(event) => this.handleKeyDown(event)}
                type="url"
                // Don't interrupt user input with clean URL
                value={props.rawUrl}
              />
            ) : (
              <a className="url" href={props.url}>{props.url}</a>
            )}
            {props.error &&
              <div
                className={`error field-error target-${props.errorTarget}`}
                data-visible="1"
              >
                {props.error.message}
              </div>
            }
          </td>
          <td className="link-actions" style={{minWidth: '34px'}}>
            {// Use current props to preview changes while editing
              !isEmpty(props) &&
              <URLInputPopover
                errorMessage={this.props.errorMessage}
                errorTarget={this.props.errorTarget}
                onCancel={() => this.handleCancelEdit()}
                onChange={this.props.handleUrlChange}
                onToggle={(open) => this.onTogglePopover(open)}
                rawUrl={this.props.rawUrl}
                url={this.props.url}
              />
            }
            {notEmpty &&
              <RemoveButton
                onClick={() => props.onUrlRemove()}
                title={l('Remove Link')}
              />}
          </td>
        </tr>
        {notEmpty &&
          props.relationships.map((link, index) => (
            <ExternalLinkRelationship
              hasUrlError={props.error != null}
              isOnlyRelationship={props.relationships.length === 1}
              key={index}
              link={link}
              onLinkRemove={props.handleLinkRemove}
              onTypeChange={props.onTypeChange}
              onVideoChange={props.onVideoChange}
              typeOptions={props.typeOptions}
            />
        ))}
        {notEmpty &&
        <tr className="add-relationship">
          <td />
          <td className="add-item" colSpan="4">
            <button
              className="add-item with-label"
              onClick={() => props.onAddRelationship(props.url)}
              type="button"
            >
              {l('Add another relationship')}
            </button>
          </td>
        </tr>}
      </React.Fragment>
    );
  }
}

const defaultLinkState: LinkStateT = {
  rawUrl: '',
  relationship: null,
  type: null,
  url: '',
  video: false,
};

function newLinkState(state: $Shape<LinkStateT>) {
  return {...defaultLinkState, ...state};
}

function linkTypeAndUrlString(link) {
  /*
   * There's no reason why we should allow adding the same relationship
   * twice when the only difference is http vs https, so normalize this
   * for the check.
   */
  const httpUrl = link.url.replace(/^https/, 'http');
  return (link.type || '') + '\0' + httpUrl;
}

function isEmpty(link) {
  return !(link.type || link.url);
}

function withOneEmptyLink(links, dontRemove) {
  let emptyCount = 0;
  let canRemoveCount = 0;
  const canRemove = {};

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

const isVideoAttribute = attr => attr.type.gid === VIDEO_ATTRIBUTE_GID;

export function parseRelationships(
  relationships?: $ReadOnlyArray<RelationshipT | {
    +id: null,
    +linkTypeID?: number,
    +target: {
      +entityType: 'url',
      +name: string,
    },
  }>,
): Array<LinkStateT> {
  if (!relationships) {
    return [];
  }
  return relationships.reduce(function (accum, data) {
    const target = data.target;

    if (target.entityType === 'url') {
      accum.push({
        relationship: data.id,
        rawUrl: target.name,
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
  links: Array<LinkStateT>,
): Map<string, Array<LinkRelationshipT>> {
  let map = new Map();
  links.forEach((link, index) => {
    const relationship: LinkRelationshipT = {...link, error: null, index};
    // Treat empty URLs as separate links
    const key = link.url === '' ? String(link.relationship) : link.url;
    const relationships = map.get(key);
    if (relationships) {
      relationships.push(relationship);
    } else {
      map.set(key, [relationship]);
    }
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

const URL_SHORTENERS = [
  'adf.ly',
  'album.link',
  'ampl.ink',
  'amu.se',
  'artist.link',
  'band.link',
  'biglink.to',
  'bit.ly',
  'bitly.com',
  'backl.ink',
  'bruit.app',
  'bstlnk.to',
  'cli.gs',
  'deck.ly',
  'distrokid.com',
  'ditto.fm',
  'eventlink.to',
  'fanlink.to',
  'ffm.to',
  'fty.li',
  'fur.ly',
  'g.co',
  'gate.fm',
  'geni.us',
  'goo.gl',
  'hypel.ink',
  'hyperurl.co',
  'is.gd',
  'kl.am',
  'laburbain.com',
  'li.sten.to',
  'linkco.re',
  'lnkfi.re',
  'linktr.ee',
  'listen.lt',
  'lnk.bio',
  'lnk.co',
  'lnk.site',
  'lnk.to',
  'lsnto.me',
  'many.link',
  'mcaf.ee',
  'moourl.com',
  'music.indiefy.net',
  'musics.link',
  'mylink.page',
  'myurls.bio',
  'odesli.co',
  'orcd.co',
  'owl.ly',
  'page.link',
  'pandora.app.link',
  'podlink.to',
  'pods.link',
  'push.fm',
  'rb.gy',
  'rubyurl.com',
  'smarturl.it',
  'snd.click',
  'song.link',
  'songwhip.com',
  'spinnup.link',
  'spoti.fi',
  'sptfy.com',
  'spread.link',
  'streamlink.to',
  'su.pr',
  't.co',
  'tiny.cc',
  'tinyurl.com',
  'tourlink.to',
  'trac.co', // Host links can be legitimate; non-root paths are aggregators
  'u.nu',
  'unitedmasters.com',
  'untd.io',
  'yep.it',
].map(host => new RegExp('^https?://([^/]+\\.)?' + host + '/.+', 'i'));

function isShortened(url) {
  return URL_SHORTENERS.some(function (shortenerRegex) {
    return url.match(shortenerRegex) !== null;
  });
}

function isGoogleAmp(url) {
  return /^https?:\/\/([^/]+\.)?google\.[^/]+\/amp/.test(url);
}

function isMusicBrainz(url) {
  return /^https?:\/\/([^/]+\.)?musicbrainz\.org/.test(url);
}

type InitialOptionsT = {
  errorObservable?: (boolean) => void,
  mountPoint: Element,
  sourceData: CoreEntityT,
};

type SeededUrlShape = {
  +link_type_id?: string,
  +text?: string,
};

MB.createExternalLinksEditor = function (options: InitialOptionsT) {
  const sourceData = options.sourceData;
  const sourceType = sourceData.entityType;
  const entityTypes = [sourceType, 'url'].sort().join('-');
  let initialLinks = parseRelationships(sourceData.relationships);

  // Terribly get seeded URLs
  if (MB.formWasPosted) {
    if (hasSessionStorage) {
      const submittedLinks = window.sessionStorage.getItem('submittedLinks');
      if (submittedLinks) {
        initialLinks = JSON.parse(submittedLinks)
          .filter(l => !isEmpty(l)).map(newLinkState);
      }
    }
  } else {
    const seededLinkRegex = new RegExp(
      '(?:\\?|&)edit-' + sourceType +
        '\\.url\\.([0-9]+)\\.(text|link_type_id)=([^&]+)',
      'g',
    );
    const urls = {};
    let match;

    while ((match = seededLinkRegex.exec(window.location.search))) {
      const [/* unused */, index, key, value] = match;
      (urls[index] = urls[index] || {})[key] = decodeURIComponent(value);
    }

    for (
      const data of
      ((Object.values(urls): any): $ReadOnlyArray<SeededUrlShape>)
    ) {
      initialLinks.push(newLinkState({
        relationship: uniqueId('new-'),
        type: parseInt(data.link_type_id, 10) || null,
        url: data.text || '',
      }));
    }
  }

  initialLinks.sort(function (a, b) {
    const typeA = a.type && linkedEntities.link_type[a.type];
    const typeB = b.type && linkedEntities.link_type[b.type];

    return compare(
      typeA ? l_relationships(typeA.link_phrase).toLowerCase() : '',
      typeB ? l_relationships(typeB.link_phrase).toLowerCase() : '',
    );
  });

  initialLinks = initialLinks.map(function (link) {
    /*
     * Only run the URL cleanup on seeded URLs, i.e. URLs that don't have an
     * existing relationship ID.
     */
    if (!isPositiveInteger(link.relationship)) {
      return Object.assign({}, link, {
        relationship: uniqueId('new-'),
        url: URLCleanup.cleanURL(link.url) || link.url,
      });
    }
    return link;
  });

  const typeOptions = (
    linkTypeOptions(
      {children: linkedEntities.link_type_tree[entityTypes]},
      /^url-/.test(entityTypes),
    ).map((data) => (
      <option
        disabled={data.disabled}
        key={data.value}
        value={data.value}
      >
        {data.text}
      </option>
    ))
  );

  const errorObservable = options.errorObservable ||
    validation.errorField(ko.observable(false));

  return ReactDOM.render(
    <ExternalLinksEditor
      errorObservable={errorObservable}
      initialLinks={initialLinks}
      sourceType={sourceData.entityType}
      typeOptions={typeOptions}
    />,
    options.mountPoint,
  );
};

export const createExternalLinksEditor = MB.createExternalLinksEditor;
