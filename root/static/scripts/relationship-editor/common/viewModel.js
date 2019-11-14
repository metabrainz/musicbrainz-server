// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';

import localizeLinkAttributeTypeDescription
    from '../../common/i18n/localizeLinkAttributeTypeDescription';
import localizeLinkAttributeTypeName
    from '../../common/i18n/localizeLinkAttributeTypeName';
import linkedEntities from '../../common/linkedEntities';
import MB from '../../common/MB';
import parseDate from '../../common/utility/parseDate';
import request from '../../common/utility/request';
import {hasSessionStorage} from '../../common/utility/storage';

import fields from './fields';

const addAnotherEntityLabels = {
    area: N_l('Add another area'),
    artist: N_l('Add another artist'),
    event: N_l('Add another event'),
    instrument: N_l('Add another instrument'),
    label: N_l('Add another label'),
    place: N_l('Add another place'),
    recording: N_l('Add another recording'),
    release: N_l('Add another release'),
    release_group: N_l('Add another release group'),
    series: N_l('Add another series'),
    work: N_l('Add another work'),
};

const RE = MB.relationshipEditor = MB.relationshipEditor || {};

    RE.exportTypeInfo = _.once(function (typeInfo, attrInfo) {
        const attrChildren = _.groupBy(attrInfo, x => x.parent_id);

        function mapItems(result, item) {
            if (item.id) {
                result[item.id] = item;
            }
            if (item.gid) {
                result[item.gid] = item;
            }
            switch (item.entityType) {
                case 'link_attribute_type':
                    const children = attrChildren[item.id];
                    if (children) {
                        item.children = children;
                    }
                    break;
                case 'link_type':
                    _.transform(item.children, mapItems, result);
                    break;
            }
        }

        Object.assign(linkedEntities, {
            link_type_tree: typeInfo,
            link_type: _(typeInfo).values().flatten().transform(mapItems, {}).value(),
            link_attribute_type: _.transform(attrInfo, mapItems, {}),
        });

        _.each(linkedEntities.link_type, function (type) {
            _.each(type.attributes, function (typeAttr, id) {
                typeAttr.attribute = linkedEntities.link_attribute_type[id];
            });
        });

        MB.allowedRelations = {};

        _(typeInfo).keys().each(function (typeString) {
            var types = typeString.split("-");
            var type0 = types[0];
            var type1 = types[1];

            if (!editorMayEditTypes(type0, type1)) {
                return;
            }

            (MB.allowedRelations[type0] = MB.allowedRelations[type0] || []).push(type1);

            if (type0 !== type1) {
                (MB.allowedRelations[type1] = MB.allowedRelations[type1] || []).push(type0);
            }
        });

        // Sort each list of types alphabetically.
        _(MB.allowedRelations).values().invokeMap('sort').value();

        _.each(linkedEntities.link_attribute_type, function (attr) {
            attr.root = linkedEntities.link_attribute_type[attr.root_id];
        });
    });


export class ViewModel {
        constructor(options) {
            this.source = options.source;
            this.uniqueID = _.uniqueId("relationship-editor-");
            this.cache = {};
        }

        getRelationship(data, source) {
            return MB.getRelationship(data, source);
        }

        removeRelationship(relationship) {
            if (relationship.added()) {
                relationship.remove();
            } else if (relationship.removed()) {
                relationship.removed(false);
            } else {
                if (relationship.edited()) {
                    relationship.fromJS(relationship.original);
                }
                relationship.removed(true);
            }
        }

        _sortedRelationships(relationships, source) {
            return relationships
                .sortBy(function (r) { return r.lowerCaseTargetName(source) })
                .sortBy("linkOrder");
        }

        addAnotherEntityLabel(group, entity) {
            const entityType = group.values.peek()[0].target(entity).entityType;
            return addAnotherEntityLabels[entityType]();
        }

        localizeLinkAttributeTypeName(type) {
            return localizeLinkAttributeTypeName(type);
        }

        localizeLinkAttributeTypeDescription(type) {
            return localizeLinkAttributeTypeDescription(type);
        }
    }

    Object.assign(ViewModel.prototype, {
        relationshipClass: fields.Relationship,
        activeDialog: ko.observable(),
    });


