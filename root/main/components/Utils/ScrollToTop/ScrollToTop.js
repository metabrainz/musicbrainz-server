import React, { Component } from "react";
import PropTypes from "prop-types";

export default class ScrollToTop extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hovered: false,
      styles: {
        ...props.position,
        position: "fixed",
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
        text: props.text ? props.text : "",
        transition: props.transition,
        cursor: props.cursor,
        outline: props.outline,
        zIndex: props.zIndex
      },
      show: false
    };
  }

  componentDidMount() {
    window.addEventListener("scroll", this.handleScroll);
    const { show } = this.state;
    if (!show) {
      this.hideButton();
    } else {
      this.showButton();
    }
  }

  componentWillUnmount() {
    window.removeEventListener("scroll", this.handleScroll);
  }

  handleScroll = () => {
    this.setState({ show: true });
    const { showOnDistance } = this.props;
    const scrollY = window.scrollY;

    scrollY >= (showOnDistance >= 0 ? showOnDistance : 300)
      ? this.showButton()
      : this.hideButton();
  };

  handleOnClick = () => {
    const { scrollBehavior } = this.state.styles;
    window.scrollTo({
      top: 0,
      behavior: scrollBehavior
    });
  };

  handleOnHover = hovered => {
    this.setState({
      ...this.state,
      hovered
    });
  };

  showButton = () => {
    if (!this.ref) return;
    this.ref.style.display = "";
  };

  hideButton = () => {
    if (!this.ref) return;
    this.ref.style.display = "none";
  };

  render() {
    const { icon, text } = this.state.styles;

    return (
      <button
        ref={btn => {
          this.ref = btn;
        }}
        onMouseOver={() => this.handleOnHover(true)}
        onMouseOut={() => this.handleOnHover(false)}
        onClick={this.handleOnClick}
        style={
          this.state.hovered
            ? { ...this.state.styles, ...this.props.hover }
            : this.state.styles
        }
        className={`${icon ? icon : ""}`}
      >
        {text}
      </button>
    );
  }
}

ScrollToTop.defaultProps = {
  icon: "",
  position: {
    bottom: "0%",
    right: "0%"
  },
  color: "white",
  backgroundColor: "black",
  hover: {
    color: "white",
    backgroundColor: "black",
    opacity: "0.9"
  },
  borderRadius: 48,
  margin: "10px",
  fontSize: "18px",
  padding: "12px",
  opacity: "1",
  border: "none",
  text: "",
  cursor: "pointer",
  outline: "none",
  scrollBehavior: "smooth",
  transition: "none",
  showOnDistance: 300,
  zIndex: 999
};

ScrollToTop.propTypes = {
  icon: PropTypes.string,
  color: PropTypes.string,
  backgroundColor: PropTypes.string,
  hover: PropTypes.shape({
    color: PropTypes.string,
    backgroundColor: PropTypes.string,
    opacity: PropTypes.string
  }),
  position: PropTypes.shape({
    top: PropTypes.string,
    bottom: PropTypes.string,
    left: PropTypes.string,
    right: PropTypes.string
  }),
  margin: PropTypes.string,
  padding: PropTypes.string,
  transition: PropTypes.string,
  fontSize: PropTypes.string,
  cursor: PropTypes.string,
  outline: PropTypes.string,
  scrollBehavior: PropTypes.string,
  border: PropTypes.string,
  opacity: PropTypes.string,
  borderRadius: PropTypes.number,
  showOnDistance: PropTypes.number,
  zIndex: PropTypes.number
};
