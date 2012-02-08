MB.tests.URLCleanup = (MB.tests.URLCleanup) ? MB.tests.URLCleanup : {};

MB.tests.URLCleanup.GuessType = function() {
    QUnit.module('URL Cleanup');
    QUnit.test('Guess type', function() {
        var control = MB.Control.URLCleanup();
        var tests = [
                [
                    'artist', 'http://en.wikipedia.org/wiki/Source_Direct_%28band%29',
                    MB.constants.LINK_TYPES.wikipedia.artist
                ],
                [
                    'release_group', 'http://en.wikipedia.org/wiki/Exorcise_the_Demons',
                    MB.constants.LINK_TYPES.wikipedia.release_group
                ],
                [
                    'label', 'http://en.wikipedia.org/wiki/Astralwerks',
                    MB.constants.LINK_TYPES.wikipedia.label
                ],

                [
                    'artist', 'http://www.discogs.com/artist/Source+Direct',
                    MB.constants.LINK_TYPES.discogs.artist
                ],
                [
                    'label', 'http://www.discogs.com/label/Demonic',
                    MB.constants.LINK_TYPES.discogs.label
                ],
                [
                    'release', 'http://www.discogs.com/release/12130',
                    MB.constants.LINK_TYPES.discogs.release
                ],
                [
                    'release_group', 'http://www.discogs.com/Source-Direct-Exorcise-The-Demons/master/126685',
                    MB.constants.LINK_TYPES.discogs.release_group
                ],

                [
                    'artist', 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/',
                    MB.constants.LINK_TYPES.musicmoz.artist
                ],
                [
                    'release', 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/Discography/Superunknown/',
                    MB.constants.LINK_TYPES.musicmoz.release
                ],

                [
                    'artist', 'http://www.imdb.com/name/nm1539156/',
                    MB.constants.LINK_TYPES.imdb.artist
                ],
                [
                    'release_group', 'http://www.imdb.com/title/tt0421082/',
                    MB.constants.LINK_TYPES.imdb.release_group
                ],

                [
                    'artist', 'http://www.myspace.com/instramentaluk',
                    MB.constants.LINK_TYPES.myspace.artist
                ],
                [
                    'label', 'http://www.myspace.com/hospitalrecords',
                    MB.constants.LINK_TYPES.myspace.label
                ],

                [
                    'artist', 'http://www.purevolume.com/withbloodcomescleansing',
                    MB.constants.LINK_TYPES.purevolume.artist
                ],

                [
                    'release', 'http://www.amazon.co.uk/gp/product/B00005JIWP',
                    MB.constants.LINK_TYPES.amazon.release
                ],

                [
                    'release', 'http://www.archive.org/download/JudasHalo/cover.jpg',
                    MB.constants.LINK_TYPES.coverart.release
                ],

                [
                    'release', 'http://www.jamendo.com/album/16090',
                    MB.constants.LINK_TYPES.downloadfree.release
                ],

                [
                    'release', 'http://www.encyclopedisque.fr/images/imgdb/main/16593.jpg',
                    MB.constants.LINK_TYPES.coverart.release
                ],

                [
                    'release', 'http://www.mange-disque.tv/fs/md_429.jpg',
                    MB.constants.LINK_TYPES.coverart.release
                ],

                [
                    'release', 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
                    MB.constants.LINK_TYPES.lyrics.release
                ]
            ];

        $.each(tests, function(i, test) {
            QUnit.equals(control.guessType(test[0], test[1]), test[2], test[1]);
        });
    });

    QUnit.test('Cleanup', function() {
        var control = MB.Control.URLCleanup(),
            tests = [
                [
                    'http://www.amazon.co.uk/Out-Patients-Vol-3-Various-Artists/dp/B00009W0XE/ref=pd_sim_m_h__1',
                    'http://www.amazon.co.uk/gp/product/B00009W0XE'
                ],
                [
                    'http://www.discogs.com/Various-Out-Patients-2/release/5578',
                    'http://www.discogs.com/release/5578'
                ],
                [
                    // FIXME Need a "bad" archive.org link
                    'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
                    'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg'
                ],
                [
                    'http://www.jamendo.com/en/album/56372',
                    'http://www.jamendo.com/album/56372'
                ],
                [
                    'http://www.encyclopedisque.fr/images/imgdb/thumb250/1435.jpg',
                    'http://www.encyclopedisque.fr/images/imgdb/main/1435.jpg'
                ],
                [
                    // FIXME Need a bad link
                    'http://www.mange-disque.tv/fs/md_1643.jpg',
                    'http://www.mange-disque.tv/fs/md_1643.jpg'
                ]
            ];

        $.each(tests, function(i, test) {
            QUnit.equals(control.cleanUrl(test[0]), test[1], test[0]);
        });
    });
};

MB.tests.URLCleanup.Run = function() {
    MB.tests.URLCleanup.GuessType();
};
