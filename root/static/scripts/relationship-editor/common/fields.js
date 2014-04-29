// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var fields = RE.fields = RE.fields || {};


    fields.Relationship = aclass(MB.entity.Relationship, {

        rateLimitOptions: {
            rateLimit: { method: "notifyWhenChangesStop", timeout: 100 }
        },

        augment$init: function (data, source) {
            this.period = {
                beginDate: setPartialDate({}, data.beginDate || {}),
                endDate: setPartialDate({}, data.endDate || {}),
                ended: ko.observable(!!data.ended)
            };

            var attributes = _(data.attributes || []).map(Number).sort().value();
            this.attributes = ko.observableArray(attributes);

            this.removed = ko.observable(!!data.removed);
            this.editsPending = Boolean(data.editsPending);
            this.uniqueID = this.id || _.uniqueId("new-");

            this.entities.saved = this.entities.peek().slice(0);
            this.entities.subscribe(this.entitiesChanged, this);

            // By default, show all existing relationships on the page.
            if (this.id) this.show();
        },

        after$fromJS: function (data) {
            setPartialDate(this.period.beginDate, data.beginDate || {});
            setPartialDate(this.period.endDate, data.endDate || {});
            this.period.ended(!!data.ended);

            this.attributes(_(data.attributes || []).map(Number).sort().value());

            _.has(data, "removed") && this.removed(!!data.removed);
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

            if (!relationships0) {
                relationships0 = entity0.relationships = ko.observableArray([]);
            }

            if (!relationships1) {
                relationships1 = entity1.relationships = ko.observableArray([]);
            }

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

        remove: function () {
            if (this.removed() === true) return;

            var entities = this.entities();

            entities[0].relationships.remove(this);
            entities[1].relationships.remove(this);

            delete this.parent.cache[this.entityTypes + "-" + this.id];
            this.removed(true);
        },

        phraseAndExtraAttributes: function (source) {
            var origPhrase = this.linkPhrase(source);
            var attributes = this.attributes();
            var extraAttributes = _.transform(attributes, attrNamesByRoot, {});

            var phrase = _.str.clean(origPhrase.replace(/\{(.*?)(?::(.*?))?\}/g,
                    function (match, name, alts) {

                delete extraAttributes[name];
                var root = MB.attrInfo[name];

                var values = _.transform(attributes, function (result, id) {
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

            extraAttributes = MB.utility.joinList(
                _(extraAttributes).values().flatten().value()
            );

            return [phrase, extraAttributes];
        },

        around$isDuplicate: function (supr, other) {
            return (
                supr(other) &&
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


    function attrNamesByRoot(result, id) {
        var attr = MB.attrInfoByID[id];
        var root = attr.root.name;

        (result[root] = result[root] || []).push(attr.l_name);
    }


    function setPartialDate(target, data) {
        _.each(["year", "month", "day"], function (key) {
            (target[key] = target[key] || ko.observable())(ko.unwrap(data[key]) || null);
        });
        return target;
    }


}(MB.relationshipEditor = MB.relationshipEditor || {}));
