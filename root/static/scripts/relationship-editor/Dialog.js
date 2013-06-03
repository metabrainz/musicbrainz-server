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

var allowedRelations = {
    recording:     ["artist", "label", "recording", "release", "work"],
    work:          ["artist", "label", "work"],
    release:       ["artist", "label", "recording", "release"],
    release_group: ["artist", "release_group"]
};

// For select attributes and the link type field, we use a custom binding handler
// for performance reasons (the instrument tree is huge, for example). We also
// need to support the unaccented instrument names. the builtin options binding
// doesn't allow anything like that.

ko.bindingHandlers.selectAttribute = (function() {

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
        build(Dialog.relationship().attrs(), attr.data, 0, doc);
        return doc;

    }, function(attr) {return attr.data.name});

    return {
        init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            var $element = $(element), attr = valueAccessor(), multi = (attr.max === null);
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

    var previousType, previousDirection, getOptions;

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

    getOptions = _.memoize(function(type, backward) {
        var doc = document.createDocumentFragment();

        $.each(Util.typeInfoByEntities(type), function(i, root) {
            build(root, 0, backward, doc);
        });
        return doc;
    }, function(type, backward) {return type + "-" + backward});

    return {
        update: function(element) {
            var relationship = Dialog.relationship(), type = relationship.type,
                backward = Dialog.backward();

            if (type != previousType || backward != previousDirection) {
                var doc = getOptions(type, backward).cloneNode(true);

                $(element).empty().append(doc).val(relationship.link_type());
                Dialog.resize();

                previousType = type;
                previousDirection = backward;
            }
        }
    };
}());


ko.bindingHandlers.targetType = (function() {

    function change() {
        var mode = Dialog.mode();
        if (!(mode == "add" || /^batch\.(recording|work)$/.test(mode))) return;

        var ac = Dialog.autocomplete, relationship = Dialog.relationship.peek(),
            newTarget = RE.Entity({type: this.value, name: Dialog.target.name}),
            obj = relationship.toJS();

        obj.entity[Dialog.target.gid == obj.entity[0].gid ? 0 : 1] = newTarget;

        // detect when the entity order needs to be reversed.
        // e.g. switching from artist-recording to recording-release.

        var types = [obj.entity[0].type, obj.entity[1].type],
            type = types.join("-"), reverseType = types.reverse().join("-");

        if (!Util.typeInfoByEntities(type) && Util.typeInfoByEntities(reverseType))
            obj.entity.reverse();

        Dialog.relationship(RE.Relationship(obj));
        relationship.remove();

        if (ac) {
            ac.clear();
            ac.changeEntity(this.value);
            Dialog.$autocomplete.find("input.name").removeClass("error");
        }
    }

    return {
        init: function(element) {
            var $element = $(element).change(change), relationship = Dialog.relationship(),
                types = (relationship.type == "recording-work")
                    ? ["work"] : allowedRelations[Dialog.source.type];

            $element.empty();
            $.each(types, function(i, type) {
                $element.append($("<option></option>").val(type).text(MB.text.Entity[type]));
            });
            $element.val(Dialog.target.type);
        }
    };
}());


function setAutocompleteEntity(entity, nameOnly) {
    var $ac = Dialog.$autocomplete, ac = Dialog.autocomplete,
        $name = $ac.find("input.name");

    ac.term = entity.name;
    ac.selectedItem = null;
    $name.removeClass("error lookup-performed").val(entity.name);

    if (nameOnly === false) {
        ac.currentSelection = null;
        $name.addClass("lookup-performed").data("lookup-result", entity);
    }
};


