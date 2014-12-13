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


    RE.exportTypeInfo = _.once(function (typeInfo, attrInfo) {
        MB.typeInfo = typeInfo;
        MB.attrInfo = attrInfo;

        MB.typeInfoByID = _(typeInfo).values().flatten().transform(mapItems, {}).value();
        MB.attrInfoByID = _(attrInfo).values().transform(mapItems, {}).value();

        _.each(MB.typeInfoByID, function (type) {
            _.each(type.attributes, function (typeAttr, id) {
                typeAttr.attribute = MB.attrInfoByID[id];
            });
        });

        MB.allowedRelations = {};

        _(MB.typeInfo).keys().each(function (typeString) {
            var types = typeString.split("-");
            var type0 = types[0];
            var type1 = types[1];

            if (typesAreRestricted(type0, type1)) {
                return;
            }

            (MB.allowedRelations[type0] = MB.allowedRelations[type0] || []).push(type1);

            if (type0 !== type1) {
                (MB.allowedRelations[type1] = MB.allowedRelations[type1] || []).push(type0);
            }
        });

        _.each(MB.attrInfoByID, function (attr) {
            attr.root = MB.attrInfoByID[attr.rootID];
        });
    });


    RE.ViewModel = aclass({

        relationshipClass: RE.fields.Relationship,

        init: function (options) {
            this.source = options.source;
            this.uniqueID = _.uniqueId("relationship-editor-");
            this.cache = {};

            if (options.formName) {
                this.formName = options.formName;
            }
        },

        getRelationship: function (data, source) {
            return MB.getRelationship(data, source);
        }
    });

}(MB.relationshipEditor = MB.relationshipEditor || {}));

MB.initRelationshipEditors = function (args) {
    MB.relationshipEditor.exportTypeInfo(args.typeInfo, args.attrInfo);

    var sourceData = args.sourceData;

    // XXX used by series edit form
    sourceData.gid = sourceData.gid || _.uniqueId("tmp-");
    MB.sourceEntityGID = sourceData.gid;

    var source = MB.entity(sourceData);
    var vmArgs = { source: source, formName: args.formName };

    MB.relationshipEditor.GenericEntityViewModel(vmArgs);

    if ($('#external-links-editor').length) {
        MB.Control.externalLinks.applyBindings(vmArgs);
    }

    source.parseRelationships(sourceData.relationships);

    addPostedRelationships(source);

    if (!MB.formWasPosted) {
        addRelationshipsFromQueryString(source);
    }

    var $content = $("#relationship-editor");
    ko.applyBindings(MB.sourceRelationshipEditor, $content[0]);
    $content.show();
};

MB.getRelationship = function (data, source) {
    var target = data.target;

    data = _.clone(data);

    var backward = source.entityType > target.entityType;

    if (source.entityType === target.entityType) {
        backward = (data.direction === "backward");
    }

    data.entities = backward ? [target, source] : [source, target];

    var viewModel = getRelationshipEditor(data, source);

    if (viewModel) {
        if (data.id) {
            var cacheKey = _.pluck(data.entities, "entityType").concat(data.id).join("-");
            var cached = viewModel.cache[cacheKey];

            if (cached) {
                return cached;
            }
        }
        var relationship = viewModel.relationshipClass(data, source, viewModel);
        return data.id ? (viewModel.cache[cacheKey] = relationship) : relationship;
    }
};

function getRelationshipEditor(data, source) {
    if (MB.releaseRelationshipEditor) {
        return MB.releaseRelationshipEditor;
    }

    var target = data.target;
    var typeInfo = MB.typeInfoByID[data.linkTypeID];

    if ((target && target.entityType === 'url') ||
        (typeInfo && (typeInfo.type0 === 'url' || typeInfo.type1 === 'url'))) {
        return MB.sourceExternalLinksEditor;
    }

    if (source === MB.sourceRelationshipEditor.source) {
        return MB.sourceRelationshipEditor;
    }
}

function addSubmittedRelationship(data, source) {
    var relationship = MB.getRelationship(data, source);
    if (!relationship) {
        return;
    } else if (relationship.id) {
        relationship.fromJS(data);
    } else {
        relationship.show();
    }
}

function addPostedRelationships(source) {
    if (MB.hasSessionStorage && sessionStorage.submittedRelationships) {
        if (MB.formWasPosted) {
            _.each(JSON.parse(sessionStorage.submittedRelationships), function (data) {
                addSubmittedRelationship(data, source);
            });
        }
        delete sessionStorage.submittedRelationships;
    }
}

function addRelationshipsFromQueryString(source) {
    var fields = parseQueryString(window.location.search);

    _.each(fields.rels, function (rel) {
        var typeInfo = MB.typeInfoByID[rel.type];
        var targetIsUUID = v4_uuid_regex.test(rel.target);

        if (!typeInfo && !targetIsUUID) {
            // We need at least a link type or target gid
            return;
        }

        var target = targetIsUUID ? (MB.entityCache[rel.target] || { gid: rel.target }) : { name: rel.target };

        if (typeInfo && !target.entityType) {
            target.entityType = source.entityType === typeInfo.type0 ? typeInfo.type1 : typeInfo.type0;
        }

        var data = {
            target: target,
            linkTypeID: typeInfo ? typeInfo.id : null,
            beginDate: parseDateString(rel.begin_date || ''),
            endDate: parseDateString(rel.end_date || ''),
            ended: !!Number(rel.ended),
            direction: rel.direction,
            linkOrder: Number(rel.link_order) || 0
        };

        if (typeInfo) {
            data.attributes = _.transform(rel.attributes, function (accum, attr) {
                var attrInfo = MB.attrInfoByID[attr.type];

                if (attrInfo && typeInfo.attributes[attrInfo.id]) {
                    accum.push({
                        type: { gid: attr.type },
                        credit: attr.credited_as,
                        textValue: attr.text_value
                    });
                }
            }, []);
        }

        if (target.entityType) {
            addSubmittedRelationship(data, source);
        } else {
            MB.utility.request({ url: '/ws/js/entity/' + rel.target })
              .done(function (targetData) {
                  data.target = targetData;
                  addSubmittedRelationship(data, source);
              });
        }
    });

    _.each(fields.url, function (data) {
        addSubmittedRelationship({
            linkTypeID: data.link_type_id,
            target: { name: data.text || '', entityType: 'url' },
        }, source);
    });
}

var v4_uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;

var dateRegex = /(?:-|([0-9]{4}))(?:-(?:-|(0[1-9]|1[0-2]))(?:-(?:-|([0-2][1-9]|3[0-1])))?)?/;

function parseQueryString(queryString) {
    var queryStringRegex = /(?:\\?|&)([A-z0-9\-_.]+)=([^&]+)/g;
    var fields = {};
    var subField, match, parts;

    while (match = queryStringRegex.exec(queryString)) {
        subField = fields;
        parts = match[1].split('.');

        _.each(parts, function (part, index) {
            if (index === parts.length - 1) {
                subField[part] = decodeURIComponent(match[2])
            } else {
                subField = subField[part] = subField[part] || {};
            }
        });
    }

    return fields;
}

function parseDateString(string) {
    var match = string.match(dateRegex);
    if (match) {
        return {
            year: match[1] || null,
            month: match[2] || null,
            day: match[3] || null
        };
    }
    return null;
}

function typesAreRestricted(type0, type1) {
    return (
        (!MB.userIsLocationEditor && (type0 === 'area' || type1 === 'area')) ||
        (!MB.userIsRelationshipEditor && (type0 === 'instrument' || type1 === 'instrument'))
    );
}
