// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const entityLink = require('./entityLink');

function artistCreditLink(ac) {
  return ac.reduce(function (accum, name) {
    if (name.artist.gid) {
      accum.push(entityLink(ac.artist, {name: name.name}));
    } else {
      accum.push(name.name);
    }
    accum.push(name.join_phrase);
    return accum;
  }, []);
}

module.exports = artistCreditLink;
