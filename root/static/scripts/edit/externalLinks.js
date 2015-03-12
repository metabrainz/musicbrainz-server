// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var Immutable = require('immutable');
var React = require('react');
var PropTypes = React.PropTypes;
var validation = require('./validation.js');
var HelpIcon = require('./components/HelpIcon.js');
var RemoveButton = require('./components/RemoveButton.js');
var i18n = require('../common/i18n.js');
var URLCleanup = require('./MB/Control/URLCleanup.js');

require('react/addons');

var l = i18n.l;

var LinkState = Immutable.Record({
  url: '',
  type: null,
  relationship: null,
  video: false
});

var ExternalLinksEditor = React.createClass({
  mixins: [React.addons.PureRenderMixin],

  propTypes: {
    sourceType: PropTypes.string.isRequired,
    typeOptions: PropTypes.arrayOf(PropTypes.element).isRequired,
    initialLinks: PropTypes.instanceOf(Immutable.List).isRequired,
    errorObservable: function (props, propName) {
      if (propName === 'errorObservable' && !ko.isObservable(props[propName])) {
        return new Error('errorObservable should be an observable');
      }
    }
  },

  getInitialState: function () {
    return { links: withOneEmptyLink(this.props.initialLinks) };
  },

  setLinkState: function (index, state, callback) {
    this.setState({ links: withOneEmptyLink(this.state.links.mergeIn([index], state), index) }, callback);
  },

  handleUrlChange: function (index, event) {
    var url = event.target.value;
    var link = this.state.links.get(index);

    // Allow adding spaces while typing, they'll be trimmed on blur
    if (_.str.trim(url) !== _.str.trim(link.url)) {
      if (url.match(/^\w+\./)) {
          url = 'http://' + url;
      }
      url = URLCleanup.cleanUrl(url) || url;
    }

    this.setLinkState(index, { url: url }, () => {
      if (!link.type) {
        var type = URLCleanup.guessType(this.props.sourceType, url);

        if (type) {
          this.setLinkState(index, { type: MB.typeInfoByID[type].id });
        }
      }
    });
  },

  handleUrlBlur: function (index, event) {
    var url = event.target.value;
    var trimmed = _.str.trim(url);

    if (url !== trimmed) {
      this.setLinkState(index, { url: trimmed });
    }
  },

  handleTypeChange: function (index, event) {
    this.setLinkState(index, { type: +event.target.value || null });
  },

  handleVideoChange: function (index, event) {
    this.setLinkState(index, { video: event.target.checked });
  },

  removeLink: function (index) {
    this.setState({ links: this.state.links.remove(index) }, () => {
      $(this.getDOMNode()).find('tr:gt(' + (index - 1) + ') button.remove:first, ' +
                                'tr:lt(' + (index + 1) + ') button.remove:last')
                          .eq(0).focus();
    });
  },

  getEditData: function () {
    var oldLinks = _.indexBy(this.props.initialLinks.toJS(), 'relationship');
    var newLinks = _.indexBy(this.state.links.toJS(), 'relationship');
    return {
      oldLinks: oldLinks,
      newLinks: newLinks,
      allLinks: _.defaults(_.clone(newLinks), oldLinks)
    };
  },

  getFormData: function (startingPrefix, startingIndex, pushInput) {
    var index = 0;
    var backward = this.props.sourceType > 'url';
    var { newLinks, allLinks } = this.getEditData();

    _.each(allLinks, function (link, relationship) {
      if (!link.type) {
        return;
      }

      var prefix = startingPrefix + '.' + (startingIndex + (index++));

      if (isInteger(relationship)) {
        pushInput(prefix, 'relationship_id', relationship);

        if (!newLinks[relationship]) {
          pushInput(prefix, 'removed', 1);
        }
      }

      pushInput(prefix, 'text', link.url);

      if (link.video) {
        pushInput(prefix + '.attributes.0', 'type.gid', MB.constants.VIDEO_ATTRIBUTE_GID);
      }

      if (backward) {
        pushInput(prefix, 'backward', 1);
      }

      pushInput(prefix, 'link_type_id', link.type || '');
    });
  },

  render: function () {
    this.props.errorObservable(false);

    var linksArray = this.state.links.toArray();

    var linksByTypeAndUrl = _(linksArray).concat(this.props.initialLinks.toArray())
          .uniq((link) => link.relationship).groupBy(linkTypeAndUrlString).value();

    return (
      <table id="external-links-editor" className="row-form">
        <tbody>
          {linksArray.map((link, index) => {
            var error;
            var typeInfo = MB.typeInfoByID[link.type] || {};
            var checker = URLCleanup.validationRules[typeInfo.gid];

            if (isEmpty(link)) {
              error = '';
            } else if (!link.url) {
              error = l('Required field.');
            } else if (!MB.utility.isValidURL(link.url)) {
              error = l('Enter a valid url e.g. "http://google.com/"');
            } else if (!link.type) {
              error = l('Please select a link type for the URL you’ve entered.');
            } else if (typeInfo.deprecated && !isInteger(link.relationship)) {
              error = l('This relationship type is deprecated and should not be used.');
            } else if (checker && !checker(link.url)) {
              error = l('This URL is not allowed for the selected link type, or is incorrectly formatted.');
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
                isOnlyLink={this.state.links.size === 1}
                urlMatchesType={typeInfo.gid === URLCleanup.guessType(this.props.sourceType, link.url)}
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
});

var LinkTypeSelect = React.createClass({
  mixins: [React.addons.PureRenderMixin],

  propTypes: {
    type: PropTypes.number,
    typeChangeCallback: PropTypes.func.isRequired
  },

  render: function () {
    return (
      <select value={this.props.type} onChange={this.props.typeChangeCallback} className="link-type">
        <option value=""></option>
        {this.props.children}
      </select>
    );
  }
});

var ExternalLink = React.createClass({
  mixins: [React.addons.PureRenderMixin],

  propTypes: {
    url: PropTypes.string.isRequired,
    type: PropTypes.number,
    video: PropTypes.bool.isRequired,
    errorMessage: PropTypes.string.isRequired,
    isOnlyLink: PropTypes.bool.isRequired,
    urlMatchesType: PropTypes.bool.isRequired,
    removeCallback: PropTypes.func.isRequired,
    urlChangeCallback: PropTypes.func.isRequired,
    urlBlurCallback: PropTypes.func.isRequired,
    typeChangeCallback: PropTypes.func.isRequired,
    videoChangeCallback: PropTypes.func.isRequired,
    typeOptions: PropTypes.arrayOf(PropTypes.element).isRequired
  },

  render: function () {
    var props = this.props;
    var typeInfo = MB.typeInfoByID[props.type] || {};
    var typeDescription = '';
    var faviconClass;

    if (typeInfo.description) {
      typeDescription = l('{description} ({url|more documentation})', {
        description: typeInfo.description,
        url: '/relationship/' + typeInfo.gid
      });
    }

    if (props.url && !props.errorMessage) {
      var escapedURL = _.escape(props.url);
      typeDescription = '<a href="' + escapedURL + '" target="_blank">' + escapedURL + '</a><br><br>' + typeDescription;
    }

    var showTypeSelection = props.errorMessage ? true : !(props.urlMatchesType || isEmpty(props));
    if (!showTypeSelection && props.urlMatchesType) {
      faviconClass = _.find(MB.faviconClasses, (value, key) => props.url.indexOf(key) > 0);
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
                {typeInfo.phrase || (props.isOnlyLink ? l('Add link:') : l('Add another link:'))}
              </label>}
        </td>
        <td>
          <input type="url"
                 className="value with-button"
                 value={props.url}
                 onChange={props.urlChangeCallback}
                 onBlur={props.urlBlurCallback} />
          {props.errorMessage && <div className="error field-error" data-visible="1">{props.errorMessage}</div>}
          {_.has(typeInfo.attributes, MB.constants.VIDEO_ATTRIBUTE_ID) &&
            <div className="attribute-container">
              <label>
                <input type="checkbox" checked={props.video} onChange={props.videoChangeCallback} /> {l('video')}
              </label>
            </div>}
        </td>
        <td style={{minWidth: '34px'}}>
          {typeDescription && <HelpIcon html={typeDescription} />}
          {isEmpty(props) || <RemoveButton title={l('Remove Link')} callback={props.removeCallback} />}
        </td>
      </tr>
    );
  }
});

function isInteger(value) {
  return /^[0-9]+$/.test(value);
}

function linkTypeAndUrlString(link) {
  return link.type + '\0' + link.url;
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
    return links.push(new LinkState({ relationship: _.uniqueId('new-') }));
  } else if (emptyCount > 1 && _.size(canRemove)) {
    return links.filter((link, index) => !canRemove[index]);
  } else {
    return links;
  }
}

function parseRelationships(relationships) {
  return _.transform(relationships || [], function (accum, data) {
    var target = data.target;

    if (target.entityType === 'url') {
      accum.push(new LinkState({
        relationship: data.id,
        url: target.name,
        type: data.linkTypeID,
        video: _.any(data.attributes, (attr) => attr.type.gid === MB.constants.VIDEO_ATTRIBUTE_GID)
      }));
    }
  });
}

MB.createExternalLinksEditor = function (options) {
  var sourceData = options.sourceData;
  var sourceType = sourceData.entityType;
  var entityTypes = [sourceType, 'url'].sort().join('-');
  var initialLinks = parseRelationships(sourceData.relationships);

  // Terribly get seeded URLs
  if (MB.formWasPosted) {
    if (MB.hasSessionStorage && sessionStorage.submittedLinks) {
      initialLinks = JSON.parse(sessionStorage.submittedLinks).filter(l => !isEmpty(l)).map(LinkState);
    }
  } else {
    var seededLinkRegex = new RegExp("(?:\\?|&)edit-" + sourceType + "\\.url\\.([0-9]+)\\.(text|link_type_id)=([^&]+)", "g");
    var urls = {};
    var match;

    while (match = seededLinkRegex.exec(window.location.search)) {
      (urls[match[1]] = urls[match[1]] || {})[match[2]] = decodeURIComponent(match[3]);
    }

    _.each(urls, function (data) {
      initialLinks.push(new LinkState({ url: data.text || "", type: data.link_type_id, relationship: _.uniqueId('new-') }));
    });
  }

  initialLinks.sort(function (a, b) {
    var typeA = MB.typeInfoByID[a.type];
    var typeB = MB.typeInfoByID[b.type];

    return i18n.compare(typeA ? typeA.phrase.toLowerCase() : '',
                        typeB ? typeB.phrase.toLowerCase() : '');
  });

  initialLinks = initialLinks.map(function (link) {
    var newData = {url: URLCleanup.cleanUrl(link.url) || link.url};
    if (!_.isNumber(link.relationship)) {
      newData.relationship = _.uniqueId('new-');
    }
    return link.merge(newData);
  });

  var typeOptions = (
    MB.forms.linkTypeOptions({ children: MB.typeInfo[entityTypes] }, /^url-/.test(entityTypes))
      .map((data) => <option value={data.value} disabled={data.disabled} key={data.value}>{data.text}</option>)
  );

  var errorObservable = options.errorObservable || validation.errorField(ko.observable(false));

  return React.render(
    <ExternalLinksEditor
      sourceType={sourceData.entityType}
      typeOptions={typeOptions}
      initialLinks={Immutable.List(initialLinks)}
      errorObservable={errorObservable} />,
    options.mountPoint
  );
};

exports.ExternalLinksEditor = ExternalLinksEditor;
exports.ExternalLink = ExternalLink;
exports.parseRelationships = parseRelationships;
exports.createExternalLinksEditor = MB.createExternalLinksEditor;
