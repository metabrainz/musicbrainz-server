/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function bugTrackerURL(description?: string): string {
  return (
    'http://tickets.metabrainz.org/secure/CreateIssueDetails!init.jspa?' +
    'pid=10000&issuetype=1' +
    (nonEmpty(description)
      ? '&description=' + encodeURIComponent(description)
      : '')
  );
}

export default bugTrackerURL;
