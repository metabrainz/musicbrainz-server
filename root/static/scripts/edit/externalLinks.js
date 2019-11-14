/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import * as React from 'react';
import ReactDOM from 'react-dom';

import {
  FAVICON_CLASSES,
  VIDEO_ATTRIBUTE_ID,
  VIDEO_ATTRIBUTE_GID,
} from '../common/constants';
import {compare} from '../common/i18n';
import expand2react from '../common/i18n/expand2react';
import linkedEntities from '../common/linkedEntities';
import MB from '../common/MB';
import {hasSessionStorage} from '../common/utility/storage';

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
  ...,
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
  constructor(props: LinksEditorProps) {
    super(props);
    this.state = {links: withOneEmptyLink(props.initialLinks)};
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

    if (url !== trimmed) {
      this.setLinkState(index, {url: trimmed});
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
      $(ReactDOM.findDOMNode(this))
        .find('tr:gt(' + (index - 1) + ') button.remove:first, ' +
              'tr:lt(' + (index + 1) + ') button.remove:last')
        .eq(0)
        .focus();
    });
  }

  getOldLinksHash() {
    return _(this.props.initialLinks)
      .filter(link => isPositiveInteger(link.relationship))
      .keyBy('relationship')
      .value();
  }

  getEditData() {
    const oldLinks = this.getOldLinksHash();
    const newLinks = _.keyBy<
      LinkStateT,
      $ElementType<LinkStateT, 'relationship'>,
    >(this.state.links, 'relationship');

    return {
      allLinks: _.defaults(_.clone(newLinks), oldLinks),
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

    _.each(allLinks, function (link, relationship) {
      if (!link.type) {
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
    });
  }

  render() {
    this.props.errorObservable(false);

    const oldLinks = this.getOldLinksHash();
    const linksArray = this.state.links;

    const linksByTypeAndUrl = _(linksArray).concat(this.props.initialLinks)
      .uniqBy((link) => link.relationship)
      .groupBy(linkTypeAndUrlString)
      .value();

    return (
      <table className="row-form" id="external-links-editor">
        <tbody>
          {linksArray.map((link, index) => {
            let error;
            const linkType = link.type
              ? linkedEntities.link_type[link.type] : {};
            const checker = URLCleanup.validationRules[linkType.gid];
            const oldLink = oldLinks[link.relationship];
            const isNewLink = !isPositiveInteger(link.relationship);
            const linkChanged = oldLink && link.url !== oldLink.url;
            const linkTypeChanged = oldLink && +link.type !== +oldLink.type;

            if (isEmpty(link)) {
              error = '';
            } else if (!link.url) {
              error = l('Required field.');
            } else if (!isValidURL(link.url)) {
              error = l('Enter a valid url e.g. "http://google.com/"');
            } else if (isShortened(link.url)) {
              error = l(`Please don’t enter bundled/shortened URLs,
                         enter the destination URL(s) instead.`);
            } else if (!link.type) {
              error = l(`Please select a link type for the URL
                         you’ve entered.`);
            } else if (
              linkType.deprecated && (isNewLink || linkTypeChanged)
            ) {
              error = l(`This relationship type is deprecated 
                         and should not be used.`);
            } else if (
              (isNewLink || linkChanged) && checker && !checker(link.url)
            ) {
              error = l(`This URL is not allowed for the selected link type, 
                         or is incorrectly formatted.`);
            } else if (
              (isNewLink || linkChanged) &&
                /^(https?:\/\/)?([^.\/]+\.)?wikipedia\.org\/.*#/
                  .test(link.url)
            ) {
              // Kludge for MBS-9515 to be replaced with general MBS-9516
              error = exp.l(
                `Links to specific sections of Wikipedia articles are not 
                 allowed. Please remove “{fragment}” if still appropriate.
                 See the {url|guidelines}.`,
                {
                  fragment: (
                    <span className="url-quote" key="fragment">
                      {link.url.replace(
                        /^(?:https?:\/\/)?(?:[^.\/]+\.)?wikipedia\.org\/[^#]*#(.*)$/,
                        '#$1',
                      )}
                    </span>
                  ),
                  url: {
                    href: '/relationship/' + linkType.gid,
                    target: '_blank',
                  },
                },
              );
            } else if (
              (linksByTypeAndUrl[linkTypeAndUrlString(link)] || []).length > 1
            ) {
              error = l('This relationship already exists.');
            }

            if (error) {
              this.props.errorObservable(true);
            }

            return (
              <ExternalLink
                errorMessage={error || ''}
                handleUrlBlur={
                  _.bind(this.handleUrlBlur, this, index)
                }
                handleUrlChange={
                  _.bind(this.handleUrlChange, this, index)
                }
                handleVideoChange={
                  _.bind(this.handleVideoChange, this, index)
                }
                isOnlyLink={this.state.links.length === 1}
                key={link.relationship}
                removeCallback={_.bind(this.removeLink, this, index)}
                type={link.type}
                typeChangeCallback={
                  _.bind(this.handleTypeChange, this, index)
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
  removeCallback: (number) => void,
  type: number | null,
  typeChangeCallback: (number, SyntheticEvent<HTMLSelectElement>) => void,
  typeOptions: Array<React.Element<'option'>>,
  url: string,
  urlMatchesType: boolean,
  video: boolean,
};

export class ExternalLink extends React.Component<LinkProps> {
  render() {
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
            _.has(linkType.attributes, String(VIDEO_ATTRIBUTE_ID)) &&
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
              callback={props.removeCallback}
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
  _.defaults(state, defaultLinkState);
  return state;
}

function linkTypeAndUrlString(link) {
  return (link.type || '') + '\0' + link.url;
}

function isEmpty(link) {
  return !(link.type || link.url);
}

function withOneEmptyLink(links, dontRemove) {
  let emptyCount = 0;
  const canRemove = {};

  links.forEach(function (link, index) {
    if (isEmpty(link)) {
      ++emptyCount;
      if (index !== dontRemove) {
        canRemove[index] = true;
      }
    }
  });

  if (emptyCount === 0) {
    return links.concat(newLinkState({relationship: _.uniqueId('new-')}));
  } else if (emptyCount > 1 && _.size(canRemove)) {
    return links.filter((link, index) => !canRemove[index]);
  }
  return links;
}

const isVideoAttribute = attr => attr.type.gid === VIDEO_ATTRIBUTE_GID;

export function parseRelationships(
  relationships?: $ReadOnlyArray<RelationshipT>,
) {
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

function isValidURL(url) {
  const a = document.createElement('a');
  a.href = url;

  const hostname = a.hostname;

  if (url.indexOf(hostname) < 0) {
    return false;
  }

  if (!hostnameRegex.test(hostname)) {
    return false;
  }

  if (hostname.indexOf('.') < 0) {
    return false;
  }

  if (!protocolRegex.test(a.protocol)) {
    return false;
  }

  return true;
}

const URL_SHORTENERS = [
  'adf.ly',
  'band.link',
  'biglink.to',
  'bit.ly',
  'bitly.com',
  'bruit.app',
  'cli.gs',
  'deck.ly',
  'distrokid.com',
  'fanlink.to',
  'ffm.to',
  'fty.li',
  'fur.ly',
  'goo.gl',
  'hyperurl.co',
  'is.gd',
  'kl.am',
  'laburbain.com',
  'linkco.re',
  'linktr.ee',
  'listen.lt',
  'lnk.bio',
  'lnk.co',
  'lnk.to',
  'mcaf.ee',
  'moourl.com',
  'owl.ly',
  'rubyurl.com',
  'smarturl.it',
  'song.link',
  'songwhip.com',
  'spread.link',
  'su.pr',
  't.co',
  'tiny.cc',
  'tinyurl.com',
  'u.nu',
  'yep.it',
].map(host => new RegExp('^https?://([^/]+\\.)?' + host + '/', 'i'));

function isShortened(url) {
  return URL_SHORTENERS.some(function (shortenerRegex) {
    return url.match(shortenerRegex) !== null;
  });
}

type InitialOptionsT = {
  errorObservable?: (boolean) => void,
  mountPoint: Element,
  sourceData: CoreEntityT,
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

    _.each(urls, function (data) {
      initialLinks.push(newLinkState({
        relationship: _.uniqueId('new-'),
        type: data.link_type_id,
        url: data.text || '',
      }));
    });
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
        relationship: _.uniqueId('new-'),
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
