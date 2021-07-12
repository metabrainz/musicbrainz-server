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

export type LinkStateT = {
  rawUrl: string,
  // New relationships will use a unique string ID like "new-1".
  relationship: StrOrNum | null,
  type: number | null,
  url: string,
  video: boolean,
  ...
};

type LinkMapT = Map<string, LinkStateT>;

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

  appendEmptyLink() {
    this.setState({
      links: this.state.links.concat(
        newLinkState({relationship: uniqueId('new-')}),
      ),
    });
  }

  handleUrlChange(index: number, event: SyntheticEvent<HTMLInputElement>) {
    const rawUrl = event.currentTarget.value;
    let url = rawUrl;
    const link = this.state.links[index];

    // Allow adding spaces while typing, they'll be trimmed on blur
    if (url.trim() !== link.url.trim()) {
      if (url.match(/^\w+\./)) {
        url = 'http://' + url;
      }
      url = URLCleanup.cleanURL(url) || url;
    }

    this.setLinkState(index, {url: url, rawUrl: rawUrl}, () => {
      if (!link.type) {
        const type = URLCleanup.guessType(this.props.sourceType, url);

        if (type) {
          this.setLinkState(index, {type: linkedEntities.link_type[type].id});
        }
      }
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
          {linksArray.map((link, index) => {
            let error;
            let errorTarget: ErrorTarget = URLCleanup.ERROR_TARGETS.NONE;
            const isLastLink = index === linksArray.length - 1;
            const linkType = link.type
              ? linkedEntities.link_type[link.type] : {};
            const checker = URLCleanup.validationRules[linkType.gid];
            const oldLink = oldLinks.get(String(link.relationship));
            const isNewLink = !isPositiveInteger(link.relationship);
            const linkChanged = oldLink && link.url !== oldLink.url;
            const isNewOrChangedLink = (isNewLink || linkChanged);
            const linkTypeChanged = oldLink && +link.type !== +oldLink.type;
            link.url = getUnicodeUrl(link.url);

            if (isEmpty(link)) {
              error = '';
            } else if (!link.url) {
              error = l('Required field.');
              errorTarget = URLCleanup.ERROR_TARGETS.URL;
            } else if (isNewOrChangedLink && !isValidURL(link.url)) {
              error = l('Enter a valid url e.g. "http://google.com/"');
              errorTarget = URLCleanup.ERROR_TARGETS.URL;
            } else if (isNewOrChangedLink && isMusicBrainz(link.url)) {
              error = l(`Links to MusicBrainz URLs are not allowed.
                         Did you mean to paste something else?`);
              errorTarget = URLCleanup.ERROR_TARGETS.URL;
            } else if (isNewOrChangedLink && isMalware(link.url)) {
              error = l(`Links to this website are not allowed
                         because it is known to host malware.`);
              errorTarget = URLCleanup.ERROR_TARGETS.URL;
            } else if (isNewOrChangedLink && isShortened(link.url)) {
              error = l(`Please don’t enter bundled/shortened URLs,
                         enter the destination URL(s) instead.`);
              errorTarget = URLCleanup.ERROR_TARGETS.URL;
            } else if (isNewOrChangedLink && isGoogleAmp(link.url)) {
              error = l(`Please don’t enter Google AMP links,
                         since they are effectively an extra redirect.
                         Enter the destination URL instead.`);
              errorTarget = URLCleanup.ERROR_TARGETS.URL;
            } else if (!link.type) {
              error = l(`Please select a link type for the URL
                         you’ve entered.`);
              errorTarget = URLCleanup.ERROR_TARGETS.RELATIONSHIP;
            } else if (
              linkType.deprecated && (isNewLink || linkTypeChanged)
            ) {
              error = l(`This relationship type is deprecated 
                         and should not be used.`);
              errorTarget = URLCleanup.ERROR_TARGETS.RELATIONSHIP;
            } else if (
              (linksByTypeAndUrl.get(
                linkTypeAndUrlString(link),
              ) || []).length > 1
            ) {
              error = l('This relationship already exists.');
              errorTarget = URLCleanup.ERROR_TARGETS.RELATIONSHIP;
            } else if (isNewOrChangedLink && checker) {
              const check = checker(link.url);
              if (!check.result) {
                errorTarget = check.target ||
                  URLCleanup.ERROR_TARGETS.NONE;
                if (errorTarget === URLCleanup.ERROR_TARGETS.URL) {
                  error = l(
                    `This URL is not allowed for the selected link type,
                     or is incorrectly formatted.`,
                  );
                }
                if (errorTarget === URLCleanup.ERROR_TARGETS.RELATIONSHIP) {
                  error = l(`This URL is not allowed 
                             for the selected link type.`);
                }
                error = check.error || error;
              }
            }

            if (error) {
              this.props.errorObservable(true);
            }

            return (
              <ExternalLink
                errorMessage={error || ''}
                errorTarget={errorTarget}
                handlePressEnter={
                  (event) => this.handlePressEnter(event)
                }
                handleUrlBlur={
                  (event) => this.handleUrlBlur(index, event)
                }
                handleUrlChange={
                  (event) => this.handleUrlChange(index, event)
                }
                handleVideoChange={
                  (event) => this.handleVideoChange(index, event)
                }
                isLastLink={isLastLink}
                isOnlyLink={this.state.links.length === 1}
                key={link.relationship}
                onCancelEdit={
                  (state) => this.setLinkState(index, state)
                }
                onRemove={() => this.removeLink(index)}
                rawUrl={link.rawUrl}
                type={link.type}
                typeChangeCallback={
                  (event) => this.handleTypeChange(index, event)
                }
                typeOptions={this.props.typeOptions}
                url={link.url}
                urlMatchesType={
                  linkType.gid === URLCleanup.guessType(
                    this.props.sourceType, link.url,
                  )
                }
                video={link.video}
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
  handleTypeChange: (SyntheticEvent<HTMLSelectElement>) => void,
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

type ErrorTarget = $Values<typeof URLCleanup.ERROR_TARGETS>;

type LinkProps = {
  errorMessage: string,
  errorTarget: ErrorTarget,
  handlePressEnter: (SyntheticKeyboardEvent<HTMLInputElement>) => void,
  handleUrlBlur: (SyntheticEvent<HTMLInputElement>) => void,
  handleUrlChange: (SyntheticEvent<HTMLInputElement>) => void,
  handleVideoChange:
    (SyntheticEvent<HTMLInputElement>) => void,
  isLastLink: boolean,
  isOnlyLink: boolean,
  onCancelEdit: ($Shape<LinkStateT>) => void,
  onRemove: () => void,
  rawUrl: string,
  type: number | null,
  typeChangeCallback: (SyntheticEvent<HTMLSelectElement>) => void,
  typeOptions: Array<React.Element<'option'>>,
  url: string,
  urlMatchesType: boolean,
  video: boolean,
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
    this.props.onCancelEdit({
      url: props.url,
      rawUrl: props.rawUrl,
      type: props.type,
    });
  }

  render(): React.Element<'tr'> {
    // Temporarily hide changes while editing
    const props =
      this.state.isPopoverOpen ? this.state.originalProps : this.props;
    const linkType = props.type ? linkedEntities.link_type[props.type] : null;
    let typeDescription = '';
    let faviconClass: string | void;
    const backward = linkType && linkType.type1 > 'url';

    if (linkType && linkType.description) {
      typeDescription = exp.l('{description} ({url|more documentation})', {
        description: expand2react(l_relationships(linkType.description)),
        url: '/relationship/' + linkType.gid,
      });
    }

    const showTypeSelection = props.errorMessage
      ? true
      : !(props.urlMatchesType || isEmpty(props));

    if (!showTypeSelection && props.urlMatchesType) {
      for (const key of Object.keys(FAVICON_CLASSES)) {
        if (props.url.indexOf(key) > 0) {
          faviconClass = FAVICON_CLASSES[key];
          break;
        }
      }
    }

    return (
      <tr>
        <td>
          {/* If the URL matches its type or is just empty, display either a
              favicon or a prompt for a new link as appropriate. */
            showTypeSelection
              ? (
                <LinkTypeSelect
                  handleTypeChange={props.typeChangeCallback}
                  type={props.type}
                >
                  {props.typeOptions}
                </LinkTypeSelect>
              ) : (
                <label>
                  {faviconClass &&
                  <span className={'favicon ' + faviconClass + '-favicon'} />}
                  {(linkType ? (
                    backward
                      ? l_relationships(linkType.reverse_link_phrase)
                      : l_relationships(linkType.link_phrase)
                  ) : null) ||
                  (props.isOnlyLink
                    ? l('Add link:')
                    : l('Add another link:'))}
                </label>)
          }
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
          {props.errorMessage &&
            <div
              className={`error field-error target-${props.errorTarget}`}
              data-visible="1"
            >
              {props.errorMessage}
            </div>
          }
          {linkType &&
            hasOwnProp(linkType.attributes, String(VIDEO_ATTRIBUTE_ID)) &&
            <div className="attribute-container">
              <label>
                <input
                  checked={props.video}
                  onChange={props.handleVideoChange}
                  type="checkbox"
                />
                {' '}
                {l('video')}
              </label>
            </div>}
        </td>
        <td className="link-actions" style={{minWidth: '51px'}}>
          {typeDescription &&
            <HelpIcon
              content={
                <div style={{textAlign: 'left'}}>
                  {typeDescription}
                </div>}
            />}
          {!props.isLastLink &&
            // Use current props to preview changes while editing
            <URLInputPopover
              errorMessage={this.props.errorMessage}
              onCancel={() => this.handleCancelEdit()}
              onChange={this.props.handleUrlChange}
              onToggle={(open) => this.onTogglePopover(open)}
              rawUrl={this.props.rawUrl}
              url={this.props.url}
            />
          }
          {!isEmpty(props) && !props.isLastLink &&
            <RemoveButton
              onClick={props.onRemove}
              title={l('Remove Link')}
            />}
        </td>
      </tr>
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
