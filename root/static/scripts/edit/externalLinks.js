// @flow
// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

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
  url: string,
  type: number | null,
  relationship: number | string | null,
  video: boolean,
};

type LinksEditorProps = {
  sourceType: string,
  typeOptions: Array<React.Element<'option'>>,
  initialLinks: Array<LinkStateT>,
  errorObservable: (bool) => void,
};

type LinksEditorState = {
  links: Array<LinkStateT>,
};

export class ExternalLinksEditor extends React.Component<LinksEditorProps, LinksEditorState> {
  constructor(props: LinksEditorProps) {
    super(props);
    this.state = {links: withOneEmptyLink(props.initialLinks)};
  }

  setLinkState(index: number,
               state: $Shape<LinkStateT>,
               callback?: () => void) {
    const newLinks: Array<LinkStateT> = this.state.links.concat();
    newLinks[index] = Object.assign({}, newLinks[index], state);
    this.setState({links: withOneEmptyLink(newLinks, index)}, callback);
  }

  handleUrlChange(index: number, event: SyntheticEvent<HTMLInputElement>) {
    var url = event.currentTarget.value;
    var link = this.state.links[index];

    // Allow adding spaces while typing, they'll be trimmed on blur
    if (url.trim() !== link.url.trim()) {
      if (url.match(/^\w+\./)) {
        url = 'http://' + url;
      }
      url = URLCleanup.cleanURL(url) || url;
    }

    this.setLinkState(index, {url: url}, () => {
      if (!link.type) {
        var type = URLCleanup.guessType(this.props.sourceType, url);

        if (type) {
          this.setLinkState(index, {type: linkedEntities.link_type[type].id});
        }
      }
    });
  }

  handleUrlBlur(index: number, event: SyntheticEvent<HTMLInputElement>) {
    var url = event.currentTarget.value;
    var trimmed = url.trim();

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
    const newLinks = this.state.links.concat();
    newLinks.splice(index, 1);
    this.setState({links: newLinks}, () => {
      $(ReactDOM.findDOMNode(this))
        .find('tr:gt(' + (index - 1) + ') button.remove:first, ' +
              'tr:lt(' + (index + 1) + ') button.remove:last')
        .eq(0).focus();
    });
  }

  getOldLinksHash() {
    return _(this.props.initialLinks)
      .filter(link => isPositiveInteger(link.relationship))
      .keyBy('relationship')
      .value();
  }

  getEditData() {
    var oldLinks = this.getOldLinksHash();
    var newLinks = _.keyBy<
      LinkStateT,
      $ElementType<LinkStateT, 'relationship'>,
    >(this.state.links, 'relationship');

    return {
      oldLinks: oldLinks,
      newLinks: newLinks,
      allLinks: _.defaults(_.clone(newLinks), oldLinks)
    };
  }

