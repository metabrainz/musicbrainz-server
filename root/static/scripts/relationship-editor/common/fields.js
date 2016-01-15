// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');

const {
    SERIES_ORDERING_ATTRIBUTE,
    SERIES_ORDERING_TYPE_AUTOMATIC
} = require('../../common/constants');
const i18n = require('../../common/i18n');
const clean = require('../../common/utility/clean');
const request = require('../../common/utility/request');
const dates = require('../../edit/utility/dates');
const linkPhrase = require('../../edit/utility/linkPhrase');
const mergeDates = require('./mergeDates');

(function (RE) {

    var fields = RE.fields = RE.fields || {};


    fields.Relationship = aclass({

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

            this.entity0_credit = ko.observable(data.entity0_credit || '');
            this.entity1_credit = ko.observable(data.entity1_credit || '');

            this.linkTypeID = ko.observable(data.linkTypeID);
            this.linkTypeID.isDifferent = linkTypeComparer;
            this.linkTypeID.subscribe(this.linkTypeIDChanged, this);

            this.period = {
                beginDate: setPartialDate({}, data.beginDate || {}),
                endDate: setPartialDate({}, data.endDate || {}),
                ended: ko.observable(!!data.ended)
            };

            this.attributes = ko.observableArray([]);
            this.setAttributes(data.attributes);
            this.attributes.original = {};

            if (data.id) {
                _.each(this.attributes.peek(), function (attribute) {
                    self.attributes.original[attribute.type.gid] = attribute.toJS();
                });
            }

            // XXX Sigh. This whole subscription shouldn't be necessary, because
            // we already filter out invalid attributes in linkTypeIDChanged.
            // But knockout's 'checked' binding is annoying and reverts any removals
            // if it sees that the previous attributes are still checked (they
            // haven't been removed from the template yet; that probably happens
            // in a later subscription). That's why the _.defer is needed; we need
            // to wait for it to idiotically add the attributes back. The proper
            // solution would be to use a writable computed observable that filters
            // out invalid values upon writing, but there's already a bunch of code
            // that depends on 'attributes' being an observableArray.
            var removingInvalidAttributes = false;
            this.attributes.subscribe(function (newAttributes) {
                if (!removingInvalidAttributes) {
                    _.defer(function () {
                        if (newAttributes === self.attributes.peek()) {
                            removingInvalidAttributes = true;
                            self.attributes(validAttributes(self, newAttributes));
                            removingInvalidAttributes = false;
                        }
                    });
                }
            });

            this.linkOrder = ko.observable(data.linkOrder || 0);
            this.removed = ko.observable(!!data.removed);
            this.editsPending = Boolean(data.editsPending);

            this.editData = ko.computed(function () {
                return MB.edit.fields.relationship(self);
            });

            this.phraseAndExtraAttributes = ko.computed(function () {
                return self._phraseAndExtraAttributes();
            });

            if (data.id) {
                this.original = this.editData.peek();
            }

            // By default, show all existing relationships on the page.
            if (this.id) this.show();
        },

        formatDatePeriod: function () {
            return dates.formatDatePeriod(this.period);
        },

        fromJS: function (data) {
            this.linkTypeID(data.linkTypeID);
            this.entities([MB.entity(data.entities[0]), MB.entity(data.entities[1])]);
            this.entity0_credit(data.entity0_credit || '');
            this.entity1_credit(data.entity1_credit || '');

            setPartialDate(this.period.beginDate, data.beginDate || {});
            setPartialDate(this.period.endDate, data.endDate || {});
            this.period.ended(!!data.ended);

            this.setAttributes(data.attributes);
            this.linkOrder(data.linkOrder || 0);

            _.has(data, "removed") && this.removed(!!data.removed);
        },

        target: function (source) {
            var entities = this.entities();

            if (source === entities[0]) return entities[1];
            if (source === entities[1]) return entities[0];

            throw new Error("The given entity is not used by this relationship");
        },

        linkTypeIDChanged: function () {
            var typeInfo = this.linkTypeInfo();

            if (!typeInfo) {
                return;
            }

            // This should really only change if the relationship was initially
            // seeded without any link type.
            this.entityTypes = typeInfo.type0 + '-' + typeInfo.type1;

            var typeAttributes = typeInfo.attributes,
                attributes = this.attributes(), attribute;

            for (var i = 0, len = attributes.length; i < len; i++) {
                attribute = attributes[i];

                if (!typeAttributes || !typeAttributes[attribute.type.rootID]) {
                    this.attributes.remove(attribute);
                    --i;
                    --len;
                }
            }
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

                request(args).done(function (data) {
                    entity1.parseRelationships(data.relationships);
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

        getAttribute: function (typeGID) {
            var attributes = this.attributes();

            for (var i = 0, linkAttribute; linkAttribute = attributes[i]; i++) {
                if (linkAttribute.type.gid === typeGID) return linkAttribute;
            }
            return new fields.LinkAttribute({ type: { gid: typeGID }});
        },

        setAttributes: function (attributes) {
            this.attributes(_.map(validAttributes(this, attributes), function (data) {
                return new fields.LinkAttribute(data);
            }));
        },

        addAttribute: function (typeGID) {
            var attribute = new fields.LinkAttribute({ type: { gid: typeGID } });
            this.attributes.push(attribute);
            return attribute;
        },

        linkTypeAttributes: function () {
            var typeInfo = this.linkTypeInfo();
            return typeInfo ? _.values(typeInfo.attributes) : [];
        },

        attributeError: function (rootInfo) {
            var min = rootInfo.min;

            if (min > 0) {
                var rootID = rootInfo.attribute.id;

                var values = _.filter(this.attributes(), function (attribute) {
                    return attribute.type.rootID == rootID;
                });

                if (values.length < min) {
                    return i18n.l("This attribute is required.");
                }
            }

            return "";
        },

        _phraseAndExtraAttributes: function () {
            return linkPhrase.interpolate(this.linkTypeID(), this.attributes());
        },

        linkPhrase: function (source) {
            return this.phraseAndExtraAttributes()[_.indexOf(this.entities(), source)];
        },

        lowerCasePhrase: function (source) {
            return this.linkPhrase(source).toLowerCase();
        },

        lowerCaseTargetName: function (source) {
            return ko.unwrap(this.target(source).name).toLowerCase();
        },

        paddedSeriesNumber: function () {
            var attributes = this.attributes(), numberAttribute;

            for (var i = 0; numberAttribute = attributes[i]; i++) {
                if (numberAttribute.type.gid === SERIES_ORDERING_ATTRIBUTE) {
                    break;
                }
            }

            if (!numberAttribute) {
                return "";
            }

            var parts = _.compact(numberAttribute.textValue().split(/(\d+)/)),
                integerRegex = /^\d+$/;

            for (var i = 0, part; part = parts[i]; i++) {
                if (integerRegex.test(part)) {
                    parts[i] = _.padLeft(part, 10, "0");
                }
            }

            return parts.join("");
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
                return +target.orderingTypeID() !== SERIES_ORDERING_TYPE_AUTOMATIC;
            }

            return true;
        },

        _moveEntity: function (offset) {
            var vm = this.parent;
            var relationships = vm.source.getRelationshipGroup(this, vm);
            var index = _.indexOf(relationships, this);
            var newIndex = index + offset;

            if (newIndex >= 0 && newIndex <= relationships.length - 1) {
                var other = relationships[newIndex];
                relationships[newIndex] = this;
                relationships[index] = other;

                _.each(relationships, function (r, i) {
                    r.linkOrder(i + 1);
                });
            }
        },

        moveEntityUp: function () {
            this._moveEntity(-1);
        },

        moveEntityDown: function () {
            this._moveEntity(1);
        },

        showLinkOrder: function (source) {
            return this.linkOrder() > 0 && this.entityCanBeReordered(this.target(source));
        },

        isDuplicate: function (other) {
            return (
                this !== other &&
                this.linkTypeID() == other.linkTypeID() &&
                this.linkOrder() == other.linkOrder() &&
                _.isEqual(this.entities(), other.entities()) &&
                mergeDates(this.period.beginDate, other.period.beginDate) &&
                mergeDates(this.period.endDate, other.period.endDate) &&
                attributesAreEqual(this.attributes(), other.attributes())
            );
        },

        openEdits: function () {
            var entities = this.original.entities;
            var entity0 = MB.entity(entities[0]);
            var entity1 = MB.entity(entities[1]);

            return (
                '/search/edits?auto_edit_filter=&order=desc&negation=0&combinator=and' +
                `&conditions.0.field=${encodeURIComponent(entity0.entityType)}` +
                '&conditions.0.operator=%3D' +
                `&conditions.0.name=${encodeURIComponent(entity0.name)}` +
                `&conditions.0.args.0=${encodeURIComponent(entity0.id)}` +
                `&conditions.1.field=${encodeURIComponent(entity1.entityType)}` +
                '&conditions.1.operator=%3D' +
                `&conditions.1.name=${encodeURIComponent(entity1.name)}` +
                `&conditions.1.args.0=${encodeURIComponent(entity1.id)}` +
                '&conditions.2.field=type' +
                '&conditions.2.operator=%3D&conditions.2.args=90%2C233&conditions.2.args=91' +
                '&conditions.2.args=92&conditions.3.field=status&conditions.3.operator=%3D' +
                '&conditions.3.args=1&field=Please+choose+a+condition'
            );
        },

        creditField: function (entity) {
            var entities = this.entities();

            if (entity === entities[0]) {
                return this.entity0_credit;
            }

            if (entity === entities[1]) {
                return this.entity1_credit;
            }
        }
    });


    fields.LinkAttribute = function (data) {
        var type = this.type = MB.attrInfoByID[data.type.gid];

        if (type.creditable) {
            this.creditedAs = ko.observable(ko.unwrap(data.credited_as) || "");
        }

        if (type.freeText) {
            this.textValue = ko.observable(ko.unwrap(data.text_value) || "");
        }
    };

    fields.LinkAttribute.prototype.identity = function () {
        var type = this.type;

        if (type.creditable) {
            return type.gid + "\0" + clean(this.creditedAs());
        }
        if (type.freeText) {
            return type.gid + "\0" + clean(this.textValue());
        }
        return type.gid;
    };

    fields.LinkAttribute.prototype.toJS = function () {
        var type = this.type;
        var output = { type: { gid: type.gid } };

        if (type.creditable) {
            output.credited_as = clean(this.creditedAs());
        }

        if (type.freeText) {
            output.text_value = clean(this.textValue());
        }

        return output;
    };

    ko.bindingHandlers.textAttribute = {
        init: function (element, valueAccessor) {
            var options = valueAccessor(),
                linkAttribute = options.relationship.getAttribute(options.typeGID),
                currentValue = linkAttribute.textValue.peek();

            linkAttribute.textValue.subscribe(function (newValue) {
                if (newValue && !currentValue) {
                    options.relationship.attributes.push(linkAttribute);
                } else if (currentValue && !newValue) {
                    options.relationship.attributes.remove(linkAttribute);
                }
                currentValue = newValue;
            });
            ko.applyBindingsToNode(element, { value: linkAttribute.textValue });
        }
    };

    function entitiesComparer(a, b) {
        return a[0] === b[0] && a[1] === b[1];
    }

    function linkTypeComparer(a, b) { return a != b }

    function setPartialDate(target, data) {
        _.each(["year", "month", "day"], function (key) {
            (target[key] = target[key] || ko.observable())(ko.unwrap(data[key]) || null);
        });
        return target;
    }

    function attributesAreEqual(attributesA, attributesB) {
        if (attributesA.length !== attributesB.length) {
            return false;
        }
        for (var i = 0, a; a = attributesA[i]; i++) {
            var match = false;

            for (var j = i, b; b = attributesB[j]; j++) {
                if (a.identity() === b.identity()) {
                    match = true;
                    break;
                }
            }
            if (!match) return false;
        }
        return true;
    }

    function validAttributes(relationship, attributes) {
        var typeInfo = relationship.linkTypeInfo();

        if (_.isEmpty(attributes) || _.isEmpty(typeInfo) || _.isEmpty(typeInfo.attributes)) {
            return [];
        } else {
            return _.transform(attributes, function (accum, data) {
                var attrInfo = MB.attrInfoByID[data.type.gid];

                if (attrInfo && typeInfo.attributes[attrInfo.rootID]) {
                    accum.push(data);
                }
            });
        }
    }

}(MB.relationshipEditor = MB.relationshipEditor || {}));
