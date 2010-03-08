function JsSelect()
{

    this.CN = "JsSelect";
    this.GID = "jsselect";

    this.newId = 0;
    this.selects = new Object();
    this.loadingImage = new Image();
    this.loadingImage.src = "/images/loading-small.gif";

    this.initialise = function()
    {
        lookupButton = BUTTON({}, 'Lookup');
        connect(lookupButton, 'onclick', this, this.lookup);
        this.list = DIV({'class': 'ajaxSelectContent'});
        this.selectbox = DIV({'style': 'display:none; position:absolute; z-index:100;', 'class': 'ajaxSelect'},
                this.list, DIV({'class': 'ajaxSelectButtonBox'}, lookupButton));
        this.selectbox.onmouseover = function(e) { jsselect.ignoreFocusEvents = true; };
        this.selectbox.onmouseout = function(e) { jsselect.ignoreFocusEvents = false; };
        insertSiblingNodesAfter('overDiv', this.selectbox);
    };

    this.lookup = function(event)
    {
        this.selects[this.id].element.focus();
        this.showInfo('<img src="/images/loading-small.gif" alt="" /> Searching...');
        var callback = function(doc) { jsselect.showResults(doc); }
        var errback = function(err) { jsselect.showError(); }
        var url = '/ws/priv/lookup?entitytype=' + this.selects[this.id].entitytype + '&query=' + encodeURIComponent(this.selects[this.id].element.value);
        mb.log.debug('Lookup: ' + url);
        var d = loadJSONDoc(url);
        d.addCallbacks(callback, errback);
    }

    this.selectOption = function(entity, event)
    {
        var callback = this.selects[this.id].callback;
        if (callback) {
                var owner = this.selects[this.id].owner;
                if (owner) {
                        callback.apply(owner, [entity]);
                }
                else {
                        callback(entity);
                }
        }
        this.hide(true);
    }

    this.showInfo = function(html)
    {
        this.list.innerHTML = '<div class="ajaxSelectLoading">' + html + '</div>';
    }

    this.showError = function()
    {
        this.showInfo('Lookup failed!');
    }

    this.showResults = function(doc)
    {
        var entitytype = this.selects[this.id].entitytype;
        var options = new Array();
        if (doc.results.length) {
                for (var i = 0; i < doc.results.length; i++) {
                        var entity, c = new Array(), result = doc.results[i];
                        if (entitytype == 'artist') {
                                entity = result.artist;
                                c.push(entity.name);
                                if (entity.resolution) {
                                        c.push(SPAN({'class': 'small'}, ' (' + entity.resolution + ')'));
                                }
                        }
                        else if (entitytype == 'label') {
                                entity = result.label;
                                c.push(entity.name);
                                if (entity.resolution) {
                                        c.push(SPAN({'class': 'small'}, ' (' + entity.resolution + ')'));
                                }
                        }
                        else if (entitytype == 'track') {
                                entity = result.track;
                                c.push(entity.name);
                                c.push(SPAN({'class': 'small'}, ' (Artist: ' + result.artist.name + ', Release: ' + result.album.name + ')'));
                        }
                        else if (entitytype == 'album') {
                                entity = result.album;
                                c.push(entity.name);
                                c.push(SPAN({'class': 'small'}, ' (Artist: ' + result.artist.name + ')'));
                        }
                        var option = A({'href': '#', 'class': 'ajaxSelectOption'}, c);
                        connect(option, 'onmousedown', this, partial(this.selectOption, entity));
                        options.push(option);
                }
                replaceChildNodes(this.list, options);
        }
        else {
                this.list.innerHTML = '<div class="ajaxSelectLoading">No results.</div>';
        }
    }

    this.show = function(id, event)
    {
        if (!this.ignoreFocusEvents) {
                this.id = id;
                this.showInfo('');
                var element = this.selects[id].element;
                var pos = getElementPosition(element);
                pos.y += getElementDimensions(element).h;
                setElementPosition(this.selectbox, pos);
                showElement(this.selectbox);
        }
    }

    this.hide = function(force, event)
    {
        if (!this.ignoreFocusEvents || force) {
                hideElement(this.selectbox);
                this.ignoreFocusEvents = false;
        }
    }

    this.registerAjaxSelect = function(el, entitytype, callback, owner)
    {
        var id = ++this.newId;
        connect(el, 'onfocus', this, partial(this.show, id));
        connect(el, 'onblur', this, partial(this.hide, false));
        this.selects[id] = {
                'element': el,
                'entitytype': entitytype,
                'callback': callback,
                'owner': owner
        };
        return id;
    }

}

var jsselect = new JsSelect();
mb.registerDOMReadyAction(new MbEventAction("jsselect", "initialise", "Init JsSelect"));
