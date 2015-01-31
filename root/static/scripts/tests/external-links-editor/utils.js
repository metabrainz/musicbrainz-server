var React = require('react');

require('react/addons');

exports.triggerChange = function (node, value) {
    React.addons.TestUtils.Simulate.change(node, { target: { value: value } });
};

exports.addURL = function (component, name) {
    var inputs = React.addons.TestUtils.scryRenderedDOMComponentsWithTag(component, 'input');
    exports.triggerChange(inputs[inputs.length - 1], name);
};
