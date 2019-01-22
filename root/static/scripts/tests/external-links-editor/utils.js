import ReactTestUtils from 'react-dom/test-utils';

export function triggerChange(node, value) {
  ReactTestUtils.Simulate.change(node, { target: { value: value } });
}

export function triggerClick(node) {
  ReactTestUtils.Simulate.click(node);
};

export function addURL(component, name) {
  var inputs = ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'input');
  triggerChange(inputs[inputs.length - 1], name);
};
