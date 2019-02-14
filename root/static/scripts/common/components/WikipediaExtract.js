/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import hydrate, {minimalEntity} from '../../../../utility/hydrate';
import {l} from '../i18n';
import entityHref from '../utility/entityHref';

import Collapsible from './Collapsible';

type Props = {|
  +entity: CoreEntityT,
  +cachedWikipediaExtract: WikipediaExtractT | null,
|};

type State = {|
  wikipediaExtract: WikipediaExtractT | null,
|};

class WikipediaExtract extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {wikipediaExtract: props.cachedWikipediaExtract};
  }

  componentDidMount() {
    if (!this.state.wikipediaExtract) {
      const $ = require('jquery');
      $.get(entityHref(this.props.entity, '/wikipedia-extract'), data => {
        this.setState(data);
      });
    }
  }

  render() {
    const {wikipediaExtract} = this.state;
    return wikipediaExtract ? (
      <>
        <h2 className="wikipedia">{l('Wikipedia')}</h2>
        <Collapsible
          className="wikipedia-extract"
          html={wikipediaExtract.content}
        />
        <a href={wikipediaExtract.url}>
          {l('Continue reading at Wikipedia...')}
        </a>
        {' '}
        <small>
          {l('Wikipedia content provided under the terms of the {license_link|Creative Commons BY-SA license}',
            {license_link: 'https://creativecommons.org/licenses/by-sa/3.0/'})}
        </small>
      </>
    ) : null;
  }
}

export default hydrate<Props>('wikipedia-extract', WikipediaExtract, minimalEntity);
