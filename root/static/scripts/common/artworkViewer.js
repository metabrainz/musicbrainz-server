// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Released under the GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.txt

$.widget("mb.artworkViewer", $.ui.dialog, {

    options: {
        modal: true,
        resizable: false,
        autoOpen: false,
        minWidth: 300,
        show: true
    },

    _create: function () {
        this._super();

        // jQuery collection of all the image links we're showing.
        this.$artwork = this.options.$artwork;

        // Only display prev/next buttons if there's >1 image.
        if (this.$artwork.length > 1) {
            // jQuery UI dialogs have a buttons API, but it's difficult to
            // style them like our other ones without duplicating CSS. And
            // it doesn't save a whole lotta code anyway.

            this.$prev = $("<button>").attr("type", "button")
                            .text(MB.text.Previous)
                            .click(_.bind(this.prevImage, this));

            this.$next = $("<button>").attr("type", "button")
                            .text(MB.text.Next)
                            .click(_.bind(this.nextImage, this));

            this.$pager = $("<div>").addClass("artwork-pager");

            this.uiDialog.append(
                $("<div>").addClass("artwork-dialog-controls").append(
                    this.$pager,
                    $("<div>").addClass("buttons").append(this.$prev, this.$next)
                )
            );
        } else {
            this.$prev = this.$next = this.$pager = $();
        }

        this.$loading = $("<div>").addClass("content-loading");
        this.element.addClass("artwork-dialog").append(this.$loading);
    },

    open: function (link, wasClosed) {
        var hadFocus = document.activeElement, $preview = $(link).find("img");
        this._setOption("title", $preview.attr("title"));

        var index = this.$artwork.index(link);
        this._prevLink = this.$artwork[index - 1];
        this._nextLink = this.$artwork[index + 1];

        this.$prev.prop("disabled", !this._prevLink);
        this.$next.prop("disabled", !this._nextLink);

        this.$pager.text(MB.text.ImagePager
            .replace("{current}", index + 1)
            .replace("{total}", this.$artwork.length)
        );

        this._super();

        // Only size the dialog based on the preview image's aspect ratio if
        // the dialog was just opened. If the dialog is already open and the
        // user is simply loading a previous/next image, it'll get resized
        // later, once the image actually loads. But if we were to resize
        // *now*, the current image would get clipped.

        if (wasClosed) {
            this._sizeAndPosition($preview.width() / $preview.height());
        }

        // $.ui.dialog will call _focusTabbable on its own if just opened.
        if (!wasClosed) {
            if (!this._prevLink && hadFocus === this.$prev[0]) {
                this.$next.focus();

            } else if (!this._nextLink && hadFocus === this.$next[0]) {
                this.$prev.focus();
            }
        }
        this._viewImage(link.href);
    },

    close: function (event) {
        this._super(event);
        this.element.find("img").remove();
    },

    _focusTabbable: function () {
        this._nextLink ? this.$next.focus() :
        this._prevLink ? this.$prev.focus() : this._super();
    },

    prevImage: function () {
        this._prevLink && this.open(this._prevLink);
    },

    nextImage: function () {
        this._nextLink && this.open(this._nextLink);
    },

    _viewImage: function (src) {
        this._currentImageSrc = src;

        if (!this._loadImage(src, this._imageLoaded).complete) {
            this.$loading.stop(true, true).fadeIn();
        }
    },

    _loadImage: function (src, callback) {
        var image = document.createElement("img");
        callback && (image.onload = _.bind(callback, this, image));
        image.src = src;
        return image;
    },

    _imageLoaded: function (image) {
        // Return if the user skipped this image or closed the dialog.
        if (!this.isOpen() || image.src !== this._currentImageSrc) return;

        this._sizeAndPosition(image.width / image.height, image);

        this.element.find("img").remove().end().append(image);
        this.$loading.stop(true, true).fadeOut();

        // Preload the previous and next images.
        this._prevLink && this._loadImage(this._prevLink.href);
        this._nextLink && this._loadImage(this._nextLink.href);
    },

    _sizeAndPosition: function (imageAspectRatio, image) {
        var $window = $(window),
            maxDialogHeight = $window.height() * 0.95,
            maxDialogWidth = $window.width() * 0.95,
            nonContentHeight = this.uiDialog.outerHeight() - this.element.height(),
            nonContentWidth = this.uiDialog.outerWidth() - this.element.width(),
            imageHeight = maxDialogHeight - nonContentHeight,
            imageWidth = imageAspectRatio * imageHeight;

        if (imageWidth > maxDialogWidth) {
            imageWidth = maxDialogWidth;
            imageHeight = (1 / imageAspectRatio) * imageWidth;
        }

        this._setOption("width", imageWidth + nonContentWidth);
        this._setOption("height", imageHeight + nonContentHeight);

        this._size();
        this._position();

        if (image) {
            image.width = imageWidth;
            image.height = imageHeight;
        }
    }
});


$(function () {
    var $activeDialog = $();

    // Create separate dialogs for the sidebar and content, so that the
    // image "albums" are logically grouped.
    $("#sidebar, #content").each(function (index, container) {
        var $artwork = $("a.artwork-image", container);
        if ($artwork.length === 0) return;

        var $artworkViewer = $("<div>").appendTo("body")
                .artworkViewer({ $artwork: $artwork });

        $(container).on("click", "a.artwork-image", function (event) {
            if (!(event.which > 1 || event.shiftKey || event.altKey ||
                    event.metaKey || event.ctrlKey)) {

                event.preventDefault();
                $activeDialog = $artworkViewer.artworkViewer("open", this, true);
            }
        });
    });

    $("body")
        .on("keydown", function (event) {
            if ($activeDialog.artworkViewer("isOpen") !== true) return;

            if (event.keyCode === 37) { // Left arrow
                $activeDialog.artworkViewer("prevImage");

            } else if (event.keyCode === 39) { // Right Arrow
                $activeDialog.artworkViewer("nextImage");
            }
        })
        .on("click", ".artwork-dialog img", function () {
            // Close the dialog when the user clicks on the image.
            $(this).parents(".artwork-dialog").artworkViewer("close");
        });
});
