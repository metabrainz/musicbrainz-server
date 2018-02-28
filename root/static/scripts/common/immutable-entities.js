// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {VARTIST_GID} = require('./constants');
const nonEmpty = require('./utility/nonEmpty');

const reduceName = (memo, x) =>
  memo +
  (nonEmpty(x.name) ? x.name : (x.artist && nonEmpty(x.artist.name) ? x.artist.name : '')) +
  (nonEmpty(x.joinPhrase) ? x.joinPhrase : '');

const isVariousArtist = name => name.artist ? name.artist.gid === VARTIST_GID : false;

const hasVariousArtists = ac => ac.some(isVariousArtist);

const hasArtist = name => !!(name.artist && name.artist.gid);

const isCompleteArtistCredit = ac => ac.length > 0 && ac.every(hasArtist);

const reduceArtistCredit = ac => ac.reduce(reduceName, '');

const isComplexArtistCredit = function (ac) {
  const firstName = ac[0];
  if (firstName && hasArtist(firstName)) {
     return !nonEmpty(firstName.name) || firstName.artist.name !== reduceArtistCredit(ac);
  }
  return false;
};

function artistCreditFromArray(ac) {
  return ac.map(function (x) {
    x = {
      artist: x.artist,
      joinPhrase: x.joinPhrase,
      name: x.name,
    };
    if (x.artist && !nonEmpty(x.name)) {
      x.name = x.artist.name;
    }
    return x;
  });
}

function artistCreditsAreEqual(a, b) {
  if (a === b) {
    return true;
  }

  if (a.length !== b.length) {
    return false;
  }

  for (let i = 0; i < a.length; i++) {
    const aName = a[i];
    const bName = b[i];

    const aHasArtist = hasArtist(aName);
    const bHasArtist = hasArtist(bName);

    if ((aHasArtist !== bHasArtist) ||
        (aHasArtist && aName.artist.gid !== bName.artist.gid) ||
        (aName.name !== bName.name) ||
        (aName.joinPhrase !== bName.joinPhrase)) {
      return false;
    }
  }

  return true;
}

exports.artistCreditFromArray = artistCreditFromArray;
exports.artistCreditsAreEqual = artistCreditsAreEqual;
exports.hasArtist = hasArtist;
exports.hasVariousArtists = hasVariousArtists;
exports.isCompleteArtistCredit = isCompleteArtistCredit;
exports.isComplexArtistCredit = isComplexArtistCredit;
exports.reduceArtistCredit = reduceArtistCredit;
