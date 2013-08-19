MB.WorkAttributes = (function(WA) {

// Private variables
var attributeTypes;

// Private classes
var ViewModel, WorkAttribute, WorkAttributeType;

WA.init = function(config) {
    attributeTypes = config;

    WA.viewModel = new ViewModel(config);
    ko.applyBindings(WA.viewModel);
};

WorkAttribute = function(typeId) {
    var self = this;

    self.typeId = ko.observable(typeId);
    self.allowsFreeText = ko.computed(function() {
        return !self.typeId() || attributeTypes[self.typeId()].allowsFreeText;
    });
    self.allowedValues = ko.computed(function() {
        if (self.allowsFreeText()) {
            return [];
        }
        else {
            return _.keys(attributeTypes[self.typeId()].values);
        }
    });
    self.valueFormatter = function(item) {
        return attributeTypes[self.typeId()].values[item];
    };

    return self;
};

ViewModel = function () {
    var model = {};
    model.attributes = ko.observableArray();

    model.attributeTypes = ko.computed(function() {
        return _.keys(attributeTypes);
    });
    model.formatAttributeType = function(item) {
        return attributeTypes[item].name;
    };

    model.newAttribute = function() {
        model.attributes.push(new WorkAttribute(undefined));
    };

    return model;
};

return WA;

}(MB.WorkAttributes || {}));