ko.bindingHandlers.autocomplete = (function() {

    var recentEntities = {};

    function setEntity(type) {
        if (!_.contains(allowedRelations[Dialog.source.type], type) ||
                (Dialog.disableTypeSelection() && type != Dialog.target.type)) {
            Dialog.autocomplete.clear();
            return false;
        }
        $("#target-type").val(type).trigger("change");
    }

    function changeTarget(event, data) {
        if (!data.gid) return;

        // XXX release groups' numeric "type" conflicts with the entity type
        data.type = _.isNumber(data.type) ? "release_group" : (data.type || Dialog.target.type);

        // Add/move to the top of the recent entities menu.
        var recent = recentEntities[data.type] = recentEntities[data.type] || [],
            dup = _.where(recent, {gid: data.gid})[0];

        dup && recent.splice(recent.indexOf(dup), 1);
        recent.unshift(data);

        Dialog.targetField.peek()(RE.Entity(data));
    }

    function showRecentEntities(event) {
        if (event.originalEvent === undefined || // event was triggered by code, not user
            (event.type == "keyup" && !_.contains([8, 40], event.keyCode)))
            return;

        var recent = recentEntities[Dialog.target.type],
            ac = Dialog.autocomplete.autocomplete;

        if (!this.value && recent && recent.length && !ac.menu.active) {
            // setting ac.term to "" prevents the autocomplete plugin
            // from running its own search, which closes our menu.
            ac.term = "";
            ac._suggest(recent);
        }
    }

    function fixAutocompleteKeys(event) {
        // In Opera 10, when the keydown event on the autocomplete bubbles up to the
        // dialog, isDefaultPrevented returns false even though here it returns true.
        // Other browsers work fine.
        if ((event.keyCode == 13 && event.isDefaultPrevented()) || event.keyCode == 27)
            event.stopPropagation();

        // Opera doesn't return focus to the autocomplete after pressing esc.
        // without preventDefault.
        if (event.keyCode == 27)
            event.preventDefault();
    }

    return {
        init: function(element) {
            var $autocomplete = Dialog.$autocomplete = $(element);

            Dialog.autocomplete = MB.Control.EntityAutocomplete({
                inputs: $autocomplete,
                entity: Dialog.target.type,
                setEntity: setEntity
            });

            $autocomplete
                .on("lookup-performed", changeTarget)
                .find("input.name")
                    .on("keydown keypress", fixAutocompleteKeys)
                    .on("keyup focus click", showRecentEntities);

            setAutocompleteEntity(Dialog.target, Dialog.mode() != "edit");
        }
    };
}());


var BaseDialog = (function() {
    var inputRegex = /^input|button|select$/;
    var selectChanged = {};

    function dialogKeydown(event) {
        if (event.isDefaultPrevented())
            return;

        var self = this;
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

            if (event.keyCode == 13 && self.canSubmit() && inputRegex.test(nodeName)) {
                self.accept();
            } else if (event.keyCode == 27 && nodeName != "select") {
                self.hide();
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
            this.hide();
        }
    }

    return function(options) {
        options.$dialog
            .on("keydown", _.bind(dialogKeydown, options))
            .on("change", "select", selectChange)
            .find("button.negative").on("keydown", _.bind(cancel, options));
    };
}());


