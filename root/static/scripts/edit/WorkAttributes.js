MB.WorkAttributes = (function(WA) {

// Private variables
var attributeTypes;
var allowedValues;
var attributeTypesByID;

// Private classes
var ViewModel;

WA.init = function (config) {

    function byID(result, parent) {
        result[parent.id] = parent;
        _.transform(parent.children, byID, result);
    }

    attributeTypes = config.attributeTypes;
    allowedValues = config.allowedValues;
    attributeTypesByID = _.transform(attributeTypes.children, byID, {});

    WA.viewModel = new ViewModel(config.attributes);
    ko.applyBindings(WA.viewModel, $("#work-attributes")[0]);
};

WA.WorkAttribute = function (data) {
    var self = this;

    self.typeID = ko.observable(data.typeID);
    self.attributeValue = ko.observable(data.value || undefined);
    self.errors = ko.observableArray(data.errors);
    self.typeHasFocus = ko.observable(false);

    self.allowsFreeText = ko.computed(function() {
        return !self.typeID() || attributeTypesByID[self.typeID()].freeText;
    });

    self.allowedValues = ko.computed(function () {
        var typeID = self.typeID();

        if (self.allowsFreeText()) {
            return [];
        }
        else {
            var root = {
                children: _.filter(allowedValues.children, function (value) {
                    return value.workAttributeTypeID == typeID;
                })
            };

            return MB.forms.buildOptionsTree(root, "value", "id");
        }
    });

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

    if (!attributes || !attributes.length) {
        attributes = [{}];
    }

    attributes = _.map(attributes, function (data) {
        return new WA.WorkAttribute(data);
    });

    model.attributes = ko.observableArray(attributes);

    model.attributeTypes = MB.forms.buildOptionsTree(
        attributeTypes, "name", "id"
    );

    model.newAttribute = function() {
        var attr = new WA.WorkAttribute({});
        attr.typeHasFocus(true);
        model.attributes.push(attr);
    };

    return model;
};

return WA;

}(MB.WorkAttributes || {}));
