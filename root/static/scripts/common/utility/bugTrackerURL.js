// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

function bugTrackerURL(description) {
  return (
    'http://tickets.musicbrainz.org/secure/CreateIssueDetails!init.jspa?' +
    'pid=10000&issuetype=1' +
    (description ? '&description=' + encodeURIComponent(description) : '')
  );
}

module.exports = bugTrackerURL;
