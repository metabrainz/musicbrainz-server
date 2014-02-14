MB.WorkAttributes = (function(WA) {

// Private variables
var attributeTypes;

// Private classes
var ViewModel;

WA.init = function (config) {
    attributeTypes = config.attributeTypes;

    WA.viewModel = new ViewModel(config.attributes);
    ko.applyBindings(WA.viewModel, document.getElementById('work_attributes'));
};

WA.WorkAttribute = function (data) {
    var self = this;

    self.typeID = ko.observable(data.typeID);
    self.attributeValue = ko.observable(data.value);
    self.errors = ko.observableArray(data.errors);

    self.allowsFreeText = ko.computed(function() {
        return !self.typeID() || attributeTypes[self.typeID()].allowsFreeText;
    });

    self.allowedValues = ko.computed(function () {
        if (self.allowsFreeText()) {
            return [];
        }
        else {
            return _.keys(attributeTypes[self.typeID()].values);
        }
    });

    self.valueFormatter = function(item) {
        return attributeTypes[self.typeID()].values[item];
    };

    self.remove = function() {
        WA.viewModel.attributes.remove(this);
    };

    function resetErrors() { self.errors([]) };

    self.typeID.subscribe(function (newTypeID) {
        // != is used intentionally for type coercion.
        if (self.typeID() != newTypeID) {
            self.attributeValue("");
            resetErrors();
        }
    });

    self.attributeValue.subscribe(function() {
        resetErrors();
    });

    return self;
};

ViewModel = function (attributes) {
    var model = {};

    attributes = _.map(attributes || [], function (data) {
        return new WA.WorkAttribute(data);
    });

    model.attributes = ko.observableArray(attributes);

    model.attributeTypes = _.keys(attributeTypes);

    model.formatAttributeType = function (item) {
        return attributeTypes[item].name;
    };

    model.newAttribute = function() {
        model.attributes.push(new WA.WorkAttribute({}));
    };

    if (!attributes.length) {
        model.newAttribute();
    }

    return model;
};

return WA;

}(MB.WorkAttributes || {}));
