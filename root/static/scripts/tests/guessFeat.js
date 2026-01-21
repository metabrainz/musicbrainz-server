/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import test from 'tape';

import guessFeat, {guessFeatForReleaseEditor as guessFeatKo}
  from '../edit/utility/guessFeat.js';
import fields from '../release-editor/fields.js';

/* eslint-disable sort-keys */
test('guessing feat. artists', function (t) {
  t.plan(71);

  const recordingTests = [
    {
      input: {
        entityType: 'recording',
        name: 'мыльныйопус (feat.813)',
        artistCredit: {names: [{name: 'micromatics', joinPhrase: ''}]},
      },
      output: {
        name: 'мыльныйопус',
        artistCredit: {
          names: [
            {name: 'micromatics', joinPhrase: ' feat. '},
            {artist: null, name: '813', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'recording',
        name: 'Fix (Main Mix) (feat. Slash & Ol\' Dirty Bastard)',
        artistCredit: {names: [{name: 'Blackstreet', joinPhrase: ''}]},
        relationships: [
          {
            target: {
              name: 'Ol’ Dirty Bastard',
              gid: 'd50548a0-3cfd-4d7a-964b-0aef6545d819',
              entityType: 'artist',
            },
            backward: true,
            linkTypeID: 156,
          },
        ],
      },
      output: {
        name: 'Fix (Main Mix)',
        artistCredit: {
          names: [
            {name: 'Blackstreet', joinPhrase: ' feat. '},
            {artist: null, name: 'Slash', joinPhrase: ' & '},
            {
              artist: {
                name: 'Ol’ Dirty Bastard',
                gid: 'd50548a0-3cfd-4d7a-964b-0aef6545d819',
                entityType: 'artist',
              },
              name: 'Ol\' Dirty Bastard',
              joinPhrase: '',
            },
          ],
        },
      },
    },
  ];

  const trackTests = [
    {
      input: {
        entityType: 'track',
        name: 'мыльныйопус (feat.813)',
        artistCredit: {names: [{name: 'micromatics', joinPhrase: ''}]},
      },
      output: {
        name: 'мыльныйопус',
        artistCredit: {
          names: [
            {name: 'micromatics', joinPhrase: ' feat. '},
            {artist: null, name: '813', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'City Of Time (feat. 마리오(Feat.영지))',
        artistCredit: {names: [{name: '[unknown]', joinPhrase: ''}]},
      },
      output: {
        name: 'City Of Time',
        artistCredit: {
          names: [
            {name: '[unknown]', joinPhrase: ' feat. '},
            {artist: null, name: '마리오', joinPhrase: ' & '},
            {artist: null, name: '영지', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Feat Stouffi (feat. Christine & Stouffi)',
        artistCredit: {names: [{name: 'David TMX', joinPhrase: ''}]},
      },
      output: {
        name: 'Feat Stouffi',
        artistCredit: {
          names: [
            {name: 'David TMX', joinPhrase: ' feat. '},
            {artist: null, name: 'Christine', joinPhrase: ' & '},
            {artist: null, name: 'Stouffi', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Åndsvag ( Feat. Jooks)',
        artistCredit: {names: [{name: 'Suspekt', joinPhrase: ''}]},
      },
      output: {
        name: 'Åndsvag',
        artistCredit: {
          names: [
            {name: 'Suspekt', joinPhrase: ' feat. '},
            {artist: null, name: 'Jooks', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Ft. Smith Breakdown',
        artistCredit: {
          names: [
            {name: 'Luke Highnight & His Ozark Strutters', joinPhrase: ''},
          ],
        },
      },
      // no change
      output: {
        name: 'Ft. Smith Breakdown',
        artistCredit: {
          names: [
            {name: 'Luke Highnight & His Ozark Strutters', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Stormclouds [ft. Landforge]',
        artistCredit: {names: [{name: 'Red Horizons', joinPhrase: ''}]},
      },
      output: {
        name: 'Stormclouds',
        artistCredit: {
          names: [
            {name: 'Red Horizons', joinPhrase: ' ft. '},
            {artist: null, name: 'Landforge', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Montana Ft Juicy J',
        artistCredit: {names: [{name: 'Lil Bibby', joinPhrase: ''}]},
      },
      output: {
        name: 'Montana',
        artistCredit: {
          names: [
            {name: 'Lil Bibby', joinPhrase: ' ft '},
            {artist: null, name: 'Juicy J', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: '50,000 ft.',
        artistCredit: {names: [{name: 'The Hang Ups', joinPhrase: ''}]},
      },
      // no change
      output: {
        name: '50,000 ft.',
        artistCredit: {names: [{name: 'The Hang Ups', joinPhrase: ''}]},
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Classe x et freestyle (Feat. Hfi, Oxmo et Pit Baccardi)',
        artistCredit: {names: [{name: 'Ill', joinPhrase: ''}]},
      },
      output: {
        name: 'Classe x et freestyle',
        artistCredit: {
          names: [
            {name: 'Ill', joinPhrase: ' feat. '},
            {artist: null, name: 'Hfi', joinPhrase: ', '},
            {artist: null, name: 'Oxmo', joinPhrase: ' et '},
            {artist: null, name: 'Pit Baccardi', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'The Lion (Featuring Sphere720 And Tariq)',
        artistCredit: {names: [{name: 'Dragon Fli Empire', joinPhrase: ''}]},
      },
      output: {
        name: 'The Lion',
        artistCredit: {
          names: [
            {name: 'Dragon Fli Empire', joinPhrase: ' featuring '},
            {artist: null, name: 'Sphere720', joinPhrase: ' And '},
            {artist: null, name: 'Tariq', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'The Bell (Paranoia Network Remix), ' +
              'featuring Pete Seeger & DJ Spooky',
        artistCredit: {names: [{name: 'Stephan Smith', joinPhrase: ''}]},
      },
      output: {
        name: 'The Bell (Paranoia Network Remix)',
        artistCredit: {
          names: [
            {name: 'Stephan Smith', joinPhrase: ' featuring '},
            {artist: null, name: 'Pete Seeger', joinPhrase: ' & '},
            {artist: null, name: 'DJ Spooky', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Mothership Reconnection (Feat Parliament/Funkadelic) ' +
              '(Daft Punk Remix)',
        artistCredit: {names: [{name: 'Daft Punk', joinPhrase: ''}]},
      },
      output: {
        name: 'Mothership Reconnection (Daft Punk Remix)',
        artistCredit: {
          names: [
            {name: 'Daft Punk', joinPhrase: ' feat. '},
            {artist: null, name: 'Parliament', joinPhrase: '/'},
            {artist: null, name: 'Funkadelic', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Yes my lord (dub version - feat. Rubén Rada)',
        artistCredit: {names: [{name: 'Kameleba', joinPhrase: ''}]},
      },
      output: {
        name: 'Yes my lord (dub version)',
        artistCredit: {
          names: [
            {name: 'Kameleba', joinPhrase: ' feat. '},
            {artist: null, name: 'Rubén Rada', joinPhrase: ''},
          ],
        },
      },
    },
    /*
     * "Slash & Ol' Dirty Bastard" should be split even though it's above
     * the similarity threshold to "Ol' Dirty Bastard" alone.
     */
    {
      input: {
        entityType: 'track',
        name: 'Fix (Main Mix) (feat. Slash & Ol\' Dirty Bastard)',
        artistCredit: {names: [{name: 'Blackstreet', joinPhrase: ''}]},
        recording: {
          name: 'Fix (main mix) (feat. Slash & Ol\' Dirty Bastard)',
          gid: '8c6920a2-130c-4028-add9-684325a3fa8a',
          relationships: [
            {
              target: {
                name: 'Ol’ Dirty Bastard',
                gid: 'd50548a0-3cfd-4d7a-964b-0aef6545d819',
                entityType: 'artist',
              },
              backward: true,
              linkTypeID: 156,
            },
          ],
        },
      },
      output: {
        name: 'Fix (Main Mix)',
        artistCredit: {
          names: [
            {name: 'Blackstreet', joinPhrase: ' feat. '},
            {artist: null, name: 'Slash', joinPhrase: ' & '},
            {
              artist: {
                name: 'Ol’ Dirty Bastard',
                gid: 'd50548a0-3cfd-4d7a-964b-0aef6545d819',
                entityType: 'artist',
              },
              name: 'Ol\' Dirty Bastard',
              joinPhrase: '',
            },
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'ｆｒｏｚｅｎ ｆｔ.grèg',
        artistCredit: {names: [{name: 'cight', joinPhrase: ''}]},
      },
      output: {
        name: 'ｆｒｏｚｅｎ',
        artistCredit: {
          names: [
            {name: 'cight', joinPhrase: '　ｆｔ．　'},
            {artist: null, name: 'grèg', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'ｓｍｏｋｅ ｆｔ. ｅｐvｒ',
        artistCredit: {names: [{name: 'cight', joinPhrase: ''}]},
      },
      output: {
        name: 'ｓｍｏｋｅ',
        artistCredit: {
          names: [
            {name: 'cight', joinPhrase: '　ｆｔ．　'},
            {artist: null, name: 'ｅｐvｒ', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'lulu（feat. Predawn）',
        artistCredit: {names: [{name: '菅野よう子', joinPhrase: ''}]},
      },
      output: {
        name: 'lulu',
        artistCredit: {
          names: [
            {name: '菅野よう子', joinPhrase: ' feat. '},
            {artist: null, name: 'Predawn', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: '本能の呼吸（カラオケ） feat．戦場ヶ原ひたぎ ＆ 貝木泥舟',
        artistCredit: {names: [{name: '凪宗一郎', joinPhrase: ''}]},
      },
      output: {
        name: '本能の呼吸（カラオケ）',
        artistCredit: {
          names: [
            {name: '凪宗一郎', joinPhrase: '　ｆｅａｔ．　'},
            {artist: null, name: '戦場ヶ原ひたぎ', joinPhrase: '　＆　'},
            {artist: null, name: '貝木泥舟', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'track',
        name: 'Coast To Coast feat. 漢、般若',
        artistCredit: {names: [{name: 'DJ Baku', joinPhrase: ''}]},
      },
      output: {
        name: 'Coast To Coast',
        artistCredit: {
          names: [
            {name: 'DJ Baku', joinPhrase: ' feat. '},
            {artist: null, name: '漢', joinPhrase: '、'},
            {artist: null, name: '般若', joinPhrase: ''},
          ],
        },
      },
    },
  ];

  const releaseTests = [
    {
      input: {
        entityType: 'release',
        name: 'Coast To Coast feat. 漢、般若',
        artistCredit: {names: [{name: 'DJ Baku', joinPhrase: ''}]},
      },
      output: {
        name: 'Coast To Coast',
        artistCredit: {
          names: [
            {name: 'DJ Baku', joinPhrase: ' feat. '},
            {artist: null, name: '漢', joinPhrase: '、'},
            {artist: null, name: '般若', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'release',
        name: 'Stuffy Stuff【Feat. Artist】',
        artistCredit: {names: [{name: 'Someone', joinPhrase: ''}]},
      },
      output: {
        name: 'Stuffy Stuff',
        artistCredit: {
          names: [
            {name: 'Someone', joinPhrase: ' feat. '},
            {artist: null, name: 'Artist', joinPhrase: ''},
          ],
        },
      },
    },
    {
      input: {
        entityType: 'release',
        name: 'Montana Ft Juicy J',
        relationships: [
          {
            target: {
              gid: 'c45d161f-83ce-4464-ba41-44202e6916d9',
              name: 'Juicy J',
              entityType: 'artist',
            },
            backward: true,
            linkTypeID: 44,
          },
        ],
        artistCredit: {names: [{name: 'Lil Bibby', joinPhrase: ''}]},
      },
      output: {
        name: 'Montana',
        artistCredit: {
          names: [
            {name: 'Lil Bibby', joinPhrase: ' ft '},
            {
              artist: {
                name: 'Juicy J',
                gid: 'c45d161f-83ce-4464-ba41-44202e6916d9',
                entityType: 'artist',
              },
              name: 'Juicy J',
              joinPhrase: '',
            },
          ],
        },
      },
    },
  ];

  const releaseGroupTests = [
    {
      input: {
        entityType: 'release_group',
        name: 'Coast To Coast feat. 漢、般若',
        artistCredit: {names: [{name: 'DJ Baku', joinPhrase: ''}]},
      },
      output: {
        name: 'Coast To Coast',
        artistCredit: {
          names: [
            {name: 'DJ Baku', joinPhrase: ' feat. '},
            {artist: null, name: '漢', joinPhrase: '、'},
            {artist: null, name: '般若', joinPhrase: ''},
          ],
        },
      },
    },
  ];

  function toJS(entity) {
    return {
      name: entity.name(),
      artistCredit: {
        names: entity.artistCredit().names.map((name) => {
          const copy = {...name};
          delete copy.automaticJoinPhrase;
          return copy;
        }),
      },
    };
  }

  function runTest(x) {
    const output = guessFeat(x.input);
    if (output === null) {
      delete x.input.entityType;
      t.deepEqual(x.input, x.output, 'Expected no changes and saw none');
    } else {
      t.deepEqual(
        output.name, x.output.name, x.input.name + ' -> ' + x.output.name,
      );
      t.deepEqual(
        output.artistCreditNames, x.output.artistCredit.names, x.input.name + ' -> ' + x.output.name,
      );
    }
  }

  function runTestOld(x, entity) {
    guessFeatKo(entity);
    t.deepEqual(
      toJS(entity), x.output, x.input.name + ' -> ' + x.output.name,
    );
  }

  function runReleaseGroupTest(x, entity) {
    /*
     * This is a hack because RG is in itself hackily implemented
     * and can be hopefully dropped once all of this uses React
     */
    entity.name = ko.observable(entity.name);
    entity.artistCredit = ko.observable(entity.artistCredit);

    guessFeatKo(entity);
    t.deepEqual(
      toJS(entity), x.output, x.input.name + ' -> ' + x.output.name,
    );
  }

  for (const test of trackTests) {
    const release = new fields.Release({
      artistCredit: {names: []},
      mediums: [{tracks: [test.input]}],
    });

    runTestOld(test, release.mediums()[0].tracks()[0]);
    runTest(test);
  }

  for (const test of recordingTests) {
    runTest(test);
  }

  for (const test of releaseTests) {
    runTestOld(test, new fields.Release(test.input));
    runTest(test);
  }

  for (const test of releaseGroupTests) {
    runReleaseGroupTest(test, new fields.ReleaseGroup(test.input));
    runTest(test);
  }
});
