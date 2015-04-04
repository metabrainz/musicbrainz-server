// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var React = require('react');
var i18n = require('../../common/i18n.js');

class EntityLink extends React.Component {
  render() {
    var {entity, ...linkProps} = this.props;

    if (!linkProps.hasOwnProperty('title')) {
      linkProps.title = entity.sortName;
    }

    return (
      <span className={entity.editsPending ? 'mp' : null}>
        <a href={'/' + entity.entityType + '/' + entity.gid} {...linkProps}>
          <bdi>{entity.name}</bdi>
        </a>
        {' '}
        {entity.comment && <span className="comment">{'(' + entity.comment + ')'}</span>}
        {' '}
        {entity.video && <span className="comment">{i18n.l('(video)')}</span>}
      </span>
    );
  }
}

module.exports = EntityLink;
