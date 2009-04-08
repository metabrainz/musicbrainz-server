/*


    // ----------------------------------------------------------------------------
    // member variables
    // ----------------------------------------------------------------------------
    this.form = null;
    this.typeDropDownName = null;
    this.typeDropDown = null;
    this.isurlform = false;
    this.isready = false;
    this.formsubmitted = null;

    // ----------------------------------------------------------------------------
    // member functions
    // ----------------------------------------------------------------------------

    
      Hide all of the divs specified in int_seenattrs.
     
    this.hideAll = function() {
        mb.log.enter(this.GID, "hideAll");
        var seenattrs;
        if ((seenattrs = this.form.int_seenattrs) != null) {
            var list = (seenattrs.value || "").split(",");
            for  (var i=0; i<list.length; i++) {
                var lr = list[i];
                if (lr != "") {
                    mb.ui.setDisplay(lr, false);
                    mb.ui.setDisplay(lr+ "-desc", false);
                }
            }
        } else {
            // addcc.html, addurl.html pages do not specify this.
        }
        mb.log.exit();
    };

    
      internal fields which drive how the javascript function
      interacts with the form elements -->
      int_isurlform, value: 0|1
      int_typedropdown, value: linktypeid|linktype|license
     
      checks for the divs containing the client/server side
      variants of the swap elements html, and enables the
      client side behavior if it is supported (=javascript available)
     
    this.setupForm = function() {
        mb.log.enter(this.GID, "setupForm");

        // hide the notice, which is displayed for browsers
        // which have javascript turned off.
        var obj;
        if ((obj = mb.ui.get("relationshipNoScript")) != null) {
            obj.style.display = "none";
        }

        if ((this.form = mb.ui.get("LinkSelectForm")) != null) {
            if ((this.typeDropDownName = this.form.int_typedropdown) != null) {
                this.typeDropDownName = (this.typeDropDownName.value || "");
                if ((this.typeDropDown = this.form[this.typeDropDownName]) != null) {
                    if ((this.isurlform = this.form.int_isurlform) != null) {
                        this.ready = true;

                        // register event handlers
                        this.typeDropDown.onkeydown = function(event) { arfrontend.typeChanged(); }
                        this.typeDropDown.onchange = function(event) { arfrontend.typeChanged(); }

                        // fire event to setup descriptions etc.
                        this.typeChanged();
                        this.typeDropDown.onkeydown();

                        // add handler which clears the default value upon focus.
                        if (this.isurlform.value == 1) {
                            var urlfield;
                            if ((urlfield = this.form.url) != null) {
                                urlfield.onfocus = function(event) { if (this.value == "http://") this.value = ""; }
                                urlfield.onblur = function(event) { if (this.value == "") this.value = "http://"; }
                                urlfield.onchange = function(event) { arfrontend.guessTypeFromURL(this); }
                                urlfield.onkeyup = function(event) { arfrontend.guessTypeFromURL(this); }
                            } else {
                                mb.log.error("Field url not found in form!");
                            }
                        }
                    } else {
                        mb.log.error("Could not find the hidden field int_isurlform");
                    }
                } else {
                    mb.log.error("Could not find the DropDown given by int_typedropdown $", this.typeDropDownName);
                }

                var elcs, elss;
                if ((elcs = mb.ui.get("arEntitiesSwap-Client")) != null &&
                    (elss = mb.ui.get("arEntitiesSwap-Server")) != null) {
                    elcs.style.display = "block";
                    elss.style.display = "none";
                }

                var entities = getElementsByTagAndClassName('span', 'AR_ENTITY');
                for (var i = 0; i < entities.length; i++) {
                    var e = entities[i];
                    var tmp = e.id.split('::');
                    var index = tmp[1];
                    var type = tmp[2];
                    if (type != 'url') {
                        var button = IMG({'src': '/images/release_editor/edit-off.gif', 'id': '_linkeditimg'+index, 'align': 'absmiddle', 'alt': 'Change this ' + type, 'title': 'Change this ' + type});
                        connect(button, 'onclick', this, partial(this.changeEntity, index, type));
                        replaceChildNodes(e, button, INPUT({'type': 'hidden', 'value': '0', 'id': '_linkedit'+index}));
                    }
                }


            } else {
                mb.log.error("Could not find the hidden field int_typedropdown");
            }
        } else {
            var urlfield;
            if ((urlfield = mb.ui.get("editurl_url")) != null) {
                urlfield.onfocus = function(event) { if (this.value == "http://") this.value = ""; }
                urlfield.onblur = function(event) { if (this.value == "") this.value = "http://"; }
                urlfield.onchange = function(event) { arfrontend.fixURL(this); }
                urlfield.onkeyup = function(event) { arfrontend.fixURL(this); }
            }
        }

        mb.log.exit();
    };

    
      Sets the display attributed of the the div
      with id=id to the show (true|false)


      Sets the description of the current selected element
      from the dropdown list.
     
     
    this.typeChanged = function() {
        mb.log.enter(this.GID, "typeChanged");
        if (this.typeDropDown != null) {
            var selection = this.typeDropDown.value;
            var sp = selection.split("|");
            var attrs = (sp[1] || "");
            var descr = (sp[2] || "");

            if (!this.isurlform != null) {
                this.hideAll();
                if (attrs == "") {
                    mb.ui.setDisplay("relationshipAttributes", false);
                } else {
                    mb.ui.setDisplay("relationshipAttributes", true);
                    var p, pairs = attrs.split(" ");
                    for(p in pairs) {
                        var kv = pairs[p].split('=');
                        if (kv[0] != "") {
                            mb.ui.setDisplay(kv[0], true);
                            mb.ui.setDisplay(kv[0] + "-desc", true);
                        }
                    }
                }
            }

            // update description div
            var el = mb.ui.get("relationshipTypeDesc");
            if (el) {
                if (descr != "") {
                    el.innerHTML = "" + descr;
                    el.setAttribute("className", "relationshipTypeDesc");
                } else if (selection == "||") {
                    el.innerHTML = "Please select a relationship type";
                } else {
                    var tempStr =     "Please select a subtype of the currently selected " +
                                    "relationship type. The selected relationship type is " +
                                    "only used for grouping sub-types.";
                    el.innerHTML = tempStr;
                    if (this.isFormSubmitted()) {
                        el.setAttribute("className", "relationshipTypeError");
                    }
                }
            }
        } else {
            mb.log.error("Cannot find the DropDown $ in the form!", this.typeDropDownName);
        }
        mb.log.exit();
    }


    
      swap the contents of the first and the second element
      which are going to be related to each other.
      (saves a server roundtrip)
     
    this.swapElements = function(theBtn) {
        mb.log.enter(this.GID, "swapElements");
        var theForm = theBtn.form;
        var leftTD = $("arEntitiesSwap-TD0");
        var rightTD = $("arEntitiesSwap-TD1");
        if (leftTD != null && rightTD != null) {
            //var par = leftTD.parentNode;
            //par.replaceChild(leftTD, rightTD);
            //par.replaceChild(rightTD, leftTD);
            var tmp = theForm.link0.value;
            theForm.link0.value = theForm.link1.value
            theForm.link1.value = tmp;
            // edit AR page
            if (theForm.link0name != null && theForm.link1name != null) {
                tmp = theForm.link0name.value;
                theForm.link0name.value = theForm.link1name.value;
                theForm.link1name.value = tmp;
                arfrontend.makeEntityLink(0);
                arfrontend.makeEntityLink(1);
            }
            else {
                tmp = leftTD.innerHTML;
                leftTD.innerHTML = rightTD.innerHTML;
                rightTD.innerHTML = tmp;
            }
        }
        mb.log.exit();
    }

    this.makeEntityLink = function(idx, edit) {
        if (!edit)
            edit = $('_linkedit'+idx);
        edit.value = '0';
        $('_linkeditimg'+idx).src = '/images/release_editor/edit-off.gif';
        $('AR_ENTITY_'+idx).innerHTML = mb.ui.getEntityLink($('link'+idx+'type').value, $('link'+idx).value, $('link'+idx+'name').value);
    }

    this.setEntity = function(idx, entity) {
        $('link'+idx).value = entity.id;
        $('link'+idx+'name').value = entity.name;
        arfrontend.makeEntityLink(idx)
    }

    this.changeEntity = function(idx, type, evt) {
        var edit = $('_linkedit'+idx);
        if (edit.value == '0') {
            edit.value = '1';
            $('_linkeditimg'+idx).src = '/images/release_editor/edit-on.gif';
            var input = INPUT({
                'type': 'text',
                'class': 'textfield',
                'size': '35',
                'maxlength': '255',
                'value': $('link'+idx+'name').value
            });
            jsselect.registerAjaxSelect(input, type, partial(this.setEntity, idx));
            replaceChildNodes($('AR_ENTITY_'+idx), input);
        }
        else {
            arfrontend.makeEntityLink(idx, edit);
        }
    }
*/
