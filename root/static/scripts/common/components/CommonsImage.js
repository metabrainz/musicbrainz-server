/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import entityHref from '../utility/entityHref.js';

type Props = {
  +cachedImage: ?CommonsImageT,
  +entity: CoreEntityT,
};

type State = {
  image: ?CommonsImageT,
};

class CommonsImage extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {image: props.cachedImage};
  }

  componentDidMount() {
    if (!this.state.image) {
      const $ = require('jquery');
      $.get(entityHref(this.props.entity, '/commons-image'), data => {
        this.setState({image: data.image});
      });
    }
  }

  render(): React.MixedElement | null {
    const {image} = this.state;
    return image ? (
      <div className="picture">
        <img src={image.thumb_url} />
        <br />
        <span className="picture-note">
          <a href={image.page_url}>
            {l('Image from Wikimedia Commons')}
          </a>
        </span>
      </div>
    ) : null;
  }
}

export default (hydrate<Props>(
  'div.commons-image',
  CommonsImage,
  minimalEntity,
): React.AbstractComponent<Props, void>);
