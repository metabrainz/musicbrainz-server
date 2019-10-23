/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {ElementRef} from 'react';


type Props = {
  +className: string,
  +html: string,
};

type State = {
  isCollapsed: boolean,
  isCollapsible: boolean,
};

class Collapsible extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      isCollapsed: false,
      isCollapsible: false,
    };
    this.handleToggle = this.handleToggle.bind(this);
    this.containerRef = React.createRef();
  }

  componentDidMount() {
    const container = this.containerRef.current;
    if (container && container.offsetHeight > 100) {
      this.setState(() => ({
        isCollapsed: true,
        isCollapsible: true,
      }));
    }
  }

  containerRef: {current: null | ElementRef<'div'>};

  handleToggle: (event: SyntheticEvent<HTMLAnchorElement>) => void;

  handleToggle(event: SyntheticEvent<HTMLAnchorElement>) {
    event.preventDefault();
    this.setState(prevState => ({
      isCollapsed: !prevState.isCollapsed,
    }));
  }

  render() {
    const {className, html} = this.props;
    const {isCollapsed, isCollapsible} = this.state;

    const _className =
      className + '-body ' +
      className + (isCollapsed ? '-collapsed' : '-collapse');

    return (
      <>
        <div
          className={_className}
          dangerouslySetInnerHTML={{__html: html}}
          ref={this.containerRef}
        />
        {isCollapsible ? (
          <p>
            <a
              className={className + '-toggle'}
              href="#"
              onClick={this.handleToggle}
            >
              {isCollapsed ? l('Show more...') : l('Show less...')}
            </a>
          </p>
        ) : null}
      </>
    );
  }
}

export default Collapsible;
