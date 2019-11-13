// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import _ from 'lodash';
import test from 'tape';

import guessFeat from '../edit/utility/guessFeat';
import fields from '../release-editor/fields';

test('guessing feat. artists', function (t) {
    t.plan(22);

    var trackTests = [
        {
            input: {
                name: 'мыльныйопус (feat.813)',
                artistCredit: {names: [{name: 'micromatics', joinPhrase: ''}]},
            },
            output: {
                name: 'мыльныйопус',
                artistCredit: {
                    names: [
                        {name: 'micromatics', joinPhrase: ' feat. '},
                        {name: '813', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'City Of Time (feat. 마리오(Feat.영지))',
                artistCredit: {names: [{name: '[unknown]', joinPhrase: ''}]},
            },
            output: {
                name: 'City Of Time',
                artistCredit: {
                    names: [
                        {name: '[unknown]', joinPhrase: ' feat. '},
                        {name: '마리오', joinPhrase: ' & '},
                        {name: '영지', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Feat Stouffi (feat. Christine & Stouffi)',
                artistCredit: {names: [{name: 'David TMX', joinPhrase: ''}]},
            },
            output: {
                name: 'Feat Stouffi',
                artistCredit: {
                    names: [
                        {name: 'David TMX', joinPhrase: ' feat. '},
                        {name: 'Christine', joinPhrase: ' & '},
                        {name: 'Stouffi', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Åndsvag ( Feat. Jooks)',
                artistCredit: {names: [{name: 'Suspekt', joinPhrase: ''}]},
            },
            output: {
                name: 'Åndsvag',
                artistCredit: {
                    names: [
                        {name: 'Suspekt', joinPhrase: ' feat. '},
                        {name: 'Jooks', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Ft. Smith Breakdown',
                artistCredit: {names: [{name: 'Luke Highnight & His Ozark Strutters', joinPhrase: ''}]},
            },
            // no change
            output: {
                name: 'Ft. Smith Breakdown',
                artistCredit: {names: [{name: 'Luke Highnight & His Ozark Strutters', joinPhrase: ''}]},
            },
        },
        {
            input: {
                name: 'Stormclouds [ft. Landforge]',
                artistCredit: {names: [{name: 'Red Horizons', joinPhrase: ''}]},
            },
            output: {
                name: 'Stormclouds',
                artistCredit: {
                    names: [
                        {name: 'Red Horizons', joinPhrase: ' ft. '},
                        {name: 'Landforge', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Montana Ft Juicy J',
                artistCredit: {names: [{name: 'Lil Bibby', joinPhrase: ''}]},
            },
            output: {
                name: 'Montana',
                artistCredit: {
                    names: [
                        {name: 'Lil Bibby', joinPhrase: ' ft '},
                        {name: 'Juicy J', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
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
                name: 'Classe x et freestyle (Feat. Hfi, Oxmo et Pit Baccardi)',
                artistCredit: {names: [{name: 'Ill', joinPhrase: ''}]},
            },
            output: {
                name: 'Classe x et freestyle',
                artistCredit: {
                    names: [
                        {name: 'Ill', joinPhrase: ' feat. '},
                        {name: 'Hfi', joinPhrase: ', '},
                        {name: 'Oxmo', joinPhrase: ' et '},
                        {name: 'Pit Baccardi', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'The Lion (Featuring Sphere720 And Tariq)',
                artistCredit: {names: [{name: 'Dragon Fli Empire', joinPhrase: ''}]},
            },
            output: {
                name: 'The Lion',
                artistCredit: {
                    names: [
                        {name: 'Dragon Fli Empire', joinPhrase: ' featuring '},
                        {name: 'Sphere720', joinPhrase: ' And '},
                        {name: 'Tariq', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'The Bell (Paranoia Network Remix), featuring Pete Seeger & DJ Spooky',
                artistCredit: {names: [{name: 'Stephan Smith', joinPhrase: ''}]},
            },
            output: {
                name: 'The Bell (Paranoia Network Remix)',
                artistCredit: {
                    names: [
                        {name: 'Stephan Smith', joinPhrase: ' featuring '},
                        {name: 'Pete Seeger', joinPhrase: ' & '},
                        {name: 'DJ Spooky', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Mothership Reconnection (Feat Parliament/Funkadelic) (Daft Punk Remix)',
                artistCredit: {names: [{name: 'Daft Punk', joinPhrase: ''}]},
            },
            output: {
                name: 'Mothership Reconnection (Daft Punk Remix)',
                artistCredit: {
                    names: [
                        {name: 'Daft Punk', joinPhrase: ' feat. '},
                        {name: 'Parliament', joinPhrase: '/'},
                        {name: 'Funkadelic', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Yes my lord (dub version - feat. Rubén Rada)',
                artistCredit: {names: [{name: 'Kameleba', joinPhrase: ''}]},
            },
            output: {
                name: 'Yes my lord (dub version)',
                artistCredit: {
                    names: [
                        {name: 'Kameleba', joinPhrase: ' feat. '},
                        {name: 'Rubén Rada', joinPhrase: ''},
                    ],
                },
            },
        },
        // "Slash & Ol' Dirty Bastard" should be split even though it's above
        // the similarity threshold to "Ol' Dirty Bastard" alone.
        {
            input: {
                name: 'Fix (Main Mix) (feat. Slash & Ol\' Dirty Bastard)',
                artistCredit: {names: [{name: 'Blackstreet', joinPhrase: ''}]},
                recording: {
                    name: 'Fix (main mix) (feat. Slash & Ol\' Dirty Bastard)',
                    gid: '8c6920a2-130c-4028-add9-684325a3fa8a',
                    relationships: [
                        {
                            target: {name: 'Ol’ Dirty Bastard', gid: 'd50548a0-3cfd-4d7a-964b-0aef6545d819', entityType: 'artist'},
                            direction: 'backward',
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
                        {name: 'Slash', joinPhrase: ' & '},
                        {name: 'Ol\' Dirty Bastard', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'ｆｒｏｚｅｎ ｆｔ.grèg',
                artistCredit: {names: [{name: 'cight', joinPhrase: ''}]},
            },
            output: {
                name: 'ｆｒｏｚｅｎ',
                artistCredit: {
                    names: [
                        {name: 'cight', joinPhrase: '　ｆｔ．　'},
                        {name: 'grèg', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'ｓｍｏｋｅ ｆｔ. ｅｐvｒ',
                artistCredit: {names: [{name: 'cight', joinPhrase: ''}]},
            },
            output: {
                name: 'ｓｍｏｋｅ',
                artistCredit: {
                    names: [
                        {name: 'cight', joinPhrase: '　ｆｔ．　'},
                        {name: 'ｅｐvｒ', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'lulu（feat. Predawn）',
                artistCredit: {names: [{name: '菅野よう子', joinPhrase: ''}]},
            },
            output: {
                name: 'lulu',
                artistCredit: {
                    names: [
                        {name: '菅野よう子', joinPhrase: ' feat. '},
                        {name: 'Predawn', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: '本能の呼吸（カラオケ） feat．戦場ヶ原ひたぎ ＆ 貝木泥舟',
                artistCredit: {names: [{name: '凪宗一郎', joinPhrase: ''}]},
            },
            output: {
                name: '本能の呼吸（カラオケ）',
                artistCredit: {
                    names: [
                        {name: '凪宗一郎', joinPhrase: '　ｆｅａｔ．　'},
                        {name: '戦場ヶ原ひたぎ', joinPhrase: '　＆　'},
                        {name: '貝木泥舟', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Coast To Coast feat. 漢、般若',
                artistCredit: {names: [{name: 'DJ Baku', joinPhrase: ''}]},
            },
            output: {
                name: 'Coast To Coast',
                artistCredit: {
                    names: [
                        {name: 'DJ Baku', joinPhrase: ' feat. '},
                        {name: '漢', joinPhrase: '、'},
                        {name: '般若', joinPhrase: ''},
                    ],
                },
            },
        },
    ];

    var releaseTests = [
        {
            input: {
                name: 'The Nutcracker: Suite, Op. 71 (London Symphony Orchestra feat. conductor: André Previn) (disc 2)',
                artistCredit: {names: [{name: 'Пётр Ильич Чайковский', joinPhrase: ''}]},
                relationships: [
                    {
                        target: {name: 'London Symphony Orchestra', entityType: 'artist'},
                        direction: 'backward',
                        linkTypeID: 45,
                    },
                ],
            },
            output: {
                name: 'The Nutcracker: Suite, Op. 71 (disc 2)',
                artistCredit: {
                    names: [
                        {name: 'Пётр Ильич Чайковский', joinPhrase: '; '},
                        {name: 'London Symphony Orchestra', joinPhrase: ', '},
                        {name: 'André Previn', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Intermezzi from Palandrana and Zambrano (feat. Fortuna Ensemble; conductor: Roberto Cascio; soprano: Barbara di Castri; tenor: Gastone Sarti)',
                artistCredit: {names: [{name: 'Alessandro Scarlatti', joinPhrase: ''}]},
                relationships: [
                    {
                        target: {name: 'Roberto Cascio', entityType: 'artist'},
                        direction: 'backward',
                        linkTypeID: 46,
                    },
                ],
            },
            output: {
                name: 'Intermezzi from Palandrana and Zambrano',
                artistCredit: {
                    names: [
                        {name: 'Alessandro Scarlatti', joinPhrase: '; '},
                        {name: 'Fortuna Ensemble', joinPhrase: ', '},
                        {name: 'Roberto Cascio', joinPhrase: ', '},
                        {name: 'Barbara di Castri', joinPhrase: ', '},
                        {name: 'Gastone Sarti', joinPhrase: ''},
                    ],
                },
            },
        },
        {
            input: {
                name: 'Le nozze di Figaro - highlights (The Drottningholm Court Theatre Orchestra & Chorus, feat. conductor: Arnold Östman, singers: Salomaa, Bonney, Hagagård)',
                artistCredit: {names: [{name: 'Mozart', joinPhrase: ''}]},
                relationships: [
                    {
                        target: {name: 'The Drottningholm Court Theatre Orchestra & Chorus', entityType: 'artist'},
                        direction: 'backward',
                        linkTypeID: 45,
                    },
                ],
            },
            output: {
                name: 'Le nozze di Figaro - highlights',
                artistCredit: {
                    names: [
                        {name: 'Mozart', joinPhrase: '; '},
                        {name: 'The Drottningholm Court Theatre Orchestra & Chorus', joinPhrase: ', '},
                        {name: 'Arnold Östman', joinPhrase: ', '},
                        {name: 'Salomaa', joinPhrase: ', '},
                        {name: 'Bonney', joinPhrase: ', '},
                        {name: 'Hagagård', joinPhrase: ''},
                    ],
                },
            },
        },
    ];

    function toJS(track) {
        return {
            name: track.name(),
            artistCredit: {
                names: _.map(
                    track.artistCredit().names,
                    _.partialRight(_.omit, ['artist', 'automaticJoinPhrase']),
                ),
            },
        };
    }

    function runTest(x, entity) {
        guessFeat(entity);
        t.deepEqual(toJS(entity), x.output, x.input.name + ' -> ' + x.output.name);
    }

    _.each(trackTests, function (x) {
        var release = new fields.Release({
            artistCredit: {names: []},
            mediums: [{tracks: [x.input]}],
        });

        runTest(x, release.mediums()[0].tracks()[0]);
    });

    _.each(releaseTests, function (x) {
        runTest(x, new fields.Release(x.input));
    });
});
