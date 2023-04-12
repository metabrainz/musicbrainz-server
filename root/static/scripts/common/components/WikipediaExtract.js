/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import entityHref from '../utility/entityHref.js';

import Collapsible from './Collapsible.js';

type EntityWithWikipediaExtractT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | ReleaseGroupT
  | SeriesT
  | WorkT;

type MinimalEntityWithWikipediaExtractT = {
  +entityType: EntityWithWikipediaExtractT['entityType'],
  +gid: string,
};

type Props = {
  +cachedWikipediaExtract: WikipediaExtractT | null,
  +entity:
    | EntityWithWikipediaExtractT
    | MinimalEntityWithWikipediaExtractT,
};

type State = {
  wikipediaExtract: WikipediaExtractT | null,
};

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

  render(): React$MixedElement | null {
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
          {exp.l(
            `Wikipedia content provided under the terms of the
             {license_link|Creative Commons BY-SA license}`,
            {license_link: 'https://creativecommons.org/licenses/by-sa/3.0/'},
          )}
        </small>
      </>
    ) : null;
  }
}

export default (hydrate<Props>(
  'div.wikipedia-extract',
  WikipediaExtract,
  minimalEntity,
): React$AbstractComponent<Props, void>);
