MB.ExampleRelationshipsEditor = (function(ERE) {

// Private variables
var type0, type1, linkTypeName, jsRoot, formName;

// Private methods
var searchUrl;

// Private classes
var RelationshipsSearcher, ViewModel;

ERE.init = function(config) {
    type0 = config.type0;
    type1 = config.type1;
    linkTypeName = config.linkTypeName;
    jsRoot = config.jsRoot;
    formName = config.formName;

    ERE.viewModel = new ViewModel();

    ko.bindingHandlers.checkObject = {
        init: function (element, valueAccessor, all, vm, bindingContext) {
            ko.utils.registerEventHandler(element, "click", function() {
                var checkedValue = valueAccessor(),
                    meValue = bindingContext.$data,
                    checked = element.checked;
                if (checked && ko.isObservable(checkedValue)) {
                    checkedValue(meValue);
                }
            });
        },
        update: function (element, valueAccessor, all, vm, bindingContext) {
            var checkedValue = ko.utils.unwrapObservable(valueAccessor()),
                meValue = bindingContext.$data;

            element.checked = (checkedValue === meValue);
        }
    };

    ko.applyBindings(ERE.viewModel);
}

ERE.Example = function(name, relationship) {
    var self = this;

    self.name = ko.observable(name);
    self.relationship = relationship;
    self.removeExample = function() {
        ERE.viewModel.examples.remove(this);
    }

    return self;
}

ViewModel = function () {
    return {
        examples: ko.observableArray(),
        currentExample: {
            name: ko.observable(),
            relationship: ko.observable(),
            add: function() {
                var ce = this.currentExample;

                this.examples.push(
                    new ERE.Example(ce.name(), ce.relationship()));

                ce.name('');
                ce.relationship(null);
                ce.possibleRelationships.clear();
            },
            possibleRelationships: new RelationshipSearcher()
        }
    }
};

searchUrl = function(mbid) {
    return jsRoot + mbid + '?inc=rels';
}


RelationshipSearcher = function () {
    var self = this;

    self.query = ko.observable();
    self.error = ko.observable();

    self.results = ko.observableArray();

    self.search = function() {
        var possible = this.currentExample.possibleRelationships;

        var request = $.ajax(searchUrl(possible.query()));

        request.fail (function (jqxhr, status, error) {
            self.error ('Lookup failed: ' + error);
        });

        request.done (function (data, status, jqxhr) {
            var endPointType = data.type == type0 ? type1 : type0;

            if (! (data.type === type0 || data.type === type1)) {
                self.error ('Invalid type for this relationship: ' +  data.type +
                           ' (expected ' + type0 + ' or ' + type1 + ')');
            }
            else if (! _(data.relationships).has(endPointType)) {
                self.error ('No ' + endPointType + ' relationships found for ' + data.name);
            }
            else if (! _(data.relationships[endPointType]).has(linkTypeName)) {
                self.error ('No ' + linkTypeName + ' relationships found for ' + data.name);
            }
            else
            {
                self.error (null);

                _.each(
                    data['relationships'][endPointType][linkTypeName],
                    function (rel) {
                        var source = data, target = rel.target;

                        if (rel.direction == "backward") {
                            source = rel.target;
                            target = data;
                        }

                        possible.results.push({
                            id: rel.id,
                            phrase: rel.verbose_phrase,
                            source: {
                                name: source.name || source.url,
                                mbid: source.gid
                            },
                            target: {
                                name: target.name || target.url,
                                mbid: target.gid
                            }
                        })
                    }
                );
            }
        });
    };

    self.clear =  function() {
        this.query('');
        this.results.removeAll();
    }

    return self;
}

return ERE;

}(MB.ExampleRelationshipsEditor || {}));