var Dialog = UI.Dialog = {
    MB: MB,
    mode: ko.observable(""),
    loading: ko.observable(false),
    batchWorksError: ko.observable(false),

    showAutocomplete: ko.observable(false),
    showCreateWorkLink: ko.observable(false),
    showAttributesHelp: ko.observable(false),
    showLinkTypeHelp: ko.observable(false),
    disableTypeSelection : ko.observable(false),

    init: function() {
        var self = this, entity = [RE.Entity({type: "artist"}), RE.Entity({type: "recording"})];

        // this is used as an "empty" state when the dialog is hidden, so that
        // none of the bindings error out.
        this.emptyRelationship = RE.Relationship({entity: entity});
        this.relationship = ko.observable(this.emptyRelationship);

        this.backward = ko.observable(true);
        this.sourceField = ko.observable(null);
        this.targetField = ko.observable(null);
        this.source = entity[1];

        this.linkTypeDescription = ko.computed(function() {
            return (Util.typeInfo(Dialog.relationship().link_type()) || {}).descr || "";
        });

        ko.computed(function() {
            var relationship = Dialog.relationship(),
                entity0 = relationship.entity[0],
                entity1 = relationship.entity[1],
                backward = (Dialog.source === entity1());

            if (backward) {
                Dialog.sourceField(entity1);
                Dialog.targetField(entity0);
            } else {
                Dialog.sourceField(entity0);
                Dialog.targetField(entity1);
            }

            Dialog.target = Dialog.targetField.peek()();
            Dialog.backward(backward);
        });

        this.$overlay = $("#overlay");
        this.$dialog = $("#dialog");

        BaseDialog({
            $dialog: this.$dialog,
            canSubmit: function() {
                return !self.relationship.peek().hasErrors.peek();
            },
            accept: function() {self.instance.peek().accept()},
            hide: function() {self.instance.peek().hide()}
        });

        Dialog.instance = ko.observable(this);
        ko.applyBindings(this, this.$dialog[0]);
    },

    show: function(options) {
        var dlg = Dialog, notBatchWorks = dlg.mode.peek() != "batch.create.works";

        dlg.source = options.source;
        dlg.relationship(options.relationship);

        // important: objects down the prototype chain should set "this" when
        // calling show. the template uses instance to decide which accept and
        // hide methods to execute.
        dlg.instance(this);

        dlg.showAutocomplete(notBatchWorks);
        dlg.showCreateWorkLink(options.relationship.type == "recording-work" && notBatchWorks);

        dlg.relationship().validateEntities = true;

        // prevent pressing enter on the create-work button from accepting the dialog.
        if (dlg.showCreateWorkLink.peek())
            $("#create-work-btn").on("keydown", function(event) {
                if (event.keyCode == 13)
                    event.stopPropagation();
            });

        dlg.$overlay.show();
        // prevents the page from jumping. these will be adjusted in positionDialog.
        dlg.$dialog.css({top: $w.scrollTop(), left: $w.scrollLeft()}).show();

        positionDialog(dlg.$dialog, options.posx, options.posy);
        $("#link-type").focus();
    },

    hide: function(callback) {
        var dlg = Dialog;

        WorkDialog.hide();
        dlg.$dialog.hide();
        dlg.$overlay.hide();
        delete dlg.targets;

        dlg.relationship().validateEntities = false;

        if ($.isFunction(callback)) callback.call(dlg);

        dlg.relationship().validateEntities = true;

        dlg.showAutocomplete(false);
        dlg.source = dlg.emptyRelationship.entity[1].peek();
        dlg.relationship(dlg.emptyRelationship);
    },

    accept: function() {},

    createWork: function(data, event) {

        WorkDialog.show(function(work) {
            var target = RE.Entity(work, "work");
            setAutocompleteEntity(target, false);
            Dialog.targetField.peek()(target);

        }, event.pageX, event.pageY);

        WorkDialog.name(Dialog.source.name);
        $("#work-name").focus();
    },

    batchWorksMode: function() {
        $("#work-type").clone(true).removeAttr("id").removeAttr("data-bind")
            .appendTo("#batch-work-type");

        $("#work-language").clone(true).removeAttr("id").removeAttr("data-bind")
            .appendTo("#batch-work-lang");
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
        this.resize();
    },

    toggleLinkTypeHelp: function() {
        this.showLinkTypeHelp(!this.showLinkTypeHelp.peek());
        $("#link-type").parent().find("div.ar-descr a").attr("target", "_blank");
    },

    resize: function() {
        // note: this is called by the afterRender binding.
        resizeDialog(Dialog.$dialog);
    }
};


function resizeDialog($dialog) {
    // we want the dialog's size to "fit" the contents. the ar-descrs stretch
    // the dialog 100%, making this impossible; hide them first.
    var $d = $dialog, $hidden = $();

    $.each($d.find("div.ar-descr, p.msg, div.error"), function(i, div) {
        var $div = $(div);
        if ($div.is(":visible")) $hidden = $hidden.add($div.hide());
    });

    $d.css("width", "").css("width", $d[0].offsetWidth + 2);
    $hidden.show();
}


