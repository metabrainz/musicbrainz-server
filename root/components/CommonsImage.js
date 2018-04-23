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

import {l} from '../static/scripts/common/i18n';
import hydrate from '../utility/hydrate';

type Props = {|
  +image: CommonsImageT | null,
  +imageEndpoint: string,
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
      $.get(this.props.imageEndpoint, data => {
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
