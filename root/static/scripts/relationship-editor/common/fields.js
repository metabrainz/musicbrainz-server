// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var fields = RE.fields = RE.fields || {};


    fields.Relationship = aclass({

        rateLimitOptions: {
            rateLimit: { method: "notifyWhenChangesStop", timeout: 100 }
        },

        init: function (data, source, parent) {
            var self = this;

            this.parent = parent;

            if (data.id) {
                this.id = data.id;
            }

            this.entities = ko.observable(_.map(data.entities, function (entity) {
                return MB.entity(entity);
            }));

            this.entities.equalityComparer = entitiesComparer;
            this.entities.saved = this.entities.peek().slice(0);
            this.entities.subscribe(this.entitiesChanged, this);
            this.entityTypes = _(data.entities).pluck("entityType").join("-");
            this.uniqueID = this.entityTypes + "-" + (this.id || _.uniqueId("new-"));

            this.linkTypeID = ko.observable(data.linkTypeID);
            this.linkTypeID.isDifferent = linkTypeComparer;

            this.linkTypeID.subscribe(function (id) {
                self.linkTypeIDChanged(id);
            });

            this.period = {
                beginDate: setPartialDate({}, data.beginDate || {}),
                endDate: setPartialDate({}, data.endDate || {}),
                ended: ko.observable(!!data.ended)
            };

            this.attributeValues = ko.observable({});
            this.attributes(data.attributes);
            this.setAttributeValues(data.attributeTextValues);

            this.linkOrder = ko.observable(data.linkOrder || 0);
            this.removed = ko.observable(!!data.removed);
            this.editsPending = Boolean(data.editsPending);

            this.editData = ko.computed(function () {
                return MB.edit.fields.relationship(self);
            });

            if (data.id) {
                this.original = MB.edit.fields.relationship(this);
            }

            // By default, show all existing relationships on the page.
            if (this.id) this.show();
        },

        fromJS: function (data) {
            this.linkTypeID(data.linkTypeID);
            this.entities([MB.entity(data.entities[0]), MB.entity(data.entities[1])]);

            setPartialDate(this.period.beginDate, data.beginDate || {});
            setPartialDate(this.period.endDate, data.endDate || {});
            this.period.ended(!!data.ended);

            this.attributes(data.attributes);
            this.setAttributeValues(data.attributeTextValues);
            this.linkOrder(data.linkOrder || 0);

            _.has(data, "removed") && this.removed(!!data.removed);
        },

        target: function (source) {
            var entities = this.entities();

            if (source === entities[0]) return entities[1];
            if (source === entities[1]) return entities[0];

            throw new Error("The given entity is not used by this relationship");
        },

        linkPhrase: function (source) {
            var typeInfo = this.linkTypeInfo();
            var forward = source === this.entities()[0];

            return typeInfo ? (forward ? typeInfo.phrase : typeInfo.reversePhrase) : "";
        },

        linkTypeIDChanged: function () {
            var typeInfo = this.linkTypeInfo();
            var attrValues = {};
            var self = this;

            _.each(typeInfo && typeInfo.attributes, function (attrInfo, id) {
                attrValues[id] = self.attributeValue(id);
            });

            this.attributeValues(attrValues);
        },

        linkTypeInfo: function () {
            return MB.typeInfoByID[this.linkTypeID()];
        },

        hasDates: function () {
            var typeInfo = this.linkTypeInfo();
            return typeInfo ? (typeInfo.hasDates !== false) : true;
        },

        added: function () { return !this.id },

        edited: function () {
            return !_.isEqual(this.original, this.editData());
        },

        hasChanges: function () {
            return this.added() || this.removed() || this.edited();
        },

        show: function () {
            var entities = this.entities();

            if (entities[0].relationships.indexOf(this) < 0) {
                entities[0].relationships.push(this);
            }

            if (entities[1].relationships.indexOf(this) < 0) {
                entities[1].relationships.push(this);
            }
        },

        entitiesChanged: function (newEntities) {
            var oldEntities = this.entities.saved;

            var entity0 = newEntities[0];
            var entity1 = newEntities[1];

            var saved0 = oldEntities[0];
            var saved1 = oldEntities[1];

            if (saved0 !== entity0 && saved0 !== entity1) {
                saved0.relationships.remove(this);
            }

            if (saved1 !== entity0 && saved1 !== entity1) {
                saved1.relationships.remove(this);
            }

            var relationships0 = entity0.relationships;
            var relationships1 = entity1.relationships;

            var containedBy0 = relationships0.indexOf(this) >= 0;
            var containedBy1 = relationships1.indexOf(this) >= 0;

            if (containedBy0 && !containedBy1) relationships1.push(this);
            if (containedBy1 && !containedBy0) relationships0.push(this);

            if (entity0.entityType === "recording"
                && entity1.entityType === "work"
                && saved1 !== entity1 && entity1.gid) {

                var args = { url: "/ws/js/entity/" + entity1.gid + "?inc=rels" };

                MB.utility.request(args, this).done(function (data) {
                    entity1.parseRelationships(data.relationships, this.parent);
                });
            }

            this.entities.saved = [entity0, entity1];
        },

        clone: function () {
            var clone = fields.Relationship(_.omit(this.editData(), "id"));
            clone.parent = this.parent;
            return clone;
        },

        remove: function () {
            if (this.removed() === true) return;

            var entities = this.entities();

            entities[0].relationships.remove(this);
            entities[1].relationships.remove(this);

            delete this.parent.cache[this.entityTypes + "-" + this.id];
            this.removed(true);
        },

        attributeValue: function (id) {
            var attr = MB.attrInfoByID[id];
            if (!attr) return;

            // The id parameter could also be a gid.
            // Ensure it's an integer id.
            id = attr.id;

            var typeInfo = this.linkTypeInfo();
            if (!typeInfo) return;

            var attrInfo = typeInfo.attributes && typeInfo.attributes[id];
            if (!attrInfo) return;

            // Only acquire a dependency on attributeValues if we're reading
            // the value of an attribute, not if we're writing to it.
            if (arguments.length === 1) {
                var attributeValues = this.attributeValues();
            } else {
                var attributeValues = this.attributeValues.peek();
            }

            var value = attributeValues[id];
            var isNew = !value;

            if (isNew) {
                if (attrInfo.max === 1) {
                    var defaultValue = attr.freeText ? "" : (isBooleanAttr(attr) ? false : undefined);
                    value = attributeValues[id] = ko.observable(defaultValue);
                } else {
                    value = attributeValues[id] = ko.observableArray([]);
                }
            }

            if (arguments.length === 1) {
                isNew && this.attributeValues.notifySubscribers(attributeValues);
                return value;
            } else {
                var newValue = arguments[1];

                if (attrInfo.max === 1) {
                    if (_.isArray(newValue)) newValue = newValue[0];

                    if (attr.freeText) {
                        newValue = String(newValue || "");
                    } else if (isBooleanAttr(attr)) {
                        newValue = !!newValue;
                    }
                } else {
                    newValue = _.isArray(newValue) ? newValue.slice(0) : [newValue];

                    if (attr.freeText) {
                        newValue = flattenValues(newValue).map(String).value();
                    } else {
                        newValue = flattenAttributeIDs(newValue);
                    }
                }
                value(newValue);
                this.attributeValues.notifySubscribers(attributeValues);
            }
        },

        setAttributeValues: function (values) {
            var self = this;

            _.each(values, function (value, id) {
                self.attributeValue(id, value);
            });
        },

        attributes: function (ids) {
            if (arguments.length > 0) {
                var typeInfo = this.linkTypeInfo();

                if (typeInfo) {
                    var self = this;

                    ids = _.transform(ids, attrIDsByRootID, {});

                    _.each(typeInfo.attributes, function (attrInfo, id) {
                        self.attributeValue(id, ids[id] || []);
                    });
                }
            } else {
                return flattenAttributeIDs(_.map(this.attributeValues(), unwrapAttributeValue));
            }
        },

        attributeTextValues: function () {
            var typeInfo = this.linkTypeInfo();

            if (typeInfo) {
                var self = this;
                var attributeValues = this.attributeValues();

                return _.transform(typeInfo.attributes, function (result, info, id) {
                    var attr = info.attribute;

                    if (attr.freeText) {
                        result[id] = ko.unwrap(attributeValues[id]);
                    }
                }, {});
            }

            return {};
        },

        linkTypeAttributes: function () {
            var typeInfo = this.linkTypeInfo();
            return typeInfo ? _.values(typeInfo.attributes) : [];
        },

        attributeError: function (rootInfo) {
            var value = ko.unwrap(this.attributeValue(rootInfo.attribute.id));
            var min = rootInfo.min;

            if (min > 0) {
                if (!value || (_.isArray(value) && value.length < min)) {
                    return MB.text.AttributeRequired;
                }
            }

            return "";
        },

        phraseAndExtraAttributes: function (source) {
            var origPhrase = this.linkPhrase(source);
            var attributeIDs = this.attributes();
            var extraAttributes = _.transform(attributeIDs, attrsByRootName, {});

            var phrase = _.str.clean(origPhrase.replace(/\{(.*?)(?::(.*?))?\}/g,
                    function (match, name, alts) {

                delete extraAttributes[name];
                var root = MB.attrInfo[name];

                var values = _.transform(attributeIDs, function (result, id) {
                    var attr = MB.attrInfoByID[id];

                    if (attr.root === root) result.push(attr.l_name);
                });

                if (alts && (alts = alts.split("|"))) {
                    return (
                        values.length
                            ? alts[0].replace(/%/g, MB.utility.joinList(values))
                            : alts[1] || ""
                    );
                }

                return MB.utility.joinList(values);
            }));

            var self = this;

            extraAttributes = MB.utility.joinList(
                _(extraAttributes).values().flatten().map(function (attr) {
                    if (attr.freeText) {
                        var value = ko.unwrap(self.attributeValue(attr.id));

                        if (!value) return "";

                        return MB.i18n.expand(MB.text.AttributeTextValue, {
                            attribute: attr.l_name, value: value
                        });
                    } else {
                        return attr.l_name;
                    }
                }).value()
            );

            return [phrase, extraAttributes];
        },

        lowerCasePhrase: function (source) {
            return this.phraseAndExtraAttributes()[0].toLowerCase();
        },

        lowerCaseTargetName: function (source) {
            return ko.unwrap(this.target(source).name).toLowerCase();
        },

        entityIsOrdered: function (entity) {
            var typeInfo = this.linkTypeInfo();
            if (!typeInfo) return false;

            var orderableDirection = typeInfo.orderableDirection;
            if (orderableDirection === 0) return false;

            var entities = this.entities();

            if (orderableDirection === 1 && entity === entities[1]) {
                return true;
            }

            if (orderableDirection === 2 && entity === entities[0]) {
                return true;
            }

            return false;
        },

        entityCanBeReordered: function (entity) {
            if (!this.entityIsOrdered(entity)) {
                return false;
            }

            var target = this.target(entity);

            if (target.entityType === "series") {
                return +target.orderingTypeID() !== MB.constants.SERIES_ORDERING_TYPE_AUTOMATIC;
            }

            return true;
        },

        moveEntityUp: function () {
            this.linkOrder(Math.max(this.linkOrder() - 1, 0));

            var row = $("#relationship-" + this.uniqueID)[0];

            row.tempElement && $("button.move-up", row.tempElement).focus();

            row.moving && row.moving.done(function () {
                MB.utility.deferFocus("button.move-up", row);
            });
        },

        moveEntityDown: function () {
            this.linkOrder(this.linkOrder() + 1);

            var row = $("#relationship-" + this.uniqueID)[0];

            row.tempElement && $("button.move-down", row.tempElement).focus();

            row.moving && row.moving.done(function () {
                MB.utility.deferFocus("button.move-down", row);
            });
        },

        showLinkOrder: function (source) {
            return this.entityIsOrdered(this.target(source)) &&
                    (source.entityType !== "series" ||
                     +source.orderingTypeID() === MB.constants.SERIES_ORDERING_TYPE_MANUAL);
        },

        isDuplicate: function (other) {
            return (
                this !== other &&
                this.linkTypeID() == other.linkTypeID() &&
                _.isEqual(this.entities(), other.entities()) &&
                MB.utility.mergeDates(this.period.beginDate, other.period.beginDate) &&
                MB.utility.mergeDates(this.period.endDate, other.period.endDate) &&
                _.isEqual(this.attributes(), other.attributes())
            );
        },

        openEdits: function () {
            var entities = this.original.entities;
            var entity0 = MB.entity(entities[0]);
            var entity1 = MB.entity(entities[1]);

            return _.str.sprintf(
                '/search/edits?auto_edit_filter=&order=desc&negation=0&combinator=and' +
                '&conditions.0.field=%s&conditions.0.operator=%%3D&conditions.0.name=%s' +
                '&conditions.0.args.0=%s&conditions.1.field=%s&conditions.1.operator=%%3D' +
                '&conditions.1.name=%s&conditions.1.args.0=%s&conditions.2.field=type' +
                '&conditions.2.operator=%%3D&conditions.2.args=90%%2C233&conditions.2.args=91' +
                '&conditions.2.args=92&conditions.3.field=status&conditions.3.operator=%%3D' +
                '&conditions.3.args=1&field=Please+choose+a+condition',
                encodeURIComponent(entity0.entityType),
                encodeURIComponent(entity0.name),
                encodeURIComponent(entity0.id),
                encodeURIComponent(entity1.entityType),
                encodeURIComponent(entity1.name),
                encodeURIComponent(entity1.id)
            );
        }
    });


    function entitiesComparer(a, b) {
        return a[0] === b[0] && a[1] === b[1];
    }

    function linkTypeComparer(a, b) { return a != b }


    function attrsByRootName(result, id) {
        var attr = MB.attrInfoByID[id];
        var root = attr.root.name;

        (result[root] = result[root] || []).push(attr);
    }


    function attrIDsByRootID(result, id) {
        var rootID = MB.attrInfoByID[id].root_id;

        (result[rootID] = result[rootID] || []).push(id);
    }


    function unwrapAttributeValue(value, rootID) {
        var attr = MB.attrInfoByID[rootID];

        value = ko.unwrap(value);

        return (attr.freeText || isBooleanAttr(attr)) ? (value ? rootID : null) : value;
    }


    function isBooleanAttr(attr) {
        return !(attr.children || attr.freeText);
    }


    function flattenValues(values) {
        return _(values).flatten().compact();
    }


    function flattenAttributeIDs(ids) {
        return flattenValues(ids).map(Number).sortBy().value();
    }


    function setPartialDate(target, data) {
        _.each(["year", "month", "day"], function (key) {
            (target[key] = target[key] || ko.observable())(ko.unwrap(data[key]) || null);
        });
        return target;
    }


}(MB.relationshipEditor = MB.relationshipEditor || {}));
