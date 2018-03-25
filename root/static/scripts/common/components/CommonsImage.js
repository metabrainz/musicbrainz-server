/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import React from 'react';

import hydrate from '../../../../utility/hydrate';
import {l} from '../i18n';
import entityHref from '../utility/entityHref';

type Props = {|
  +image: ?CommonsImageT,
  +entity: CoreEntityT,
|};

type State = {|
  image: CommonsImageT | null,
|};

class CommonsImage extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {image: null};
  }

  static getDerivedStateFromProps(nextProps: Props) {
    return {image: nextProps.image};
  }

  componentDidMount() {
    if (!this.state.image) {
      $.get(entityHref(this.props.entity, '/commons-image'), data => {
        this.setState({image: data.image});
      });
    }
  }

  render() {
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

export default hydrate('commons-image', CommonsImage);
