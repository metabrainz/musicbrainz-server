// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2011 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

export default function formatTrackLength(
    milliseconds,
    placeholder = '?:??',
) {
    if (!milliseconds) {
        return placeholder;
    }

    if (milliseconds < 1000) {
        return milliseconds + ' ms';
    }

    var oneMinute = 60;
    var oneHour = 60 * oneMinute;

    var seconds = Math.round(milliseconds / 1000.0);
    var hours = Math.floor(seconds / oneHour);
    seconds %= oneHour;

    var minutes = Math.floor(seconds / oneMinute);
    seconds %= oneMinute;

    var result = ('00' + seconds).slice(-2);

    if (hours > 0) {
        result = hours + ':' + ('00' + minutes).slice(-2) + ':' + result;
    } else {
        result = minutes + ':' + result;
    }

    return result;
}