MB.initRelationshipEditors = function (args) {
    MB.relationshipEditor.exportTypeInfo(args.typeInfo, args.attrInfo);

    var sourceData = args.sourceData;

    // XXX used by series edit form
    sourceData.gid = sourceData.gid || _.uniqueId("tmp-");
    sourceData.uniqueID = sourceData.id || 'source';
    MB.sourceEntityGID = sourceData.gid;
    MB.sourceEntity = MB.entity(sourceData);

    var source = MB.sourceEntity;
    var vmArgs = {source: source, formName: args.formName};

    let {vmClass} = args;
    if (!vmClass) {
        vmClass = require('../generic').GenericEntityViewModel;
    }

    new vmClass(vmArgs);

    var externalLinksEditor = $('#external-links-editor-container')[0];
    if (externalLinksEditor) {
      MB.sourceExternalLinksEditor = MB.createExternalLinksEditor({
        sourceData: sourceData,
        mountPoint: externalLinksEditor,
      });
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
            var cacheKey = _.map(data.entities, "entityType").concat(data.id).join("-");
            var cached = viewModel.cache[cacheKey];

            if (cached) {
                return cached;
            }
        }
        var relationship = new viewModel.relationshipClass(data, source, viewModel);
        return data.id ? (viewModel.cache[cacheKey] = relationship) : relationship;
    }
};

function getRelationshipEditor(data, source) {
    if (source.entityType === 'url') {
        return MB.sourceRelationshipEditor;
    }

    var target = data.target;
    var linkType = linkedEntities.link_type[data.linkTypeID];

    if ((target && target.entityType === 'url') ||
        (linkType && (linkType.type0 === 'url' || linkType.type1 === 'url'))) {
        return; // handled by the external links editor
    }

    if (MB.releaseRelationshipEditor) {
        return MB.releaseRelationshipEditor;
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
    if (!hasSessionStorage) {
        return;
    }

    let submittedRelationships = window.sessionStorage.getItem('submittedRelationships');
    if (MB.formWasPosted && submittedRelationships) {
        _.each(JSON.parse(submittedRelationships), function (data) {
            addSubmittedRelationship(data, source);
        });
    }

    window.sessionStorage.removeItem('submittedRelationships');
}

var loadingEntities = {};

function addRelationshipsFromQueryString(source) {
    var fields = parseQueryString(window.location.search);

    _.each(fields.rels, function (rel) {
        var linkType = linkedEntities.link_type[rel.type];
        var targetIsUUID = uuidRegex.test(rel.target);

        if (!linkType && !targetIsUUID) {
            // We need at least a link type or target gid
            return;
        }

        var target = targetIsUUID ? (MB.entityCache[rel.target] || {gid: rel.target}) : {name: rel.target};

        if (linkType && !target.entityType) {
            target.entityType = source.entityType === linkType.type0 ? linkType.type1 : linkType.type0;
        }

        var data = {
            target: target,
            linkTypeID: linkType ? linkType.id : null,
            begin_date: parseDate(rel.begin_date || ''),
            end_date: parseDate(rel.end_date || ''),
            ended: !!Number(rel.ended),
            direction: rel.direction,
            linkOrder: Number(rel.link_order) || 0,
        };

        if (linkType) {
            data.attributes = _.transform(rel.attributes, function (accum, attr) {
                var attrInfo = linkedEntities.link_attribute_type[attr.type];

                if (attrInfo && linkType.attributes[attrInfo.id]) {
                    accum.push({
                        type: {gid: attr.type},
                        credit: attr.credited_as,
                        textValue: attr.text_value,
                    });
                }
            }, []);
        }

        if (target.entityType && target.name) {
            addSubmittedRelationship(data, source);
        } else if (targetIsUUID) {
            var gid = rel.target;
            var req = loadingEntities[gid];

            if (!req) {
                req = request({url: '/ws/js/entity/' + gid});
                loadingEntities[gid] = req;
            }

            req.done(function (targetData) {
                data.target = targetData;
                addSubmittedRelationship(data, source);
                delete loadingEntities[gid];
            });
        }
    });
}

var uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[345][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;

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

function editorMayEditTypes(type0, type1) {
    var types = [type0, type1].sort().join('-');

    if (/^area-area|area-url$/.test(types)) {
        return !!MB.userIsLocationEditor;
    } else if (/^area-instrument|instrument-instrument|instrument-url$/.test(types)) {
        return !!MB.userIsRelationshipEditor;
    }

    return true;
}
