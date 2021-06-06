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
import {linkTypeOptions} from './forms';
import * as URLCleanup from './URLCleanup';
import validation from './validation';

type LinkStateT = {
  relationship: number | string | null,
  type: number | null,
  url: string,
  video: boolean,
  ...
};

type LinkHashT = {
  __proto__: empty,
  +[key: number | string | null]: LinkStateT,
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
    this.setState({links: withOneEmptyLink(newLinks, index)}, callback);
  }

  handleUrlChange(index: number, event: SyntheticEvent<HTMLInputElement>) {
    let url = event.currentTarget.value;
    const link = this.state.links[index];

    // Allow adding spaces while typing, they'll be trimmed on blur
    if (url.trim() !== link.url.trim()) {
      if (url.match(/^\w+\./)) {
        url = 'http://' + url;
      }
      url = URLCleanup.cleanURL(url) || url;
    }

    this.setLinkState(index, {url: url}, () => {
      if (!link.type) {
        const type = URLCleanup.guessType(this.props.sourceType, url);

        if (type) {
          this.setLinkState(index, {type: linkedEntities.link_type[type].id});
        }
      }
    });
  }

  handleUrlBlur(index: number, event: SyntheticEvent<HTMLInputElement>) {
    const url = event.currentTarget.value;
    const trimmed = url.trim();
    const unicodeUrl = getUnicodeUrl(trimmed);

    if (url !== unicodeUrl) {
      this.setLinkState(index, {url: unicodeUrl});
    }
  }

  handleTypeChange(index: number, event: SyntheticEvent<HTMLSelectElement>) {
    this.setLinkState(index, {type: +event.currentTarget.value || null});
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

  getOldLinksHash(): LinkHashT {
    return keyBy(
      this.props.initialLinks
        .filter(link => isPositiveInteger(link.relationship)),
      x => String(x.relationship),
    );
  }

  getEditData(): {
    allLinks: LinkHashT,
    newLinks: LinkHashT,
    oldLinks: LinkHashT,
    } {
    const oldLinks = this.getOldLinksHash();
    const newLinks = keyBy<
      LinkStateT,
      $ElementType<LinkStateT, 'relationship'>,
    >(this.state.links, x => String(x.relationship));

    return {
      allLinks: {...oldLinks, ...newLinks},
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

    for (
      const [relationship, link] of
      ((Object.entries(allLinks): any): $ReadOnlyArray<[string, ?LinkStateT]>)
    ) {
      if (!link?.type) {
        return;
      }

      const prefix = startingPrefix + '.' + (startingIndex + (index++));

      if (isPositiveInteger(relationship)) {
        pushInput(prefix, 'relationship_id', String(relationship));

        if (!newLinks[relationship]) {
          pushInput(prefix, 'removed', '1');
        }
      }

      pushInput(prefix, 'text', link.url);

      if (link.video) {
        pushInput(prefix + '.attributes.0', 'type.gid', VIDEO_ATTRIBUTE_GID);
      } else if ((oldLinks[relationship] || {}).video) {
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
              error = '';
            } else if (!link.url) {
              error = l('Required field.');
            } else if (isNewOrChangedLink && !isValidURL(link.url)) {
              error = l('Enter a valid url e.g. "http://google.com/"');
            } else if (isNewOrChangedLink && isMusicBrainz(link.url)) {
              error = l(`Links to MusicBrainz URLs are not allowed.
                         Did you mean to paste something else?`);
            } else if (isNewOrChangedLink && isMalware(link.url)) {
              error = l(`Links to this website are not allowed
                         because it is known to host malware.`);
            } else if (isNewOrChangedLink && isShortened(link.url)) {
              error = l(`Please don’t enter bundled/shortened URLs,
                         enter the destination URL(s) instead.`);
            } else if (isNewOrChangedLink && isGoogleAmp(link.url)) {
              error = l(`Please don’t enter Google AMP links,
                         since they are effectively an extra redirect.
                         Enter the destination URL instead.`);
            } else if (!link.type) {
              error = l(`Please select a link type for the URL
                         you’ve entered.`);
            } else if (
              linkType.deprecated && (isNewLink || linkTypeChanged)
            ) {
              error = l(`This relationship type is deprecated 
                         and should not be used.`);
            } else if (
              (linksByTypeAndUrl[linkTypeAndUrlString(link)] || []).length > 1
            ) {
              error = l('This relationship already exists.');
            } else if (isNewOrChangedLink && checker) {
              const check = checker(link.url);
              if (!check.result) {
                error = check.error ||
                  l(`This URL is not allowed for the selected link type, 
                     or is incorrectly formatted.`);
              }
            }

            if (error) {
              this.props.errorObservable(true);
            }

            return (
              <ExternalLink
                errorMessage={error || ''}
                handleUrlBlur={
                  this.handleUrlBlur.bind(this, index)
                }
                handleUrlChange={
                  this.handleUrlChange.bind(this, index)
                }
                handleVideoChange={
                  this.handleVideoChange.bind(this, index)
                }
                isOnlyLink={this.state.links.length === 1}
                key={link.relationship}
                onRemove={this.removeLink.bind(this, index)}
                type={link.type}
                typeChangeCallback={
                  this.handleTypeChange.bind(this, index)
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
  handleTypeChange:
    (number, SyntheticEvent<HTMLSelectElement>) => void,
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

type LinkProps = {
  errorMessage: React.Node,
  handleUrlBlur: (number, SyntheticEvent<HTMLInputElement>) => void,
  handleUrlChange: (number, SyntheticEvent<HTMLInputElement>) => void,
  handleVideoChange:
    (number, SyntheticEvent<HTMLInputElement>) => void,
  isOnlyLink: boolean,
  onRemove: (number) => void,
  type: number | null,
  typeChangeCallback: (number, SyntheticEvent<HTMLSelectElement>) => void,
  typeOptions: Array<React.Element<'option'>>,
  url: string,
  urlMatchesType: boolean,
  video: boolean,
};

export class ExternalLink extends React.Component<LinkProps> {
  render(): React.Element<'tr'> {
    const props = this.props;
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

    if (props.url && !props.errorMessage) {
      typeDescription = (
        <>
          <a
            href={props.url}
            rel="noopener noreferrer"
            target="_blank"
          >
            {props.url}
          </a>
          <br />
          <br />
          {typeDescription}
        </>
      );
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
          <input
            className="value with-button"
            onBlur={props.handleUrlBlur}
            onChange={props.handleUrlChange}
            type="url"
            value={props.url}
          />
          {props.errorMessage &&
            <div className="error field-error" data-visible="1">
              {props.errorMessage}
            </div>}
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
        <td style={{minWidth: '34px'}}>
          {typeDescription && <HelpIcon content={typeDescription} />}
          {isEmpty(props) ||
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
  relationships?: $ReadOnlyArray<RelationshipT>,
): Array<LinkStateT> {
  if (!relationships) {
    return [];
  }
  return relationships.reduce(function (accum, data) {
    const target = data.target;

    if (target.entityType === 'url') {
      accum.push({
        relationship: data.id,
        type: data.linkTypeID,
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
