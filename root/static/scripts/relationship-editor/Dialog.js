/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

MB.RelationshipEditor = (function(RE) {

var UI = RE.UI = RE.UI || {}, Util = RE.Util = RE.Util || {}, $w = $(window);

// For select attributes and the link type field, we use a custom binding handler
// for performance reasons (the instrument tree is huge, for example). We also
// need to support the unaccented instrument names. the builtin options binding
// doesn't allow anything like that.

ko.bindingHandlers.selectAttribute = (function() {

    var dialog;

    function build(relationshipAttrs, attr, indent, doc) {

        for (var i = 0, child; child = attr.children[i]; i++) {
            var opt = document.createElement("option"),
                attrs = relationshipAttrs[child.name];

            opt.value = child.id;
            opt.innerHTML = _.repeat("&#160;&#160;", indent) + child.l_name;
            if (child.unaccented) opt.setAttribute("data-unaccented", child.unaccented);
            if (attrs && attrs.indexOf(child.id) > -1) opt.selected = true;
            doc.appendChild(opt);

            if (child.children) build(relationshipAttrs, child, indent + 1, doc);
        }
    }

    var getOptions = _.memoize(function(attr) {
        var doc = document.createDocumentFragment();
        build(dialog.relationship().attrs(), attr.data, 0, doc);
        return doc;

    }, function(attr) {return attr.data.name});

    return {
        init: function (element, valueAccessor, allBindingsAccessor,
                        viewModel, bindingContext) {

            dialog = bindingContext.$parent;

            var $element = $(element),
                attr = valueAccessor(),
                multi = (attr.max === null);

            if (multi) {
                element.multiple = true;
                $element.hide();
            } else {
                $element.append('<option value=""></option>');
            }

            $element.append(getOptions(attr).cloneNode(true)).val(attr.value())
                .change(function() {
                    // for mutiselects, jQuery's val() returns an array
                    var value = $(this).val();
                    attr.value(multi ? $(this).val() : [value]);
                });

            if (multi) {
                var id = attr.data.id, placeholder = "";
                if (id == 14) placeholder = MB.text.FocusInstrument;
                if (id == 3) placeholder = MB.text.FocusVocal;
                $element.multiselect(placeholder, id);
            }
        }
    };
}());


ko.bindingHandlers.linkType = (function() {

    function build(root, indent, backward, doc) {
        var phrase = backward ? root.reverse_phrase : root.phrase;

        // remove {foo} {bar} junk, unless it's for a required attribute.
        var orig_phrase = phrase, re = /\{(.*?)(?::(.*?))?\}/g, m, repl;
        while (m = re.exec(orig_phrase)) {
            var attr = Util.attrRoot(m[1]), info = attr ? root.attrs[attr.id] : [0];
            if (info[0] < 1) {
                repl = (m[2] ? m[2].split("|")[1] : "") || "";
                phrase = phrase.replace(m[0], repl);
            }
        }
        var opt = document.createElement("option");
        opt.value = root.id;
        opt.innerHTML = _.repeat("&#160;&#160;", indent) + _.clean(phrase);
        root.descr || (opt.disabled = true);
        doc.appendChild(opt);

        root.children && $.each(root.children, function(i, child) {
            build(child, indent + 1, backward, doc);
        });
    };

    var getOptions = _.memoize(function(type, backward) {
        var doc = document.createDocumentFragment();

        $.each(Util.typeInfoByEntities(type), function(i, root) {
            build(root, 0, backward, doc);
        });
        return doc;
    }, function(type, backward) {return type + "-" + backward});

    return {
        update: function (element, valueAccessor) {
            var dialog = valueAccessor(),
                relationship = dialog.relationship(),
                type = relationship.type,
                backward = dialog.backward(),
                doc = getOptions(type, backward).cloneNode(true);

            $(element).empty().append(doc).val(relationship.link_type());

            previousType = type;
            previousDirection = backward;
        }
    };
}());


ko.bindingHandlers.targetType = (function() {

    var dialog;

    function change() {
        var ac = dialog.autocomplete,
            relationship = dialog.relationship(),
            obj = relationship.toJSON();

        obj.entity[dialog.target.gid === obj.entity[0].gid ? 0 : 1] = (
            MB.entity({ type: this.value, name: dialog.target.name })
        );

        // detect when the entity order needs to be reversed.
        // e.g. switching from artist-recording to recording-release.
        obj.entity = _.sortBy(obj.entity, "type");

        dialog.relationship(RE.Relationship(obj));
        relationship.remove();

        if (ac) {
            ac.clear();
            ac.changeEntity(this.value);
            dialog.autocomplete.clear();
        }
    }

    return {
        init: function (element, valueAccessor) {
            dialog = valueAccessor();

            var $element = $(element).change(change),
                types = (dialog.relationship().type == "recording-work")
                    ? ["work"] : Util.allowedRelations[dialog.source.type];

            $element.empty();
            $.each(types, function(i, type) {
                $element.append($("<option></option>").val(type).text(MB.text.Entity[type]));
            });
            $element.val(dialog.target.type);
        }
    };
}());


ko.bindingHandlers.autocomplete = (function() {

    var recentEntities = {};
    var dialog;

    function setEntity(type) {
        if (!_.contains(Util.allowedRelations[dialog.source.type], type) ||
                (dialog.disableTypeSelection && type !== dialog.target.type)) {
            dialog.autocomplete.clear();
            return false;
        }
        $("#target-type").val(type).trigger("change");
    }

    function changeTarget(data) {
        if (!data || !data.gid) {
            return;
        }
        data.type = data.type || dialog.target.type;

        // Add/move to the top of the recent entities menu.
        var recent = recentEntities[data.type] = recentEntities[data.type] || [],
            dup = _.where(recent, {gid: data.gid})[0];

        dup && recent.splice(recent.indexOf(dup), 1);
        recent.unshift(data);

        dialog.targetField.peek()(MB.entity(data));
    }

    function showRecentEntities(event) {
        if (event.originalEvent === undefined || // event was triggered by code, not user
            (event.type == "keyup" && !_.contains([8, 40], event.keyCode)))
            return;

        var recent = recentEntities[dialog.target.type],
            ac = dialog.autocomplete;

        if (!this.value && recent && recent.length && !ac.menu.active) {
            // setting ac.term to "" prevents the autocomplete plugin
            // from running its own search, which closes our menu.
            ac.term = "";
            ac._suggest(recent);
        }
    }

    return {
        init: function (element, valueAccessor) {
            dialog = valueAccessor();

            dialog.autocomplete = $(element).autocomplete({
                    entity: dialog.target.type,
                    setEntity: setEntity
                })
                .data("ui-autocomplete");

            dialog.autocomplete.currentSelection.subscribe(changeTarget);

            $(element).on("keyup focus click", showRecentEntities);

            if (dialog instanceof UI.EditDialog) {
                dialog.autocomplete.currentSelection(dialog.target);
            } else {
                // Fills in the recording name in the add-related-work dialog.
                dialog.autocomplete.currentSelection({
                    name: dialog.target.name
                });
            }
        }
    };
}());


$(function () {
    var inputRegex = /^input|select$/;
    var selectChanged = {};

    function dialogKeydown(event) {
        if (event.isDefaultPrevented())
            return;

        var dialog = RE.releaseViewModel.activeDialog();
        var target = event.target;
        var nodeName = target.nodeName.toLowerCase();

        if (nodeName == "select" && target.id)
            selectChanged[target.id] = false;

        /* While both Firefox and Opera 10 trigger the change event after
         * keydown, Opera does not update the select's value attribute until
         * after the change event has occured. Delay this event so that it
         * always runs after that attribute has changed.
         */
        _.defer(function() {
            if (nodeName == "select" && selectChanged[target.id])
                return;

            if (event.keyCode == 13 && dialog.canSubmit() && inputRegex.test(nodeName)) {
                dialog.accept();
            } else if (event.keyCode == 27 && nodeName != "select") {
                dialog.close();
            }
        });
    }

    /* Firefox's select menus are weird - after opening the menu, you have to
     * press enter *twice* to trigger the change event, unlike in Chrome.
     * We don't want the user to accidentally submit the dialog when they only
     * intended to submit the select menu. Since there's no good way to
     * determine whether the select menu was open when they pressed enter, we
     * can at least detect whether a change event has occured.
     */
    function selectChange(event) {
        var select = event.target;
        if (_.has(selectChanged, select.id))
            selectChanged[select.id] = true;
    }

    function cancel(event) {
        if (event.keyCode == 13) {
            event.preventDefault();
            event.stopPropagation();
            RE.releaseViewModel.activeDialog().close();
        }
    }

    var $dialog = $("#dialog");

    // This should never happen, except during unit tests.
    if ($dialog.length === 0) return;

    var widget = $dialog.dialog({
        dialogClass: "rel-editor-dialog",
        draggable: false,
        resizable: false,
        autoOpen: false,
        width: "auto"
    }).data("ui-dialog");

    widget.uiDialog.find(".ui-dialog-titlebar").remove();

    widget.element
        .on("keydown", dialogKeydown)
        .on("change", "select", selectChange)
        .find("button.negative").on("keydown", cancel);

    Dialog.extend({ widget: widget });

    ko.applyBindingsToNode(widget.element[0], {
        "with": RE.releaseViewModel.activeDialog
    });
});


var Dialog = aclass({

    MB: MB,
    loading: ko.observable(false),
    showAttributesHelp: ko.observable(false),
    showLinkTypeHelp: ko.observable(false),

    init: function (options) {
        var self = this,
            source = options.source,
            target = options.target;

        if (!options.relationship) {
            var testType = source.type + "-" + target.type,
                forwards = !!Util.typeInfoByEntities(testType);

            options.relationship = RE.Relationship({
                action: "add",
                entity: forwards ? [ source, target ] : [ target, source ]
            });
        }

        this.relationship = ko.observable(options.relationship);
        this.backward = ko.observable(true);
        this.sourceField = ko.observable(null);
        this.targetField = ko.observable(null);
        this.source = source;

        this.linkTypeDescription = ko.computed(function() {
            var typeInfo = Util.typeInfo(self.relationship().link_type());
            var description = '';

            if (typeInfo) {
                description += typeInfo.descr +
                  ' (<a href="/relationship/' + typeInfo.gid + '">' + 'more documentation</a>)';
            }

            return description || "";
        });

        ko.computed(function() {
            var relationship = self.relationship(),
                entity0 = relationship.entity[0],
                entity1 = relationship.entity[1],
                backward = (self.source === entity1());

            if (backward) {
                self.sourceField(entity1);
                self.targetField(entity0);
            } else {
                self.sourceField(entity0);
                self.targetField(entity1);
            }

            self.target = self.targetField.peek()();
            self.backward(backward);
        });

        this.attrs = ko.computed(function () {
            var relationship = self.relationship(),
                typeInfo = Util.typeInfo(relationship.link_type());

            if (!typeInfo) return [];

            var allowedAttrs = typeInfo.attrs ? MB.utility.keys(typeInfo.attrs) : [];

            allowedAttrs.sort(function (a, b) {
                return Util.attrInfo(a).child_order - Util.attrInfo(b).child_order;
            });

            return _.map(allowedAttrs, function (id) {
                return new DialogAttribute(
                    relationship, Util.attrInfo(id), typeInfo.attrs[id]
                );
            });
        });

        options.relationship.validateEntities = true;
    },

    open: function (positionBy) {
        var widget = this.widget;

        RE.releaseViewModel.activeDialog(this);

        this.positionBy(positionBy);
        widget.open();

        if (widget.uiDialog.width() > widget.options.maxWidth) {
            widget.uiDialog.width(widget.options.maxWidth);
        }

        // Call this.positionBy twice to prevent jumping in Opera
        this.positionBy(positionBy);

        $("#link-type").focus();
    },

    accept: function (inner) {
        if (!this.relationship().hasErrors()) {
            inner && inner.apply(this, _.toArray(arguments).slice(1));
            this.close(false);
        }
    },

    close: function () {
        if (this.widget) this.widget.close();
    },

    canSubmit: function() {
        return !this.relationship().hasErrors();
    },

    toggleAttributesHelp: function() {
        this.showAttributesHelp(!this.showAttributesHelp());
    },

    changeDirection: function() {
        var relationship = this.relationship.peek(),
            entity0 = relationship.entity[0].peek(),
            entity1 = relationship.entity[1].peek();

        relationship.validateEntities = false;
        relationship.entity[0](entity1);
        relationship.validateEntities = true;
        relationship.entity[1](entity0);
    },

    toggleLinkTypeHelp: function() {
        this.showLinkTypeHelp(!this.showLinkTypeHelp.peek());
        $("#link-type").parent().find("div.ar-descr a").attr("target", "_blank");
    },

    positionBy: function (element) {
        this.widget._setOption("position", {
            my: "top center", at: "center", of: element
        });
    }
});


function DialogAttribute(relationship, attr, info) {
    this.value = relationship.attrs.peek()[attr.name];
    this.data = attr;
    this.min = info[0];
    this.max = info[1];
    this.type = attr.children ? "select" : "boolean";
}


UI.AddDialog = aclass(Dialog, {

    dialogTemplate: "template.relationship-dialog",
    disableTypeSelection: false,

    augment$accept: function () {
        if (!this.source.mergeRelationship(this.relationship())) {
            this.relationship().show();
        }
    },

    before$close: function (cancel) {
        if (cancel !== false) {
            this.relationship().remove();
        }
    }
});


UI.EditDialog = aclass(Dialog, {

    dialogTemplate: "template.relationship-dialog",
    disableTypeSelection: true,

    before$init: function (options) {
        // originalRelationship is a copy of the relationship when the dialog
        // was opened, i.e. before the user edits it. if they cancel the
        // dialog, this is what gets copied back to revert their changes.
        this.originalRelationship = options.relationship.toJSON();
    },

    before$close: function (cancel) {
        if (cancel !== false) {
            this.relationship().fromJS(this.originalRelationship);
        }
    }
});


UI.BatchRelationshipDialog = aclass(Dialog, {

    dialogTemplate: "template.batch-relationship-dialog",
    disableTypeSelection: false,

    around$init: function (supr, targets, tempTarget) {
        this.targets = targets;

        var source = targets[0];

        tempTarget = tempTarget || MB.entity({ type: "artist" });

        supr({ source: source, target: tempTarget });
    },

    augment$accept: function (callback) {
        var model = this.relationship().toJSON(),
            hasCallback = $.isFunction(callback),
            sourceIndex = this.backward() ? 1 : 0;

        MB.utility.callbackQueue(this.targets, function (source) {
            model.entity[sourceIndex] = source;
            delete model.id;

            if (!hasCallback || callback(model)) {
                var newRelationship = RE.Relationship(model);

                if (!source.mergeRelationship(newRelationship)) {
                    newRelationship.show();
                }
            }
        });
    }
});


UI.BatchCreateWorksDialog = aclass(UI.BatchRelationshipDialog, {

    dialogTemplate: "template.batch-create-works-dialog",
    workType: ko.observable(null),
    workLanguage: ko.observable(null),

    around$init: function (supr, targets) {
        this.error = ko.observable(false);

        // The user can't edit the target in this dialog, but the gid of the
        // temporary target entity has to be set to something valid, so that
        // validation passes and the dialog can be okay'd. We don't want to
        // pass the gid to MB.entity either, or the entity will be cached.

        var tempTarget = MB.entity({ type: "work" });
        tempTarget.gid = MB.constants.VARTIST_GID;

        supr(targets, tempTarget);
    },

    around$accept: function (supr) {
        var self = this,
            workType = this.workType(),
            workLang = this.workLanguage();

        this.loading(true);

        var works = _.map(this.targets, function (target) {
            return {
                name: target.name,
                comment: "",
                type: workType,
                language: workLang
            };
        });

        function success(data) {
            supr(function (target) {
                target.entity[1] = MB.entity(data.works.shift(), "work");

                if (data.works.length == 0) {
                    self.loading(false);
                }
                return true;
            });
        }

        function error() {
            self.loading(false);
            self.error(true);
        }

        RE.createWorks(works, "", success, error);
    },

    after$close: function () {
        this.relationship().remove();
    }
});


return RE;

}(MB.RelationshipEditor || {}));
