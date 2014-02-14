(function (MB) {

    $.widget("mb.iframeDialog", $.ui.dialog, {

        options: {
            width: 800,
            title: MB.text.Loading,
            resizable: false
        },

        _create: function () {
            this._super();
            var path = encodeURIComponent(this.options.path);

            this.$loading = $("<div>").addClass("content-loading");

            this.$iframe = $("<iframe>")
                .on("load", _.bind(this._onLoad, this))
                .attr("src", "/dialog?path=" + path);

            this.element
                .addClass("iframe-dialog")
                .append(this.$loading, this.$iframe);
        },

        close: function (event) {
            var self = this;

            this._super(event);
            this._destroy();
            this.element.remove();
            event.preventDefault();

            // XXX Returning focus to the "opener" element is handled by $.ui,
            // but it doesn't always work in Opera. This trys to focus again
            // after a small delay, if it hasn't already.
            _.defer(function () {
                if (self.opener[0] !== document.activeElement) {
                    self.opener.focus();
                }
            });
        },

        _onLoad: function (event) {
            var contentWindow = event.target.contentWindow;
            contentWindow.containingDialog = this;

            this.adjustSize(contentWindow.document);
            this.toggleLoading(false);

            this._setOptions({
                title: this.options.title,
                position: { my: "center", at: "center", of: window }
            });
        },

        toggleLoading: function (toggle) {
            this.$loading.fadeToggle(toggle);
        },

        adjustSize: function (contentDocument) {
            $(contentDocument.body).width(this.element.width());
            this.$iframe.height($(contentDocument).height());
        }
    });


    $.widget("mb.createEntityDialog", $.mb.iframeDialog, {

        _create: function () {
            this.options.path = "/" + this.options.entity + "/create";
            this._super();
        },

        _onLoad: function (event) {
            var contentWindow = event.target.contentWindow;

            if (contentWindow.dialogResult) {
                this.options.callback(contentWindow.dialogResult);
                this.close(event);
                return;
            }

            var entity = this.options.entity;
            this.options.title = MB.text.AddANewEntity[entity];
            this._super(event);

            if (this.options.name) {
                var self = this,
                    nameField = "#id-edit-" + entity.replace("_", "-") + "\\.name";

                // Must use contentWindow's jQuery handle or this won't work.
                contentWindow.$(function () {
                    contentWindow._.defer(function () {
                        contentWindow.$(nameField, contentWindow.document)
                            .val(self.options.name).focus();

                        delete self.options.name;
                    });
                });
            }
        }
    });


    // Make sure click events within the dialog don't close RelateTo popups.
    $(function () {
        $("body").on("click", ".ui-dialog", function (event) {
            event.stopPropagation();
        });
    });

}(MB = MB || {}));
