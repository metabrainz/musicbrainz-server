// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    function mapItems(result, item) {
        result[item.id] = item;

        _.transform(item.children, mapItems, result);
    }


    RE.exportTypeInfo = function (typeInfo, attrInfo) {
        MB.typeInfo = typeInfo;
        MB.attrInfo = attrInfo;

        MB.typeInfoByID = _(typeInfo).values().flatten().transform(mapItems, {}).value();
        MB.attrInfoByID = _(attrInfo).values().transform(mapItems, {}).value();

        _.each(MB.typeInfoByID, function (type) {
            _.each(type.attributes, function (typeAttr, id) {
                typeAttr.attribute = MB.attrInfoByID[id];
            });
        });

        _.each(MB.attrInfoByID, function (attr) {
            attr.root = MB.attrInfoByID[attr.root_id];
        });
    };


    RE.ViewModel = aclass({

        relationshipClass: RE.fields.Relationship,

        init: function (options) {
            this.cache = {};

            var relations = this.allowedRelations = {};
            var self = this;

            _(MB.typeInfo).keys().each(function (typeString) {
                var types = typeString.split("-");
                var type0 = types[0];
                var type1 = types[1];

                if (self.typesAreAccepted(type0, type1)) {
                    (relations[type0] = relations[type0] || []).push(type1);
                }

                if (type0 !== type1 && self.typesAreAccepted(type1, type0)) {
                    (relations[type1] = relations[type1] || []).push(type0);
                }
            });

            if (options.formName) {
                this.formName = options.formName;
            }

            this.source = options.source;

            if (options.sourceData) {
                this.source = options.source || MB.entity(options.sourceData).extend({
                    relationships: ko.observableArray([])
                });

                this.source.parseRelationships(options.sourceData.relationships, this);

                _.each(options.sourceData.submittedRelationships, function (data) {
                    var relationship = self.getRelationship(data, self.source);

                    if (!relationship) {
                        return;
                    } else if (relationship.id) {
                        relationship.fromJS(_.assign(_.clone(data), {
                            entities: _.sortBy([self.source, MB.entity(data.target)], "entityType")
                        }));
                    } else {
                        relationship.show();
                    }
                });
            }

            if (options.fieldErrors) {
                _.each(this.source.relationships(), function (relationship, index) {
                    var errors = options.fieldErrors[index];

                    if (errors) {
                        relationship.error(errors.text || errors.link_type_id);
                    }
                });
            }
        },

        getRelationship: function (data, source) {
            var target = data.target;

            if (!this.typesAreAccepted(source.entityType, target.entityType)) {
                return null;
            }

            data = _.clone(data);

            var backward = source.entityType > target.entityType;

            if (source.entityType === target.entityType) {
                backward = (data.direction === "backward");
            }

            data.entities = backward ? [target, source] : [source, target];

            var types = _.pluck(data.entities, "entityType");

            if (data.id) {
                var cacheKey = types.concat(data.id).join("-");
                var cached = this.cache[cacheKey];
                if (cached) return cached;
            }

            var relationship = this.relationshipClass(data, source, this);
            return data.id ? (this.cache[cacheKey] = relationship) : relationship;
        },

        sortedRelationships: function (relationships) {
            return _.sortBy(relationships, lowerCasePhrase);
        },

        typesAreAccepted: function () {
            return true;
        },

        goodCardinality: function (linkTypeID, sourceType, backward) {
            var typeInfo = MB.typeInfoByID[linkTypeID];

            if (!typeInfo) {
                return true;
            }

            if (sourceType === typeInfo.type0 && sourceType === typeInfo.type1) {
                return backward ? (typeInfo.cardinality1 === 0) : (typeInfo.cardinality0 === 0);
            }

            if (sourceType === typeInfo.type0) {
                return typeInfo.cardinality0 === 0;
            }

            if (sourceType === typeInfo.type1) {
                return typeInfo.cardinality1 === 0;
            }

            return false;
        },

        hiddenInputs: function () {
            var fieldPrefix = this.formName + "." + this.fieldName;
            var source = this.source;
            var relationships = source.displayRelationships(this);

            return _.flatten(_.map(relationships, function (relationship, index) {
                var prefix = fieldPrefix + "." + index;
                var hidden = [];
                var target = relationship.target(source);
                var editData = relationship.editData();

                if (relationship.id) {
                    hidden.push({ name: prefix + ".relationship_id", value: relationship.id });
                }

                if (relationship.removed()) {
                    hidden.push({ name: prefix + ".removed", value: 1 });
                }

                if (target.entityType === "url") {
                    hidden.push({ name: prefix + ".text", value: target.name });
                }
                else {
                    hidden.push({ name: prefix + ".target", value: target.gid });
                }

                _.each(editData.attributes, function (id, i) {
                    hidden.push({ name: prefix + ".attributes." + i, value: id });
                });

                var beginDate = editData.beginDate;
                var endDate = editData.endDate;
                var ended = editData.ended;

                if (beginDate) {
                    hidden.push({ name: prefix + ".period.begin_date.year", value: beginDate.year });
                    hidden.push({ name: prefix + ".period.begin_date.month", value: beginDate.month });
                    hidden.push({ name: prefix + ".period.begin_date.day", value: beginDate.day });
                }

                if (endDate) {
                    hidden.push({ name: prefix + ".period.end_date.year", value: endDate.year });
                    hidden.push({ name: prefix + ".period.end_date.month", value: endDate.month });
                    hidden.push({ name: prefix + ".period.end_date.day", value: endDate.day });
                }

                if (ended) {
                    hidden.push({ name: prefix + ".period.ended", value: 1 });
                }

                if (source !== relationship.entities()[0]) {
                    hidden.push({ name: prefix + ".backward", value: 1 });
                }

                hidden.push({ name: prefix + ".link_type_id", value: relationship.linkTypeID() });
                return hidden;
            }));
        }
    });


    function lowerCasePhrase(relationship) {
        return _.result(relationship, "linkPhrase").toLowerCase();
    }

}(MB.relationshipEditor = MB.relationshipEditor || {}));