function positionDialog($dialog, posx, posy) {
    var $d = $dialog;
    if (!$d.is(":visible")) return;

    resizeDialog($d);

    var offx = $w.scrollLeft(), offy = $w.scrollTop(),
        wwidth = $w.width(), wheight = $w.height(),
        dwidth = $d[0].offsetWidth, dheight = $d[0].offsetHeight,
        centerx = offx + (wwidth / 2), centery = offy + (wheight / 2);

    if (!posx || !posy || wwidth < dwidth) {
        $d.css({top: Math.max(offy, centery - dheight), left: centerx - (dwidth / 2)});

    } else {
        $d.css("left", posx <= centerx ? posx : posx - dwidth);

        var dheight2 = dheight / 2, topclear = posy - dheight2 >= offy,
            botclear = posy + dheight2 <= wheight + offy;

        (topclear && botclear)
            ? $d.css("top", posy - dheight2)
            : $d.css("top", topclear ? (wheight + offy - dheight) : offy);
    }
}


Dialog.attrs = (function() {

    var Attribute = function(relationship, attr, info) {
        this.value = relationship.attrs.peek()[attr.name];
        this.data = attr;
        this.min = info[0];
        this.max = info[1];
        this.type = attr.children ? "select" : "boolean";
    };

    return ko.computed({read: function() {
        var relationship = Dialog.relationship(), attrs = [], id,
            linkType = relationship.link_type(),
            typeInfo = Util.typeInfo(linkType);

        if (!typeInfo) return attrs;

        var allowedAttrs = typeInfo.attrs ? MB.utility.keys(typeInfo.attrs) : [];

        allowedAttrs.sort(function(a, b) {
            return Util.attrInfo(a).child_order - Util.attrInfo(b).child_order;
        });

        for (var i = 0; id = allowedAttrs[i]; i++)
            attrs.push(new Attribute(relationship, Util.attrInfo(id), typeInfo.attrs[id]));

        return attrs;
    }, deferEvaluation: true});

}());


UI.AddDialog = MB.utility.beget(Dialog);

UI.AddDialog.show = function(options) {
    options.relationship = RE.Relationship({entity: options.entity, action: "add"});
    this.mode(options.mode || "add");
    this.disableTypeSelection(options.disableTypeSelection || false);
    Dialog.show.call(this, options);
};

UI.AddDialog.accept = function() {
    var relationship = this.relationship();

    if (!relationship.hasErrors()) {
        if (!Dialog.source.mergeRelationship(relationship))
            relationship.show();
        Dialog.hide();
    }
};

UI.AddDialog.hide = function(cancel) {
    Dialog.hide(function() {
        this.relationship.peek().remove();
    });
};


UI.EditDialog = MB.utility.beget(Dialog);

UI.EditDialog.show = function(options) {
    Dialog.mode("edit");

    // originalRelationship is a copy of the relationship when the dialog was
    // opened, i.e. before the user edits it. if they cancel the dialog, this is
    // what gets copied back to revert their changes.
    Dialog.originalRelationship = options.relationship.toJS();
    Dialog.show.call(this, options);
};

UI.EditDialog.hide = function(cancel) {
    Dialog.hide(function() {
        if (cancel !== false)
            this.relationship.peek().fromJS(this.originalRelationship);
        delete Dialog.originalRelationship;
    });
};

UI.EditDialog.accept = function() {
    var relationship = Dialog.relationship();

    if (!relationship.hasErrors()) {
        delete Dialog.originalRelationship;
        UI.EditDialog.hide(false);
    }
};


UI.BatchRelationshipDialog = MB.utility.beget(UI.AddDialog);

UI.BatchRelationshipDialog.show = function(targets) {
    Dialog.targets = targets;

    if (targets.length > 0) {
        var source = targets[0];

        UI.AddDialog.show.call(this, {
            entity: [RE.Entity({type: "artist"}), source],
            source: source,
            mode: "batch." + source.type
        });
    }
};