  getFormData(startingPrefix: string,
              startingIndex: number,
              pushInput: (string, string, string) => void) {
    var index = 0;
    var backward = this.props.sourceType > 'url';
    var {oldLinks, newLinks, allLinks} = this.getEditData();

    _.each(allLinks, function (link, relationship) {
      if (!link.type) {
        return;
      }

      var prefix = startingPrefix + '.' + (startingIndex + (index++));

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

    var oldLinks = this.getOldLinksHash();
    var linksArray = this.state.links;

    var linksByTypeAndUrl = _(linksArray).concat(this.props.initialLinks)
          .uniqBy((link) => link.relationship).groupBy(linkTypeAndUrlString).value();

    return (
      <table id="external-links-editor" className="row-form">
        <tbody>
          {linksArray.map((link, index) => {
            var error;
            var linkType = link.type ? linkedEntities.link_type[link.type] : {};
            var checker = URLCleanup.validationRules[linkType.gid];
            var oldLink = oldLinks[link.relationship];

            if (isEmpty(link)) {
              error = '';
            } else if (!link.url) {
              error = l('Required field.');
            } else if (!isValidURL(link.url)) {
              error = l('Enter a valid url e.g. "http://google.com/"');
            } else if (isShortened(link.url)) {
              error = l("Please don't use shortened URLs.");
            } else if (!link.type) {
              error = l('Please select a link type for the URL you’ve entered.');
            } else if (linkType.deprecated && (!isPositiveInteger(link.relationship) || (oldLink && +link.type !== +oldLink.type))) {
              error = l('This relationship type is deprecated and should not be used.');
            } else if ((!isPositiveInteger(link.relationship) || (oldLink && link.url !== oldLink.url)) && checker && !checker(link.url)) {
              error = l('This URL is not allowed for the selected link type, or is incorrectly formatted.');
            } else if ((!isPositiveInteger(link.relationship) || (oldLink && link.url !== oldLink.url)) && /^(https?:\/\/)?([^.\/]+\.)?wikipedia\.org\/.*#/.test(link.url)) {
              // Kludge for MBS-9515 to be replaced with the more general MBS-9516
              error = exp.l('Links to specific sections of Wikipedia articles are not allowed. Please remove “{fragment}” if still appropriate. See the {url|guidelines}.', {
                fragment: <span className='url-quote' key='fragment'>{link.url.replace(/^(?:https?:\/\/)?(?:[^.\/]+\.)?wikipedia\.org\/[^#]*#(.*)$/, '#$1')}</span>,
                url: { href: '/relationship/' + linkType.gid, target: '_blank' }
              });
            } else if ((linksByTypeAndUrl[linkTypeAndUrlString(link)] || []).length > 1) {
              error = l('This relationship already exists.');
            }

            if (error) {
              this.props.errorObservable(true);
            }

            return (
              <ExternalLink
                key={link.relationship}
                url={link.url}
                type={link.type}
                video={link.video}
                errorMessage={error || ''}
                isOnlyLink={this.state.links.length === 1}
                urlMatchesType={linkType.gid === URLCleanup.guessType(this.props.sourceType, link.url)}
                removeCallback={_.bind(this.removeLink, this, index)}
                urlChangeCallback={_.bind(this.handleUrlChange, this, index)}
                urlBlurCallback={_.bind(this.handleUrlBlur, this, index)}
                typeChangeCallback={_.bind(this.handleTypeChange, this, index)}
                videoChangeCallback={_.bind(this.handleVideoChange, this, index)}
                typeOptions={this.props.typeOptions}
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
  type: number|null,
  typeChangeCallback: (number, SyntheticEvent<HTMLSelectElement>) => void,
};

class LinkTypeSelect extends React.Component<LinkTypeSelectProps> {
  render() {
    return (
      <select value={this.props.type || ''} onChange={this.props.typeChangeCallback} className="link-type">
        <option value="">{'\xA0'}</option>
        {this.props.children}
      </select>
    );
  }
}

type LinkProps = {
  url: string,
  type: number|null,
  video: boolean,
  errorMessage: React.Node,
  isOnlyLink: boolean,
  urlMatchesType: boolean,
  removeCallback: (number) => void,
  urlChangeCallback: (number, SyntheticEvent<HTMLInputElement>) => void,
  urlBlurCallback: (number, SyntheticEvent<HTMLInputElement>) => void,
  typeChangeCallback: (number, SyntheticEvent<HTMLSelectElement>) => void,
  videoChangeCallback: (number, SyntheticEvent<HTMLInputElement>) => void,
  typeOptions: Array<React.Element<'option'>>,
};

export class ExternalLink extends React.Component<LinkProps> {
  render() {
    var props = this.props;
    var linkType = props.type ? linkedEntities.link_type[props.type] : null;
    var typeDescription = '';
    var faviconClass: string | void;
    var backward = linkType && linkType.type1 > 'url';

    if (linkType && linkType.description) {
      typeDescription = exp.l('{description} ({url|more documentation})', {
        description: l_relationships(linkType.description),
        url: '/relationship/' + linkType.gid
      });
    }

    if (props.url && !props.errorMessage) {
      typeDescription = (
        <>
          <a href={props.url} target="_blank">{props.url}</a>
          <br/>
          <br/>
          {typeDescription}
        </>
      );
    }

    var showTypeSelection = props.errorMessage ? true : !(props.urlMatchesType || isEmpty(props));
    if (!showTypeSelection && props.urlMatchesType) {
      faviconClass = _.find(FAVICON_CLASSES, (value: string, key: string) => props.url.indexOf(key) > 0);
    }

    return (
      <tr>
        <td>
          {/* If the URL matches its type or is just empty, display either a
              favicon or a prompt for a new link as appropriate. */
           showTypeSelection
            ? <LinkTypeSelect type={props.type} typeChangeCallback={props.typeChangeCallback}>
                {props.typeOptions}
              </LinkTypeSelect>
            : <label>
                {faviconClass && <span className={'favicon ' + faviconClass + '-favicon'}></span>}
                {(linkType ? (
                  backward
                    ? l_relationships(linkType.reverse_link_phrase)
                    : l_relationships(linkType.link_phrase)
                ) : null) ||
                  (props.isOnlyLink ? l('Add link:') : l('Add another link:'))}
              </label>}
        </td>
        <td>
          <input type="url"
                 className="value with-button"
                 value={props.url}
                 onChange={props.urlChangeCallback}
                 onBlur={props.urlBlurCallback} />
          {props.errorMessage && <div className="error field-error" data-visible="1">{props.errorMessage}</div>}
          {linkType && _.has(linkType.attributes, String(VIDEO_ATTRIBUTE_ID)) &&
            <div className="attribute-container">
              <label>
                <input type="checkbox" checked={props.video} onChange={props.videoChangeCallback} /> {l('video')}
              </label>
            </div>}
        </td>
        <td style={{minWidth: '34px'}}>
          {typeDescription && <HelpIcon content={typeDescription} />}
          {isEmpty(props) || <RemoveButton title={l('Remove Link')} callback={props.removeCallback} />}
        </td>
      </tr>
    );
  }
}

const defaultLinkState: LinkStateT = {
  url: '',
  type: null,
  relationship: null,
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
  var emptyCount = 0;
  var canRemove = {};

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
  } else {
    return links;
  }
}

const isVideoAttribute = attr => attr.type.gid === VIDEO_ATTRIBUTE_GID;

export function parseRelationships(relationships?: $ReadOnlyArray<RelationshipT>) {
  if (!relationships) {
    return [];
  }
  return relationships.reduce(function (accum, data) {
    var target = data.target;

    if (target.entityType === 'url') {
      accum.push({
        relationship: data.id,
        url: target.name,
        type: data.linkTypeID,
        video: data.attributes
          ? data.attributes.some(isVideoAttribute)
          : false,
      });
    }

    return accum;
  }, []);
}

var protocolRegex = /^(https?|ftp):$/;
var hostnameRegex = /^(([A-z\d]|[A-z\d][A-z\d\-]*[A-z\d])\.)*([A-z\d]|[A-z\d][A-z\d\-]*[A-z\d])$/;

function isValidURL(url) {
  var a = document.createElement("a");
  a.href = url;

  var hostname = a.hostname;

  if (url.indexOf(hostname) < 0) {
    return false;
  }

  if (!hostnameRegex.test(hostname)) {
    return false;
  }

  if (hostname.indexOf(".") < 0) {
    return false;
  }

  if (!protocolRegex.test(a.protocol)) {
    return false;
  }

  return true;
}

const URL_SHORTENERS = [
  "adf.ly",
  "bit.ly",
  "cli.gs",
  "deck.ly",
  "fur.ly",
  "goo.gl",
  "is.gd",
  "kl.am",
  "lnk.co",
  "mcaf.ee",
  "moourl.com",
  "owl.ly",
  "rubyurl.com",
  "su.pr",
  "t.co",
  "tiny.cc",
  "tinyurl.com",
  "u.nu",
  "yep.it",
].map(host => new RegExp("^https?://([^/]+\\.)?" + host + "/", "i"));

function isShortened(url) {
  return URL_SHORTENERS.some(function(shortenerRegex) {
    return url.match(shortenerRegex) !== null;
  });
}

type InitialOptionsT = {
  errorObservable?: (boolean) => void,
  mountPoint: Element,
  sourceData: CoreEntityT,
};

MB.createExternalLinksEditor = function (options: InitialOptionsT) {
  var sourceData = options.sourceData;
  var sourceType = sourceData.entityType;
  var entityTypes = [sourceType, 'url'].sort().join('-');
  var initialLinks = parseRelationships(sourceData.relationships);

  // Terribly get seeded URLs
  if (MB.formWasPosted) {
    if (hasSessionStorage) {
      let submittedLinks = window.sessionStorage.getItem('submittedLinks');
      if (submittedLinks) {
        initialLinks = JSON.parse(submittedLinks).filter(l => !isEmpty(l)).map(newLinkState);
      }
    }
  } else {
    var seededLinkRegex = new RegExp("(?:\\?|&)edit-" + sourceType + "\\.url\\.([0-9]+)\\.(text|link_type_id)=([^&]+)", "g");
    var urls = {};
    var match;

    while (match = seededLinkRegex.exec(window.location.search)) {
      (urls[match[1]] = urls[match[1]] || {})[match[2]] = decodeURIComponent(match[3]);
    }

    _.each(urls, function (data) {
      initialLinks.push(newLinkState({
        url: data.text || "",
        type: data.link_type_id,
        relationship: _.uniqueId('new-'),
      }));
    });
  }

  initialLinks.sort(function (a, b) {
    var typeA = a.type && linkedEntities.link_type[a.type];
    var typeB = b.type && linkedEntities.link_type[b.type];

    return compare(typeA ? l_relationships(typeA.link_phrase).toLowerCase() : '',
                   typeB ? l_relationships(typeB.link_phrase).toLowerCase() : '');
  });

  initialLinks = initialLinks.map(function (link) {
    // Only run the URL cleanup on seeded URLs, i.e. URLs that don't have an
    // existing relationship ID.
    if (!isPositiveInteger(link.relationship)) {
      return Object.assign({}, link, {
        relationship: _.uniqueId('new-'),
        url: URLCleanup.cleanURL(link.url) || link.url,
      });
    }
    return link;
  });

  var typeOptions = (
    linkTypeOptions({children: linkedEntities.link_type_tree[entityTypes]}, /^url-/.test(entityTypes))
      .map((data) => <option value={data.value} disabled={data.disabled} key={data.value}>{data.text}</option>)
  );

  var errorObservable = options.errorObservable || validation.errorField(ko.observable(false));

  return ReactDOM.render(
    <ExternalLinksEditor
      sourceType={sourceData.entityType}
      typeOptions={typeOptions}
      initialLinks={initialLinks}
      errorObservable={errorObservable} />,
    options.mountPoint
  );
};

export const createExternalLinksEditor = MB.createExternalLinksEditor;
