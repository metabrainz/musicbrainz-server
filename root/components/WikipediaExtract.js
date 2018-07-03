/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import React from 'react';

import {l} from '../static/scripts/common/i18n';
import entityHref from '../static/scripts/common/utility/entityHref';
import hydrate from '../utility/hydrate';

import Collapsible from './Collapsible';
import Frag from './Frag';

type Props = {|
  +entity: CoreEntityT,
  +wikipediaExtract: WikipediaExtractT | null,
|};

type State = {|
  wikipediaExtract: WikipediaExtractT | null,
|};

class WikipediaExtract extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {wikipediaExtract: null};
  }

  static getDerivedStateFromProps(nextProps: Props) {
    return {wikipediaExtract: nextProps.wikipediaExtract};
  }

  componentDidMount() {
    if (!this.state.wikipediaExtract) {
      $.get(entityHref(this.props.entity, '/wikipedia-extract'), data => {
        this.setState(data);
      });
    }
  }

  render() {
    const {wikipediaExtract} = this.state;
    return wikipediaExtract ? (
      <Frag>
        <h2 className="wikipedia">{l('Wikipedia')}</h2>
        <Collapsible
          className="wikipedia-extract"
          html={wikipediaExtract.content}
        />
        <a href={wikipediaExtract.url}>
          {l('Continue reading at Wikipedia...')}
        </a>
        <small>
          {l('Wikipedia content provided under the terms of the {license_link|Creative Commons BY-SA license}',
            {__react: true, license_link: 'https://creativecommons.org/licenses/by-sa/3.0/'})}
        </small>
      </Frag>
    ) : null;
  }
}

export default hydrate('wikipedia-extract', WikipediaExtract);
