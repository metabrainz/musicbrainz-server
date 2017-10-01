const ReactTestUtils = require('react-dom/test-utils');

exports.triggerChange = function (node, value) {
    ReactTestUtils.Simulate.change(node, { target: { value: value } });
};

exports.triggerClick = function (node) {
    ReactTestUtils.Simulate.click(node);
};

exports.addURL = function (component, name) {
    var inputs = ReactTestUtils.scryRenderedDOMComponentsWithTag(component, 'input');
    exports.triggerChange(inputs[inputs.length - 1], name);
};
