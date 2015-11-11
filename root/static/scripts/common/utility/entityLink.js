// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';
import {l} from '../i18n';

export default function entityLink(entity, props) {
  props = props || {};

  if (!props.hasOwnProperty('title')) {
    props.title = entity.sortName;
  }

  let elements = [
    <a href={'/' + entity.entityType + '/' + entity.gid} {...props}>
      <bdi>{props.name || entity.name}</bdi>
    </a>
  ];

  if (entity.comment) {
    elements.push(' ');
    elements.push(<span className="comment">{'(' + entity.comment + ')'}</span>);
  }

  if (entity.video) {
    elements.push(' ');
    elements.push(<span className="comment">{l('(video)')}</span>);
  }

  if (entity.editsPending) {
    return <span className="mp">{elements}</span>;
  }

  return elements;
}
