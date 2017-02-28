// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const Immutable = require('immutable');

const {VARTIST_GID} = require('./constants');
const nonEmpty = require('./utility/nonEmpty');

const ArtistCredit = Immutable.Record({
  names: Immutable.List(),
});

const ArtistCreditName = Immutable.Record({
  name: '',
  artist: {name: ''},
  joinPhrase: '',
  automaticJoinPhrase: true,
});

const reduceName = (memo, x) =>
  memo +
  (nonEmpty(x.name) ? x.name : (x.artist && nonEmpty(x.artist.name) ? x.artist.name : '')) +
  (nonEmpty(x.joinPhrase) ? x.joinPhrase : '');

const isVariousArtist = name => name.artist ? name.artist.gid === VARTIST_GID : false;

const hasVariousArtists = ac => ac.names.some(isVariousArtist);

const hasArtist = name => !!(name.artist && name.artist.gid);

const isCompleteArtistCredit = ac => ac.names.size > 0 && ac.names.every(hasArtist);

const reduceArtistCredit = ac => ac.names.reduce(reduceName, '');

const isComplexArtistCredit = function (ac) {
  const firstName = ac.names.get(0);
  if (firstName && hasArtist(firstName)) {
     return !nonEmpty(firstName.name) || firstName.artist.name !== reduceArtistCredit(ac);
  }
  return false;
};

function artistCreditFromArray(names) {
  return new ArtistCredit({
    names: Immutable.List(names.map(x => {
      if (x.artist && !nonEmpty(x.name)) {
        x.name = x.artist.name;
      }
      return new ArtistCreditName(x);
    }))
  });
}

function artistCreditsAreEqual(a, b) {
  if (a === b) {
    return true;
  }

  const aNames = a.names;
  const bNames = b.names;

  if (aNames.size !== bNames.size) {
    return false;
  }

  for (let i = 0; i < aNames.size; i++) {
    const aName = aNames.get(i);
    const bName = bNames.get(i);

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

exports.ArtistCredit = ArtistCredit;
exports.artistCreditFromArray = artistCreditFromArray;
exports.ArtistCreditName = ArtistCreditName;
exports.artistCreditsAreEqual = artistCreditsAreEqual;
exports.hasArtist = hasArtist;
exports.hasVariousArtists = hasVariousArtists;
exports.isCompleteArtistCredit = isCompleteArtistCredit;
exports.isComplexArtistCredit = isComplexArtistCredit;
exports.reduceArtistCredit = reduceArtistCredit;
