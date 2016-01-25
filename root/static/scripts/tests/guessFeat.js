// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const test = require('tape');

const guessFeat = require('../edit/utility/guessFeat');

test('guessing feat. artists', function (t) {
    t.plan(17);

    var trackTests = [
        {
            input: {
                name: 'мыльныйопус (feat.813)',
                artistCredit: [{name: 'micromatics', joinPhrase: ''}]
            },
            output: {
                name: 'мыльныйопус',
                artistCredit: [
                    {name: 'micromatics', joinPhrase: ' feat. '},
                    {name: '813', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'City Of Time (feat. 마리오(Feat.영지))',
                artistCredit: [{name: '[unknown]', joinPhrase: ''}]
            },
            output: {
                name: 'City Of Time',
                artistCredit: [
                    {name: '[unknown]', joinPhrase: ' feat. '},
                    {name: '마리오', joinPhrase: ' & '},
                    {name: '영지', joinPhrase: ''},
                ]
            }
        },
        {
            input: {
                name: 'Feat Stouffi (feat. Christine & Stouffi)',
                artistCredit: [{name: 'David TMX', joinPhrase: ''}]
            },
            output: {
                name: 'Feat Stouffi',
                artistCredit: [
                    {name: 'David TMX', joinPhrase: ' feat. '},
                    {name: 'Christine', joinPhrase: ' & '},
                    {name: 'Stouffi', joinPhrase: ''},
                ]
            }
        },
        {
            input: {
                name: 'Åndsvag ( Feat. Jooks)',
                artistCredit: [{name: 'Suspekt', joinPhrase: ''}]
            },
            output: {
                name: 'Åndsvag',
                artistCredit: [
                    {name: 'Suspekt', joinPhrase: ' feat. '},
                    {name: 'Jooks', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'Ft. Smith Breakdown',
                artistCredit: [{name: 'Luke Highnight & His Ozark Strutters', joinPhrase: ''}]
            },
            // no change
            output: {
                name: 'Ft. Smith Breakdown',
                artistCredit: [{name: 'Luke Highnight & His Ozark Strutters', joinPhrase: ''}]
            }
        },
        {
            input: {
                name: 'Stormclouds [ft. Landforge]',
                artistCredit: [{name: 'Red Horizons', joinPhrase: ''}]
            },
            output: {
                name: 'Stormclouds',
                artistCredit: [
                    {name: 'Red Horizons', joinPhrase: ' feat. '},
                    {name: 'Landforge', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'Montana Ft Juicy J',
                artistCredit: [{name: 'Lil Bibby', joinPhrase: ''}]
            },
            output: {
                name: 'Montana',
                artistCredit: [
                    {name: 'Lil Bibby', joinPhrase: ' feat. '},
                    {name: 'Juicy J', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: '50,000 ft.',
                artistCredit: [{name: 'The Hang Ups', joinPhrase: ''}]
            },
            // no change
            output: {
                name: '50,000 ft.',
                artistCredit: [{name: 'The Hang Ups', joinPhrase: ''}]
            }
        },
        {
            input: {
                name: 'Classe x et freestyle (Feat. Hfi, Oxmo et Pit Baccardi)',
                artistCredit: [{name: 'Ill', joinPhrase: ''}]
            },
            output: {
                name: 'Classe x et freestyle',
                artistCredit: [
                    {name: 'Ill', joinPhrase: ' feat. '},
                    {name: 'Hfi', joinPhrase: ', '},
                    {name: 'Oxmo', joinPhrase: ' et '},
                    {name: 'Pit Baccardi', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'The Lion (Featuring Sphere720 And Tariq)',
                artistCredit: [{name: 'Dragon Fli Empire', joinPhrase: ''}]
            },
            output: {
                name: 'The Lion',
                artistCredit: [
                    {name: 'Dragon Fli Empire', joinPhrase: ' feat. '},
                    {name: 'Sphere720', joinPhrase: ' And '},
                    {name: 'Tariq', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'The Bell (Paranoia Network Remix), featuring Pete Seeger & DJ Spooky',
                artistCredit: [{name: 'Stephan Smith', joinPhrase: ''}]
            },
            output: {
                name: 'The Bell (Paranoia Network Remix)',
                artistCredit: [
                    {name: 'Stephan Smith', joinPhrase: ' feat. '},
                    {name: 'Pete Seeger', joinPhrase: ' & '},
                    {name: 'DJ Spooky', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'Mothership Reconnection (Feat Parliament/Funkadelic) (Daft Punk Remix)',
                artistCredit: [{name: 'Daft Punk', joinPhrase: ''}]
            },
            output: {
                name: 'Mothership Reconnection (Daft Punk Remix)',
                artistCredit: [
                    {name: 'Daft Punk', joinPhrase: ' feat. '},
                    {name: 'Parliament', joinPhrase: '/'},
                    {name: 'Funkadelic', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'Yes my lord (dub version - feat. Rubén Rada)',
                artistCredit: [{name: 'Kameleba', joinPhrase: ''}]
            },
            output: {
                name: 'Yes my lord (dub version)',
                artistCredit: [
                    {name: 'Kameleba', joinPhrase: ' feat. '},
                    {name: 'Rubén Rada', joinPhrase: ''}
                ]
            }
        },
        // "Slash & Ol' Dirty Bastard" should be split even though it's above
        // the similarity threshold to "Ol' Dirty Bastard" alone.
        {
            input: {
                name: 'Fix (Main Mix) (feat. Slash & Ol\' Dirty Bastard)',
                artistCredit: [{name: 'Blackstreet', joinPhrase: ''}],
                recording: {
                    name: 'Fix (main mix) (feat. Slash & Ol\' Dirty Bastard)',
                    gid: '8c6920a2-130c-4028-add9-684325a3fa8a',
                    relationships: [
                        {
                            target: {name: 'Ol’ Dirty Bastard', gid: 'd50548a0-3cfd-4d7a-964b-0aef6545d819', entityType: 'artist'},
                            direction: 'backward',
                            linkTypeID: 156
                        }
                    ]
                }
            },
            output: {
                name: 'Fix (Main Mix)',
                artistCredit: [
                    {name: 'Blackstreet', joinPhrase: ' feat. '},
                    {name: 'Slash', joinPhrase: ' & '},
                    {name: 'Ol\' Dirty Bastard', joinPhrase: ''},
                ]
            }
        }
    ];

    var releaseTests = [
        {
            input: {
                name: 'The Nutcracker: Suite, Op. 71 (London Symphony Orchestra feat. conductor: André Previn) (disc 2)',
                artistCredit: [{name: 'Пётр Ильич Чайковский', joinPhrase: ''}],
                relationships: [
                    {
                        target: {name: 'London Symphony Orchestra', entityType: 'artist'},
                        direction: 'backward',
                        linkTypeID: 45
                    }
                ]
            },
            output: {
                name: 'The Nutcracker: Suite, Op. 71 (disc 2)',
                artistCredit: [
                    {name: 'Пётр Ильич Чайковский', joinPhrase: '; '},
                    {name: 'London Symphony Orchestra', joinPhrase: ', '},
                    {name: 'André Previn', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'Intermezzi from Palandrana and Zambrano (feat. Fortuna Ensemble; conductor: Roberto Cascio; soprano: Barbara di Castri; tenor: Gastone Sarti)',
                artistCredit: [{name: 'Alessandro Scarlatti', joinPhrase: ''}],
                relationships: [
                    {
                        target: {name: 'Roberto Cascio', entityType: 'artist'},
                        direction: 'backward',
                        linkTypeID: 46
                    }
                ]
            },
            output: {
                name: 'Intermezzi from Palandrana and Zambrano',
                artistCredit: [
                    {name: 'Alessandro Scarlatti', joinPhrase: '; '},
                    {name: 'Fortuna Ensemble', joinPhrase: ', '},
                    {name: 'Roberto Cascio', joinPhrase: ', '},
                    {name: 'Barbara di Castri', joinPhrase: ', '},
                    {name: 'Gastone Sarti', joinPhrase: ''}
                ]
            }
        },
        {
            input: {
                name: 'Le nozze di Figaro - highlights (The Drottningholm Court Theatre Orchestra & Chorus, feat. conductor: Arnold Östman, singers: Salomaa, Bonney, Hagagård)',
                artistCredit: [{name: 'Mozart', joinPhrase: ''}],
                relationships: [
                    {
                        target: {name: 'The Drottningholm Court Theatre Orchestra & Chorus', entityType: 'artist'},
                        direction: 'backward',
                        linkTypeID: 45
                    }
                ]
            },
            output: {
                name: 'Le nozze di Figaro - highlights',
                artistCredit: [
                    {name: 'Mozart', joinPhrase: '; '},
                    {name: 'The Drottningholm Court Theatre Orchestra & Chorus', joinPhrase: ', '},
                    {name: 'Arnold Östman', joinPhrase: ', '},
                    {name: 'Salomaa', joinPhrase: ', '},
                    {name: 'Bonney', joinPhrase: ', '},
                    {name: 'Hagagård', joinPhrase: ''}
                ]
            }
        }
    ];

    function toJS(track) {
        return {
            name: track.name(),
            artistCredit: _.map(track.artistCredit.toJSON(), _.partialRight(_.omit, 'artist'))
        };
    }

    function runTest(x, entity) {
        guessFeat(entity);
        t.deepEqual(toJS(entity), x.output, x.input.name + ' -> ' + x.output.name);
    }

    _.each(trackTests, function (x) {
        var release = MB.releaseEditor.fields.Release({mediums: [{tracks: [x.input]}]});

        runTest(x, release.mediums()[0].tracks()[0]);
    });

    _.each(releaseTests, function (x) {
        runTest(x, MB.releaseEditor.fields.Release(x.input));
    });
});
