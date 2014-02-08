// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var releaseEditor = MB.releaseEditor;


$.ajax = function () {
    var mockXHR = $.Deferred();

    mockXHR.success = mockXHR.done;
    mockXHR.error = mockXHR.fail;
    mockXHR.complete = mockXHR.always;

    return mockXHR;
};


releaseEditor.test = {

    module: function (name, setup) {
        module(name, {
            setup: function () {
                $("#qunit-fixture").append($("<div>").attr("id", "release-editor"));

                if (setup) setup.call(this);

                this.release = releaseEditor.rootField.release();
            },

            teardown: function () {
                releaseEditor.rootField.release(null);
            }
        });
    },

    setupReleaseAdd: function (data) {
        releaseEditor.action = "add";
        releaseEditor.rootField = releaseEditor.fields.Root();
        releaseEditor.seed({ seed: data || {} });
    }
};
