// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    function mapItems(result, item) {
        if (item.id) {
            result[item.id] = item;
        }
        if (item.gid) {
            result[item.gid] = item;
        }
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
            var self = this;

            this.cache = {};
            this.allowedRelations = this.getAllowedRelations();
            this.uniqueID = _.uniqueId("relationship-editor-");
            this.relationshipsBySource = {};

            if (options.formName) {
                this.formName = options.formName;
            }

            var source = this.source = options.source;

            if (options.sourceData) {
                if (!source) {
                    source = this.source = MB.entity(options.sourceData);
                }
                source.parseRelationships(options.sourceData.relationships, this);

                _.each(options.sourceData.submittedRelationships, function (data) {
                    var relationship = self.getRelationship(data, source);

                    if (!relationship) {
                        return;
                    } else if (relationship.id) {
                        var target = MB.entity(data.target);
                        var entities = _.sortBy([source, target], "entityType");

                        if (source.entityType === target.entityType && data.direction === "backward") {
                            entities.reverse();
                        }
                        relationship.fromJS(_.assign(_.clone(data), { entities: entities }));
                    } else {
                        relationship.show();
                    }
                });
            }

            if (options.fieldErrors) {
                _.each(source.relationships(), function (relationship, index) {
                    var errors = options.fieldErrors[index];

                    if (errors) {
                        relationship.error(errors.text || errors.link_type_id);
                    }
                });
            }
        },

        getAllowedRelations: function () {
            var relations = {};
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

            return relations;
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

        containsRelationship: function (relationship, source) {
            var entityTypes = relationship.entityTypes;

            if (entityTypes === "recording-work" && this instanceof RE.ReleaseViewModel) {
                return false;
            }

            var types = entityTypes.split("-"),
                targetType = source.entityType === types[0] ? types[1] : types[0];

            if (!this.typesAreAccepted(source.entityType, targetType)) {
                return false;
            }

            return this.goodCardinality(
                relationship.linkTypeID(),
                source.entityType,
                source === relationship.entities()[1]

            // Always display added/edited/removed relationships, even if
            // the cardinality is wrong; otherwise invisible changes can
            // be submitted.
            ) || relationship.hasChanges();
        }
    });

}(MB.relationshipEditor = MB.relationshipEditor || {}));
