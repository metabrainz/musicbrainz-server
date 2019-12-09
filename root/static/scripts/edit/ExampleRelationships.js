import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import {ENTITY_NAMES} from '../common/constants';
import MB from '../common/MB';
import request from '../common/utility/request';

MB.ExampleRelationshipsEditor = (function (ERE) {


  // Private variables
  let type0;
  let type1;
  let linkTypeName;
  let linkTypeID;
  let jsRoot;

  // Private methods
  let searchUrl;

  // Private classes
  let RelationshipSearcher;
  let ViewModel;

  ERE.init = function (config) {
    type0 = config.type0;
    type1 = config.type1;
    linkTypeName = config.linkTypeName;
    linkTypeID = +config.linkTypeID;

    jsRoot = config.jsRoot;

    ERE.viewModel = new ViewModel();

    let autocomplete = MB.Control.EntityAutocomplete({
      'inputs': $('span.autocomplete'),
      'entity': type0,
      'setEntity': ERE.viewModel.selectedEntityType
    });
    ERE.viewModel.selectedEntityType.subscribe(autocomplete.changeEntity);
    ERE.viewModel.availableEntityTypes(
      _.uniq([ type0, type1 ]).map(function (value) {
        return { 'value': value, 'text': ENTITY_NAMES[value]() };
      }),
    );

    ko.bindingHandlers.checkObject = {
      init: function (element, valueAccessor, all, vm, bindingContext) {
        ko.utils.registerEventHandler(element, "click", function () {
          let checkedValue = valueAccessor();
          let meValue = bindingContext.$data;
          let checked = element.checked;
          if (checked && ko.isObservable(checkedValue)) {
            checkedValue(meValue);
          }
        });
      },
      update: function (element, valueAccessor, all, vm, bindingContext) {
        let checkedValue = ko.utils.unwrapObservable(valueAccessor());
        let meValue = bindingContext.$data;

        element.checked = (checkedValue === meValue);
      }
    };

    ko.applyBindings(ERE.viewModel);
  }

  ERE.Example = function (name, relationship) {
    let self = this;

    self.name = ko.observable(name);
    self.relationship = relationship;
    self.removeExample = function () {
      ERE.viewModel.examples.remove(this);
    }

    return self;
  }

  ViewModel = function () {
    return {
      examples: ko.observableArray(),
      availableEntityTypes: ko.observableArray(),
      selectedEntityType: ko.observable(),
      currentExample: {
        name: ko.observable(),
        relationship: ko.observable(),
        add: function () {
          let ce = this.currentExample;

          this.examples.push(
            new ERE.Example(ce.name(), ce.relationship()),
          );

          ce.name('');
          ce.relationship(null);
          ce.possibleRelationships.clear();
        },
        possibleRelationships: new RelationshipSearcher()
      }
    }
  };

  searchUrl = function (mbid) {
    return jsRoot + mbid + '?inc=rels';
  }


  RelationshipSearcher = function () {
    let self = this;

    self.query = ko.observable();
    self.error = ko.observable();

    self.results = ko.observableArray();

    self.search = function () {
      let possible = this.currentExample.possibleRelationships;

      request({url: searchUrl(possible.query())})
        .fail(function (jqxhr, status, error) {
          self.error('Lookup failed: ' + error);
        })
        .done(function (data) {
          let search_result_type = data.entityType.replace("-", "_");

          if (!(search_result_type === type0 ||
                  search_result_type === type1)) {
            self.error('Invalid type for this relationship: ' +
                           search_result_type +
                           ' (expected ' + type0 + ' or ' + type1 + ')');
            return;
          }

          let relationships =
                _.filter(data.relationships, { linkTypeID: linkTypeID });

          if (relationships.length) {
            self.error(null);

            _.each(relationships, function (rel) {
              let source = data;
              let target = rel.target;

              if (rel.direction == "backward") {
                source = rel.target;
                target = data;
              }

              possible.results.push({
                id: rel.id,
                phrase: rel.verbosePhrase,
                source: {
                  name: source.name,
                  mbid: source.gid
                },
                target: {
                  name: target.name,
                  mbid: target.gid
                }
              })
            });
          } else {
            self.error(
              'No ' + linkTypeName + ' relationships found for ' + data.name,
            );
          }
        });
    };

    self.clear = function () {
      this.query('');
      this.results.removeAll();
    }

    return self;
  }

  return ERE;

}(MB.ExampleRelationshipsEditor || {}));

