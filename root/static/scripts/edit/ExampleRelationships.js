import $ from 'jquery';
import ko from 'knockout';

import {ENTITY_NAMES} from '../common/constants.js';
import MB from '../common/MB.js';
import EntityAutocomplete from '../common/MB/Control/Autocomplete.js';
import request from '../common/utility/request.js';

MB.ExampleRelationshipsEditor = (function (ERE) {
  // Private variables
  let type0;
  let type1;
  let linkTypeName;
  let linkTypeID;
  let jsRoot;

  // Private methods
  let searchUrl;

  ERE.init = function (config) {
    type0 = config.type0;
    type1 = config.type1;
    linkTypeName = config.linkTypeName;
    linkTypeID = Number(config.linkTypeID);

    jsRoot = config.jsRoot;

    ERE.viewModel = new ViewModel();

    const autocomplete = EntityAutocomplete({
      entity: type0,
      inputs: $('span.autocomplete'),
      setEntity: ERE.viewModel.selectedEntityType,
    });
    ERE.viewModel.selectedEntityType.subscribe(autocomplete.changeEntity);

    const availableEntityTypes = [
      {text: ENTITY_NAMES[type0](), value: type0},
    ];
    if (type0 !== type1) {
      availableEntityTypes.push(
        {text: ENTITY_NAMES[type1](), value: type1},
      );
    }
    ERE.viewModel.availableEntityTypes(availableEntityTypes);

    ko.bindingHandlers.checkObject = {
      init(element, valueAccessor, all, vm, bindingContext) {
        ko.utils.registerEventHandler(element, 'click', function () {
          const checkedValue = valueAccessor();
          const meValue = bindingContext.$data;
          const checked = element.checked;
          if (checked && ko.isObservable(checkedValue)) {
            checkedValue(meValue);
          }
        });
      },
      update(element, valueAccessor, all, vm, bindingContext) {
        const checkedValue = ko.utils.unwrapObservable(valueAccessor());
        const meValue = bindingContext.$data;

        element.checked = (checkedValue === meValue);
      },
    };

    ko.applyBindings(ERE.viewModel);
  };

  ERE.Example = function (name, relationship) {
    const self = this;

    self.name = ko.observable(name);
    self.relationship = relationship;
    self.removeExample = function () {
      ERE.viewModel.examples.remove(this);
    };

    return self;
  };

  function ViewModel() {
    return {
      availableEntityTypes: ko.observableArray(),
      currentExample: {
        add() {
          const ce = this.currentExample;

          this.examples.push(
            new ERE.Example(ce.name(), ce.relationship()),
          );

          ce.name('');
          ce.relationship(null);
          ce.possibleRelationships.clear();
        },
        name: ko.observable(),
        possibleRelationships: new RelationshipSearcher(),
        relationship: ko.observable(),
      },
      examples: ko.observableArray(),
      selectedEntityType: ko.observable(),
    };
  }

  searchUrl = function (mbid) {
    return jsRoot + mbid + '?inc=rels';
  };


  function RelationshipSearcher() {
    const self = this;

    self.query = ko.observable();
    self.error = ko.observable();

    self.results = ko.observableArray();

    self.search = function () {
      const possible = this.currentExample.possibleRelationships;

      request({url: searchUrl(possible.query())})
        .fail(function (jqxhr, status, error) {
          self.error('Lookup failed: ' + error);
        })
        .done(function (data) {
          const searchResultType = data.entityType.replace('-', '_');

          if (!(searchResultType === type0 ||
                searchResultType === type1)) {
            self.error('Invalid type for this relationship: ' +
                        searchResultType +
                        ' (expected ' + type0 + ' or ' + type1 + ')');
            return;
          }

          const relationships = data.relationships.filter(
            x => x.linkTypeID === linkTypeID,
          );

          if (relationships.length) {
            self.error(null);

            for (const rel of relationships) {
              let source = data;
              let target = rel.target;

              if (rel.backward) {
                source = rel.target;
                target = data;
              }

              possible.results.push({
                id: rel.id,
                phrase: rel.verbosePhrase,
                source: {
                  mbid: source.gid,
                  name: source.name,
                },
                target: {
                  mbid: target.gid,
                  name: target.name,
                },
              });
            }
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
    };

    return self;
  }

  return ERE;
}(MB.ExampleRelationshipsEditor || {}));
