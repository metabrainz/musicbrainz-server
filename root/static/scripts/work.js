const ko = require('knockout');
const _ = require('lodash');

const {lp} = require('../common/i18n');

class WorkAttribute {
  constructor(data, parent) {
    this.attributeValue = ko.observable(data.value || undefined);
    this.errors = ko.observableArray(data.errors);
    this.parent = parent;
    this.typeHasFocus = ko.observable(false);
    this.typeID = ko.observable(data.typeID);

    this.allowedValues = ko.computed(() => {
      let typeID = this.typeID();

      if (this.allowsFreeText()) {
        return [];
      } else {
        return MB.forms.buildOptionsTree({
          children: _.filter(this.parent.allowedValues.children, function (value) {
            return value.workAttributeTypeID == typeID;
          })
        }, 'value', 'id');
      }
    });

    this.typeID.subscribe(newTypeID => {
      // != is used intentionally for type coercion.
      if (this.typeID() != newTypeID) {
        this.attributeValue("");
        this.resetErrors();
      }
    });

    this.attributeValue.subscribe(() => this.resetErrors());
  }

  allowsFreeText() {
    return !this.typeID() || this.parent.attributeTypesByID[this.typeID()].freeText;
  }

  isGroupingType() {
    return !this.allowsFreeText() && this.allowedValues().length == 0;
  }

  remove() {
    this.parent.attributes.remove(this);
  }

  resetErrors() {
    this.errors([]);
  }
}

class ViewModel {
  constructor(attributeTypes, allowedValues, attributes) {
    attributeTypes.children.forEach(type => {
      type.name = lp(type.name, 'work_attribute_type');
    });

    allowedValues.children.forEach(value => {
      value.value = lp(value.value, 'work_attribute_type_allowed_value');
    });

    this.attributeTypes = MB.forms.buildOptionsTree(attributeTypes, 'name', 'id');
    this.attributeTypesByID = _.transform(attributeTypes.children, byID, {});
    this.allowedValues = allowedValues;

    if (!attributes || !attributes.length) {
      attributes = [{}];
    }

    this.attributes = ko.observableArray(_.map(attributes, data => new WorkAttribute(data, this)));
  }

  newAttribute() {
    let attr = new WorkAttribute({}, this);
    attr.typeHasFocus(true);
    this.attributes.push(attr);
  }
}

function getScriptParameter(name) {
  return JSON.parse(document.getElementById('work-bundle').getAttribute(name));
}

function byID(result, parent) {
  result[parent.id] = parent;
  _.transform(parent.children, byID, result);
}

ko.applyBindings(
  new ViewModel(
    getScriptParameter('data-attribute-types'),
    getScriptParameter('data-allowed-values'),
    getScriptParameter('data-attributes')
  ),
  $('#work-attributes')[0]
);

MB.Control.initialize_guess_case('work', 'id-edit-work');
MB.Control.initializeBubble('#iswcs-bubble', 'input[name=edit-work\\.iswcs\\.0]');
