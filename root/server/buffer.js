// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt


// Buffer.from apparently exists in some Nodes <= 4.5.0, but is broken,
// throwing "this is not a typed array" if you pass it a string.
//
// Buffer.from doesn't exist at all in versions <= 0.12.
//
// Buffer.allocUnsafe is not known to be broken in any versions, but doesn't
// exist before v5.10 according to the documentation.

try {
  Buffer.from('');
  exports.bufferFrom = Buffer.from;
} catch (e) {
  exports.bufferFrom = function (string) {
    if (typeof string !== 'string') {
      throw new TypeError('expected a string');
    }
    return new Buffer(string);
  };
}

try {
  Buffer.allocUnsafe(1);
  exports.allocBuffer = Buffer.allocUnsafe;
} catch (e) {
  exports.allocBuffer = function (size) {
    if (typeof size !== 'number') {
      throw new TypeError('expected a number');
    }
    return new Buffer(size);
  };
}
