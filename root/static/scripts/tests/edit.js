// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module("edit");


test("missing track numbers should be empty strings, not null (MBS-7246)", function () {
    var data = MB.edit.fields.track({});

    equal(data.number, "", "number is empty string");
});
