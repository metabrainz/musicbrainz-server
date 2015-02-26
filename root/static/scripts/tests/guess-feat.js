// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');
var _ = require('lodash');
var guessFeat = require('../edit/utility/guess-feat.js');

test('guessing feat. artists', function (t) {
    t.plan(13);

    var tests = [
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
        }
    ];

    _.each(tests, function (x) {
        var recording = {
            name: ko.observable(x.input.name),
            artistCredit: MB.Control.ArtistCredit({ initialData: x.input.artistCredit }),
            toJSON: function () {
                return {
                    name: this.name(),
                    artistCredit: _.map(this.artistCredit.toJSON(), _.partialRight(_.omit, 'artist'))
                };
            }
        };

        guessFeat(recording);

        t.deepEqual(recording.toJSON(), x.output, x.input.name + ' -> ' + x.output.name);
    });
});