UI.BatchRelationshipDialog.accept = function(callback) {
    var relationship = Dialog.relationship.peek(),
        model = relationship.toJS(), hasCallback = $.isFunction(callback),
        src = Dialog.backward.peek() ? 1 : 0;

    Util.callbackQueue(Dialog.targets, function(source) {
        model.entity[src] = source;
        delete model.id;

        if (!hasCallback || callback(model)) {
            var newRelationship = RE.Relationship(model);

            if (!source.mergeRelationship(newRelationship))
                newRelationship.show();
        }
    });

    UI.AddDialog.hide();
};


UI.BatchCreateWorksDialog = MB.utility.beget(UI.BatchRelationshipDialog);

UI.BatchCreateWorksDialog.show = function() {
    Dialog.targets = _.filter(UI.checkedRecordings(), function(obj) {
        return obj.performanceRelationships.peek().length == 0;
    });

    if (Dialog.targets.length > 0) {
        var source = Dialog.targets[0], target = RE.Entity({type: "work"});

        // the user can't edit the target in this dialog, but the gid of the
        // temporary target entity has to be set to something valid, so that
        // validation passes and the dialog can be okay'd. we don't want to pass
        // the gid to RE.Entity either, or else the entity will be cached.
        target.gid = "00000000-0000-0000-0000-000000000000";

        UI.AddDialog.show.call(this, {
            entity: [source, target],
            source: source,
            mode: "batch.create.works"
        });
    }
};

UI.BatchCreateWorksDialog.accept = function() {
    Dialog.loading(true);

    var type_id = $("#batch-work-type > select").val(),
        language_id = $("#batch-work-lang > select").val(), works;

    works = _.map(Dialog.targets, function(obj) {
        return {name: obj.name, comment: "", type: type_id, language: language_id};
    });

    function success(data) {
        UI.BatchRelationshipDialog.accept.call(this, function(obj) {
            obj.entity[1] = RE.Entity(data.works.shift(), "work");
            if (data.works.length == 0) Dialog.loading(false);
            return true;
        });
    }

    function error() {
        Dialog.loading(false);
        Dialog.batchWorksError(true);
    }

    RE.createWorks(works, "", success, error);
};

UI.BatchCreateWorksDialog.hide = function() {
    Dialog.hide(function() {
        this.batchWorksError(false);
        this.relationship.peek().remove();
    });
};


var WorkDialog = UI.WorkDialog = {
    RE: RE,
    showName: ko.observable(true),
    loading: ko.observable(false),
    error: ko.observable(false),
    callback: ko.observable(null),

    name: ko.observable(""),
    comment: ko.observable(""),
    type: ko.observable(""),
    language: ko.observable(""),
    editNote: ko.observable(""),

    init: function() {
        var self = this, $dialog = $("#new-work-dialog");

        BaseDialog({
            $dialog: $dialog,
            canSubmit: function() {
                return self.name.peek() && !self.loading.peek();
            },
            accept: this.accept,
            hide: this.hide
        });

        ko.applyBindings(this, $dialog[0]);
    },

    data: function() {
        var self = WorkDialog;

        return {
            name: self.name(),
            comment: self.comment(),
            type: self.type(),
            language: self.language()
        };
    },

    show: function(callback, posx, posy) {
        var self = WorkDialog;

        self.showName(true);
        self.loading(false);
        self.error(false);
        self.callback(callback);

        self.name("");
        self.comment("");
        self.type("");
        self.language("");

        positionDialog($("#new-work-dialog").show(), posx, posy);
    },

    accept: function() {
        var self = WorkDialog;
        self.error(false);
        self.loading(true);

        RE.createWorks([self.data()], self.editNote(),
            self.successCallback, self.errorCallback);
    },

    hide: function() {
        WorkDialog.callback(null);
        $("#new-work-dialog").hide();
        WorkDialog.type("");
        WorkDialog.language("");

        _.defer(function() {
            $("#create-work-btn").focus();
        });
    },

    successCallback: function(data) {
        WorkDialog.loading(false);
        WorkDialog.callback()(data.works[0]);
        WorkDialog.hide();
    },

    errorCallback: function() {
        WorkDialog.loading(false);
        WorkDialog.error(true);
    }
};


return RE;

}(MB.RelationshipEditor || {}));
