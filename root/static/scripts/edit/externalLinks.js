// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var Immutable = require('immutable');
var React = require('react');
var PropTypes = React.PropTypes;

require('react/addons');

var validation = require('./validation.js');

var l = MB.i18n.l;
var selectLinkTypeText = l("Please select a link type for the URL you’ve entered.");

var LinkState = Immutable.Record({
  url: '',
  type: null,
  relationship: null,
  video: false
});

var ExternalLinksEditor = React.createClass({
  mixins: [React.addons.PureRenderMixin],

  propTypes: {
    cleanup: PropTypes.object.isRequired,
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

  removeLink: function (index) {
    var nextIndex = index === this.state.links.size - 1 ? index - 1 : index;

    this.setState({ links: this.state.links.remove(index) }, () => {
      $(this.getDOMNode()).find('tr:eq(' + nextIndex + ') :input:visible:first').focus();
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
    var backward = this.props.cleanup.sourceType > 'url';
    var { newLinks, allLinks } = this.getEditData();

    _.each(allLinks, function (link, relationship) {
      if (!link.type) {
        return;
      }

      var prefix = startingPrefix + '.' + (startingIndex + (index++));

      if (/^[0-9]+$/.test(relationship)) {
        pushInput(prefix, 'relationship_id', relationship);

        if (!newLinks[relationship]) {
          pushInput(prefix, 'removed', 1);
        }
      }

      pushInput(prefix, 'text', link.url);

      if (link.video) {
        pushInput(prefix + '.attributes.0', 'type.gid', VIDEO_ATTRIBUTE_GID);
      }

      if (backward) {
        pushInput(prefix, 'backward', 1);
      }

      pushInput(prefix, 'link_type_id', link.type || '');
    });
  },

  render: function () {
    this.props.errorObservable(false);
    return (
      <table id="external-links-editor" className="row-form">
        <tbody>
          {this.state.links.toArray().map((link, index) => {
            return (
              <ExternalLink
                {...this.props}
                key={link.relationship}
                url={link.url}
                type={link.type}
                video={link.video}
                supportsVideoAttribute={!!((MB.typeInfoByID[link.type] || {}).attributes || {})[MB.constants.VIDEO_ATTRIBUTE_ID]}
                isOnlyLink={this.state.links.size === 1}
                errorCallback={(hasError) => {
                  if (hasError) {
                    this.props.errorObservable(true);
                  }
                }}
                removeCallback={_.bind(this.removeLink, this, index)}
                duplicateCallback={(target) =>
                  this.props.initialLinks.concat(this.state.links).some(function (other) {
                    return (
                      link.relationship !== other.relationship &&
                      link.url === other.url &&
                      link.type === other.type
                    );
                  })
                }
                setLinkState={(linkState, callback) =>
                  this.setState({ links: withOneEmptyLink(this.state.links.mergeIn([index], linkState), index) }, callback)
                }
              />
            );
          })}
        </tbody>
      </table>
    );
  }
});

var linkTypePropType = PropTypes.oneOfType([PropTypes.number,PropTypes.oneOf([null])]).isRequired;

var LinkTypeSelect = React.createClass({

  propTypes: {
    type: linkTypePropType,

    setLinkState: PropTypes.func.isRequired,
    updateTooltip: PropTypes.func.isRequired
  },

  typeChanged: function (event) {
    this.props.setLinkState({ type: +event.target.value || null }, () => {
      this.props.updateTooltip();
    });
  },

  render: function () {
    return (
      <select value={this.props.type} onChange={this.typeChanged} className="link-type">
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
    type: linkTypePropType,
    video: PropTypes.bool.isRequired,
    supportsVideoAttribute: PropTypes.bool.isRequired,
    isOnlyLink: PropTypes.bool.isRequired,
    errorCallback: PropTypes.func.isRequired,
    removeCallback: PropTypes.func.isRequired,
    duplicateCallback: PropTypes.func.isRequired,
    setLinkState: PropTypes.func.isRequired
  },

  urlChanged: function (event) {
    var url = event.target.value;
    var cleanup = this.props.cleanup;

    // Allow adding spaces while typing, they'll be trimmed on blur
    if (_.str.trim(url) !== _.str.trim(this.props.url)) {
      if (url.match(/^\w+\./)) {
          url = 'http://' + url;
      }
      url = cleanup.cleanUrl(cleanup.sourceType, url) || url;
    }

    this.props.setLinkState({ url: url }, () => {
      var errorMessage = this.errorMessage();

      if (!errorMessage || errorMessage === selectLinkTypeText) {
        var type = cleanup.guessType(cleanup.sourceType, url);

        if (type) {
          this.props.setLinkState({ type: MB.typeInfoByID[type].id }, () => {
            this.updateTooltip();
          });
        }
      }
    });
  },

  urlBlurred: function (event) {
    var url = event.target.value;
    var trimmed = _.str.trim(url);

    if (url !== trimmed) {
      this.props.setLinkState({ url: trimmed });
    }
  },

  typeDescription: function () {
    var typeInfo = MB.typeInfoByID[this.props.type];

    if (typeInfo) {
      return l('{description} ({url|more documentation})', {
        description: typeInfo.description,
        url: '/relationship/' + typeInfo.gid
      })
    }

    return '';
  },

  errorMessage: function () {
    var props = this.props;

    if (isEmpty(props)) {
      return '';
    }

    var url = props.url;
    var type = props.type;

    if (!url) {
      return l('Required field.');
    } else if (!MB.utility.isValidURL(url)) {
      return l('Enter a valid url e.g. "http://google.com/"');
    }

    var typeInfo = MB.typeInfoByID[type] || {};
    var checker = props.cleanup.validationRules[typeInfo.gid];

    if (!type) {
      return selectLinkTypeText;
    } else if (typeInfo.deprecated && !this.id) {
      return l('This relationship type is deprecated and should not be used.');
    } else if (checker && !checker(url)) {
      return l('This URL is not allowed for the selected link type, or is incorrectly formatted.');
    }

    if (props.duplicateCallback()) {
      return l('This relationship already exists.');
    }

    return '';
  },

  render: function () {
    var props = this.props;
    var typeInfo = props.type && MB.typeInfoByID[props.type];
    var matchesType = ((typeInfo && typeInfo.gid) === props.cleanup.guessType(props.cleanup.sourceType, props.url));

    var errorMessage = this.errorMessage();
    var showTypeSelection = !!errorMessage || !(matchesType || isEmpty(props));
    var faviconClass = _.find(MB.faviconClasses, (value, key) => props.url.indexOf(key) > 0);

    props.errorCallback(!!errorMessage);

    return (
      <tr>
        <td>
          {/* If the URL matches its type or is just empty, display either a
              favicon or a prompt for a new link as appropriate. */
           showTypeSelection
            ? <LinkTypeSelect type={props.type} setLinkState={props.setLinkState} updateTooltip={this.updateTooltip}>
                {props.typeOptions}
              </LinkTypeSelect>
            : <label>
                {matchesType && faviconClass && <span className={'favicon ' + faviconClass + '-favicon'}></span>}
                {(typeInfo && typeInfo.phrase) || (props.isOnlyLink ? l('Add link:') : l('Add another link:'))}
              </label>}
        </td>
        <td>
          <input type="url" className="value with-button" value={props.url} onChange={this.urlChanged} onBlur={this.urlBlurred} />
          {errorMessage && <div className="error field-error" data-visible="1">{errorMessage}</div>}
          {props.supportsVideoAttribute &&
            <div className="attribute-container">
              <label>
                <input type="checkbox" checked={props.video} onChange={_.partial(props.setLinkState, { video: !props.video }, null)} /> {l('video')}
              </label>
            </div>}
        </td>
        <td style={{whiteSpace: 'nowrap'}}>
          {props.type && <div ref="help" className="img icon help" data-tooltip={this.typeDescription()}></div>}
          {isEmpty(props) ||
            <button type="button" className="nobutton remove" onClick={props.removeCallback}>
              <div className="remove-item icon img" title={l('Remove Link')}></div>
            </button>}
        </td>
      </tr>
    );
  },

  componentDidMount: function () {
    this.updateTooltip();
  },

  updateTooltip: function () {
    if (!this.refs.help) {
      return;
    }
    var $help = $(this.refs.help.getDOMNode());
    var content = $help.attr('data-tooltip');

    if ($help.data('ui-tooltip')) {
      $help.tooltip('option', 'content', content)

      if (!content) {
        return $help.tooltip('close');
      }
    }

    $help.tooltip({
      items: 'div.icon.help',
      content: content,
      open: function (event, ui) {
        ui.tooltip.find('a').attr('target', '_blank');
      },
      close: function (event, ui) {
        ui.tooltip.hover(
          function () {
            $(this).stop(true).fadeTo(400, 1);
          },
          function () {
            $(this).fadeOut("400", function () { $(this).remove() });
          }
        );
      }
    });
  }
});

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
      initialLinks = JSON.parse(sessionStorage.submittedLinks);
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

  var typeOptions = (
    MB.forms.linkTypeOptions({ children: MB.typeInfo[entityTypes] }, /^url-/.test(entityTypes))
      .map((data) => <option value={data.value} disabled={data.disabled} key={data.value}>{data.text}</option>)
  );

  var errorObservable = validation.errorField(ko.observable(false));

  return React.render(
    <ExternalLinksEditor
      cleanup={MB.Control.URLCleanup({ sourceType: sourceData.entityType, typeInfoByID: MB.typeInfoByID })}
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
