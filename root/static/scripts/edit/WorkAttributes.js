MB.WorkAttributes = (function(WA) {

// Private variables
var attributeTypes;

// Private classes
var ViewModel;

WA.init = function(config) {
    attributeTypes = config;

    WA.viewModel = new ViewModel(config);
    ko.applyBindings(WA.viewModel, document.getElementById('work_attributes'));

    return WA;
};

WA.WorkAttribute = function(typeId, value, valueErrors) {
    var self = this;

    self.typeId = ko.observable(typeId + "");
    self.attributeValue = ko.observable(value);
    self.errors = ko.observableArray(valueErrors);

    self.allowsFreeText = ko.computed(function() {
        return !self.typeId() || attributeTypes[self.typeId()].allowsFreeText;
    });
    self.allowedValues = ko.computed(function() {
        if (self.allowsFreeText()) {
            return [];
        }
        else {
            return [null].concat(_.keys(attributeTypes[self.typeId()].values));
        }
    });
    self.valueFormatter = formatNullAsEmpty(
        function(item) {
            return attributeTypes[self.typeId()].values[item];
        }
    );
    self.remove = function() {
        MB.WorkAttributes.viewModel.attributes.remove(this);
    };

    function resetErrors() { debugger; self.errors([]) };

    self.typeId.subscribe(function() {
        self.attributeValue("");
        resetErrors();
    });
    self.attributeValue.subscribe(function() {
        resetErrors();
    });

    return self;
};

ViewModel = function () {
    var model = {};
    model.attributes = ko.observableArray();

    model.attributeTypes = ko.computed(function() {
        return [null].concat(_.keys(attributeTypes));
    });
    model.formatAttributeType = formatNullAsEmpty(
        function (item) {
            return attributeTypes[item].name;
        }
    );

    model.newAttribute = function() {
        model.attributes.push(new WA.WorkAttribute("", ""));
    };

    return model;
};

return WA;

function formatNullAsEmpty(f) {
    return function (x) {
        if (x === null) {
            return "";
        }
        else {
            return f(x);
        }
    }
}

}(MB.WorkAttributes || {}));
