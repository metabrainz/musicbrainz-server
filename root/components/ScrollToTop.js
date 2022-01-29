/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Component} from 'react';

export default class ScrollToTop extends Component<Props> {
static defaultProps = {
  backgroundColor: 'black',
  border: 'none',
  borderRadius: 48,
  color: 'white',
  cursor: 'pointer',
  fontSize: '18px',
  hover: {
    backgroundColor: 'black',
    color: 'white',
    opacity: '0.9',
  },
  icon: '',
  margin: '10px',
  opacity: '1',
  outline: 'none',
  padding: '12px',
  position: {
    bottom: '0%',
    right: '0%',
  },
  scrollBehavior: 'smooth',
  showOnDistance: 300,
  text: '',
  transition: 'none',
  zIndex: 999,
};

constructor(props) {
  super(props);
  this.state = {
    hovered: false,
    styles: {
      ...props.position,
      position: 'fixed',
      fontSize: props.fontSize,
      padding: props.padding,
      margin: props.margin,
      icon: props.icon,
      backgroundColor: props.backgroundColor,
      borderRadius: props.borderRadius,
      border: props.border,
      color: props.color,
      scrollBehavior: props.scrollBehavior,
      opacity: props.opacity,
      text: props.text ? props.text : '',
      transition: props.transition,
      cursor: props.cursor,
      outline: props.outline,
      zIndex: props.zIndex,
    },
    show: false,
  };
}

componentDidMount() {
  window.addEventListener('scroll', this.handleScroll);
  const {show} = this.state;
  if (show) {
    this.showButton();
  } else {
    this.hideButton();
  }
}

componentWillUnmount() {
  window.removeEventListener('scroll', this.handleScroll);
}

  handleScroll = () => {
    this.setState({show: true});
    const {showOnDistance} = this.props;
    const scrollY = window.scrollY;

    scrollY >= (showOnDistance >= 0 ? showOnDistance : 300)
      ? this.showButton()
      : this.hideButton();
  };

  handleOnClick = () => {
    const {scrollBehavior} = this.state.styles;
    window.scrollTo({
      top: 0,
      behavior: scrollBehavior,
    });
  };

  handleOnHover = hovered => {
    this.setState({
      ...this.state,
      hovered,
    });
  };

  showButton = () => {
    if (!this.ref) {
      return;
    }
    this.ref.style.display = '';
  };

  hideButton = () => {
    if (!this.ref) {
      return;
    }
    this.ref.style.display = 'none';
  };

  render() {
    const {icon, text} = this.state.styles;

    return (
      <button
        className={`${icon ? icon : ''}`}
        onClick={this.handleOnClick}
        onMouseOut={() => this.handleOnHover(false)}
        onMouseOver={() => this.handleOnHover(true)}
        ref={btn => {
          this.ref = btn;
        }}
        style={
          this.state.hovered
            ? {...this.state.styles, ...this.props.hover}
            : this.state.styles
        }
        type="button"
      >
        {text}
      </button>
    );
  }
}

type Props = {
  backgroundColor: string,
  border: string,
  borderRadius: number,
  color: string,
  cursor: string,
  fontSize: string,
  hover: {
    backgroundColor: string,
    color: string,
    opacity: string,
  },
  icon: string,
  margin: string,
  opacity: string,
  outline: string,
  padding: string,
  position: {
    bottom: string,
    left: string,
    right: string,
    top: string,
  },
  scrollBehavior: string,
  showOnDistance: number,
  transition: string,
  zIndex: number,
};
