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
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'release', 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/Discography/Superunknown/',
                    MB.constants.LINK_TYPES.otherdatabases.release
                ],
                [
                    'artist', 'http://www.rockinchina.com/w/Beyond_Cure_(TW)',
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'artist', 'http://www.dhhu.dk/w/%C3%98stkyst_Hustlers',
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'release',
                    'http://www.dhhu.dk/w/Jonny_Hefty_%26_Gratismixtape.dk_pr%C3%A6senterer_Actionspeax_-_Louder_Than_Words_Mixtape,_MP3/',
                    MB.constants.LINK_TYPES.otherdatabases.release
                ],
                // The Session
                [
                    'release_group', 'http://thesession.org/recordings/1488',
                    MB.constants.LINK_TYPES.otherdatabases.release_group
                ],
                [
                    'work', 'http://thesession.org/tunes/2305',
                    MB.constants.LINK_TYPES.otherdatabases.work
                ],
                // IMDb
                [
                    'artist', 'http://www.imdb.com/name/nm1539156/',
                    MB.constants.LINK_TYPES.imdb.artist
                ],
                [
                    'release_group', 'http://www.imdb.com/title/tt0421082/',
                    MB.constants.LINK_TYPES.imdb.release_group
                ],
                [
                    'label', 'http://www.imdb.com/company/co0109498/',
                    MB.constants.LINK_TYPES.imdb.label
                ],
                // MySpace
                [
                    'artist', 'https://myspace.com/instramentaluk',
                    MB.constants.LINK_TYPES.myspace.artist
                ],
                [
                    'label', 'https://myspace.com/hospitalrecords',
                    MB.constants.LINK_TYPES.myspace.label
                ],
                // Soundcloud
                [
                    'artist', 'https://soundcloud.com/metro-luminal',
                    MB.constants.LINK_TYPES.soundcloud.artist
                ],
                [
                    'label', 'https://soundcloud.com/dimmakrecords',
                    MB.constants.LINK_TYPES.soundcloud.label
                ],
                // Purevolume
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
                    'recording', 'http://www.jamendo.com/en/track/725574/giraffe',
                    MB.constants.LINK_TYPES.downloadfree.recording
                ],
                [
                    'release', 'http://nla.gov.au/anbd.bib-an11701020',
                    MB.constants.LINK_TYPES.otherdatabases.release
                ],
                [
                    'release', 'http://www.jamendo.com/en/list/a84763/crossing-state-lines',
                    MB.constants.LINK_TYPES.downloadfree.release
                ],
                [
                    'release', 'http://www.jamendo.com/album/16090',
                    MB.constants.LINK_TYPES.downloadfree.release
                ],
                [
                    'release', 'http://www.mange-disque.tv/fs/md_429.jpg',
                    MB.constants.LINK_TYPES.coverart.release
                ],
                // Japanese blogs
                [
                    'artist', 'http://ameblo.jp/murataayumi/',
                    MB.constants.LINK_TYPES.blog.artist
                ],
                [
                    'label', 'http://ameblo.jp/murataayumi/',
                    MB.constants.LINK_TYPES.blog.label
                ],
                [
                    'artist', 'http://blog.livedoor.jp/mintmania/',
                    MB.constants.LINK_TYPES.blog.artist
                ],
                [
                    'label', 'http://blog.livedoor.jp/mintmania/',
                    MB.constants.LINK_TYPES.blog.label
                ],
                [
                    'artist', 'http://milk-pu-rin.jugem.jp/',
                    MB.constants.LINK_TYPES.blog.artist
                ],
                [
                    'label', 'http://milk-pu-rin.jugem.jp/',
                    MB.constants.LINK_TYPES.blog.label
                ],
                [
                    'artist', 'http://psgarden.exblog.jp/',
                    MB.constants.LINK_TYPES.blog.artist
                ],
                [
                    'label', 'http://psgarden.exblog.jp/',
                    MB.constants.LINK_TYPES.blog.label
                ],
                [
                    'release', 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
                    MB.constants.LINK_TYPES.lyrics.release
                ],
                [
                    'recording', 'https://embed.spotify.com/?uri=spotify:track:7gwRSZ0EmGWa697ZrE58GA',
                    MB.constants.LINK_TYPES.streamingmusic.recording
                ],
                // Lyrics
                [
                    'release', 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
                    MB.constants.LINK_TYPES.lyrics.release
                ],
                [
                    'work', 'http://www.recmusic.org/lieder/get_text.html?TextId=6448',
                    MB.constants.LINK_TYPES.lyrics.work
                ],
                [
                    'work', 'http://www.utamap.com/showkasi.php?surl=34985',
                    MB.constants.LINK_TYPES.lyrics.work
                ],
                [
                    'work', 'http://decoda.com/robi-on-ne-meurt-plus-damour-lyrics',
                    MB.constants.LINK_TYPES.lyrics.work
                ],
                // Vimeo
                [
                    'recording', 'http://vimeo.com/1109226',
                    MB.constants.LINK_TYPES.streamingmusic.recording
                ],
                // YouTube
                [
                    'recording', 'http://www.youtube.com/watch?v=UmHdefsaL6I',
                    MB.constants.LINK_TYPES.streamingmusic.recording
                ],
                [
                    'artist', 'http://youtube.com/user/officialpsy/videos',
                    MB.constants.LINK_TYPES.youtube.artist
                ],
                [
                    'label', 'http://youtube.com/user/officialpsy/videos',
                    MB.constants.LINK_TYPES.youtube.label
                ],
                // iTunes
                [
                    'artist', 'http://itunes.apple.com/artist/hangry-angry-f/id444923726',
                    MB.constants.LINK_TYPES.downloadpurchase.artist
                ],
                [
                    'release', 'http://itunes.apple.com/gb/album/now-thats-what-i-call-music!-82/id543575947?v0=WWW-EUUK-STAPG-MUSIC-PROMO',
                    MB.constants.LINK_TYPES.downloadpurchase.release
                ],
                [
                    'release', 'http://itunes.apple.com/au/preorder/the-last-of-the-tourists/id499465357',
                    MB.constants.LINK_TYPES.downloadpurchase.release
                ],
                [
                    'recording', 'http://itunes.apple.com/music-video/gangnam-style/id564322420?v0=WWW-NAUS-ITSTOP100-MUSICVIDEOS&ign-mpt=uo%3D2',
                    MB.constants.LINK_TYPES.downloadpurchase.recording
                ],
                // Other download stores
                [
                    'release', 'http://www.beatport.com/release/summertime-sadness-cedric-gervais-remix/1029002',
                    MB.constants.LINK_TYPES.downloadpurchase.release
                ],
                [
                    'release', 'http://www.junodownload.com/products/caspa-subscape-geordie-racer-notixx-remix/2141988-02/',
                    MB.constants.LINK_TYPES.downloadpurchase.release
                ],
                [
                    'release', 'http://www.audiojelly.com/releases/turn-up-the-sound/242895',
                    MB.constants.LINK_TYPES.downloadpurchase.release
                ],
                // Allmusic
                [
                    'artist', 'http://www.allmusic.com/artist/the-beatles-mn0000754032/credits',
                    MB.constants.LINK_TYPES.allmusic.artist
                ],
                [
                    'release_group', 'http://www.allmusic.com/album/here-comes-the-sun-mw0002303439/releases',
                    MB.constants.LINK_TYPES.allmusic.release_group
                ],
                [
                    'work', 'http://www.allmusic.com/song/help!-mt0043064796',
                    MB.constants.LINK_TYPES.allmusic.work
                ],
                [
                    'work', 'http://www.allmusic.com/composition/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mc0002367338',
                    MB.constants.LINK_TYPES.allmusic.work
                ],
                [
                    'recording', 'http://www.allmusic.com/performance/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mq0000061129/credits',
                    MB.constants.LINK_TYPES.allmusic.recording
                ],
                // Open Library
                [
                    'artist', 'http://openlibrary.org/authors/OL23919A/',
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'release', 'http://openlibrary.org/books/OL8993487M/',
                    MB.constants.LINK_TYPES.otherdatabases.release
                ],
                [
                    'work', 'http://openlibrary.org/works/OL82592W/',
                    MB.constants.LINK_TYPES.otherdatabases.work
                ],
                // SoundtrackCollector
                [
                    'artist', 'http://soundtrackcollector.com/composer/9/John+Williams',
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'release_group', 'http://soundtrackcollector.com/title/5751/Jurassic+Park',
                    MB.constants.LINK_TYPES.otherdatabases.release_group
                ],
                // Second Hand Songs
                [
                    'artist', 'http://www.secondhandsongs.com/artist/103',
                    MB.constants.LINK_TYPES.secondhandsongs.artist
                ],
                [
                    'release', 'http://www.secondhandsongs.com/release/888',
                    MB.constants.LINK_TYPES.secondhandsongs.release
                ],
                [
                    'work', 'http://www.secondhandsongs.com/work/1409',
                    MB.constants.LINK_TYPES.secondhandsongs.work
                ],
                // VIAF
                [
                    'artist', 'http://viaf.org/viaf/109231256',
                    MB.constants.LINK_TYPES.viaf.artist
                ],
                [
                    'label', 'http://viaf.org/viaf/152662182',
                    MB.constants.LINK_TYPES.viaf.label
                ],
                [
                    'work', 'http://viaf.org/viaf/185694157',
                    MB.constants.LINK_TYPES.viaf.work
                ],
                // Lyricsnmusic
                [
                    'work', 'http://www.lyricsnmusic.com/david-hasselhoff/white-christmas-lyrics/27952232',
                    MB.constants.LINK_TYPES.lyrics.work
                ],
                // BBC Music
                [
                    'artist', 'http://www.bbc.co.uk/music/artists/b52dd210-909c-461a-a75d-19e85a522042',
                    MB.constants.LINK_TYPES.bbcmusic.artist
                ],
                // Anime News Network
                [
                    'artist', 'http://www.animenewsnetwork.com/encyclopedia/people.php?id=59062',
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'label', 'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510',
                    MB.constants.LINK_TYPES.otherdatabases.label
                ],
                // Generasia
                [
                    'artist', 'http://www.generasia.com/wiki/Wink',
                    MB.constants.LINK_TYPES.otherdatabases.artist
                ],
                [
                    'release_group', 'http://www.generasia.com/wiki/Ai_ga_Tomaranai_~Turn_It_into_Love~',
                    MB.constants.LINK_TYPES.otherdatabases.release_group
                ],
                [
                    'work', 'http://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
                    MB.constants.LINK_TYPES.otherdatabases.work
                ],
                // Japanese discography pages
                [
                    'release', 'http://www.universal-music.co.jp/sweety/products/umca-59007/',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                [
                    'release', 'http://www.lantis.jp/release-item2.php?id=326c88aa1cd230f96ef350e380a23078',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                [
                    'release', 'http://www.jvcmusic.co.jp/-/Discography/A015120/VICC-60560.html',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                [
                    'release', 'http://wmg.jp/artist/ayaka/WPCL000010415.html',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                [
                    'release', 'http://avexnet.jp/id/supeg/discography/product/CTCR-11051.html',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                [
                    'release', 'http://www.kingrecords.co.jp/cs/g/gKICM-1091/',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                // Classical discography pages
                [
                    'release', 'http://www.naxos.com/catalogue/item.asp?item_code=8.553162',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                [
                    'release', 'http://bis.se/index.php?op=album&aID=BIS-1961',
                    MB.constants.LINK_TYPES.discographyentry.release
                ],
                // Wikidata
                [
                    'artist', 'http://www.wikidata.org/wiki/Q42',
                    MB.constants.LINK_TYPES.wikidata.artist
                ],
                [
                    'label', 'http://www.wikidata.org/wiki/Q42',
                    MB.constants.LINK_TYPES.wikidata.label
                ],
                [
                    'release_group', 'http://www.wikidata.org/wiki/Q42',
                    MB.constants.LINK_TYPES.wikidata.release_group
                ],
                [
                    'work', 'http://www.wikidata.org/wiki/Q42',
                    MB.constants.LINK_TYPES.wikidata.work
                ]

            ];

        $.each(tests, function(i, test) {
            QUnit.equal(control.guessType(test[0], test[1]), test[2], test[1]);
        });
    });

    QUnit.test('Cleanup', function() {
        var control = MB.Control.URLCleanup(),
            tests = [
                [
                    'http://www.amazon.co.uk/Out-Patients-Vol-3-Various-Artists/dp/B00009W0XE/ref=pd_sim_m_h__1',
                    'http://www.amazon.co.uk/gp/product/B00009W0XE',
                    'release'
                ],
                [
                    'http://www.amazon.co.jp/dp/tracks/B000Y3JG8U#disc_1',
                    'http://www.amazon.co.jp/gp/product/B000Y3JG8U',
                    'release'
                ],
                [
                    'https://www.amazon.co.uk/Nigel-Kennedy-Polish-Emil-Mynarski/dp/B000VLR0II',
                    'http://www.amazon.co.uk/gp/product/B000VLR0II',
                    'release'
                ],
                [
                    'http://www.amazon.com/Shine-We-Are-BoA/dp/B00015007W%3FSubscriptionId%3D14P3HXS0ZAYFZPH45TR2%26tag%3Dws%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3DB00015007W',
                    'http://www.amazon.com/gp/product/B00015007W',
                    'release'
                ],
                [
                    'http://www.amazon.co.uk/IMPOSSIBLE/dp/B00008CQP2/ref=sr_1_1?ie=UTF8&qid=1344584322&sr=8-1',
                    'http://www.amazon.co.uk/gp/product/B00008CQP2',
                    'release'
                ],
                [
                    'http://amzn.com/B000005SU4',
                    'http://www.amazon.com/gp/product/B000005SU4',
                    'release'
                ],
                [
                    'http://www.amazon.co.uk/Kosheen/e/B000APRTKE',
                    'http://www.amazon.co.uk/-/e/B000APRTKE'
                ],
                [
                    'http://www.amazon.com/gp/redirect.html/ref=amb_link_7764682_1?location=http://www.amazon.com/Carrie-Underwood/e/B0017PAU8Y/%20&token=3A0F170E7CEFE27BDC730D3D7344512BC1296B83&pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-4&pf_rd_r=0WX9S8HSE9M2WG1YZJE4&pf_rd_t=101&pf_rd_p=80631142&pf_rd_i=721517011',
                    'http://www.amazon.com/-/e/B0017PAU8Y'
                ],
                // Myspace
                [
                    'http://fr.myspace.com/jujusasadada',
                    'https://myspace.com/jujusasadada',
                    'artist'
                ],
                [
                    'http://myspace.de/diekisten',
                    'https://myspace.com/diekisten',
                    'artist'
                ],
                [
                    'http://www.myspace.com/whoevenusesthisanymore',
                    'https://myspace.com/whoevenusesthisanymore',
                    'label'
                ],
                // SoundCloud
                [
                    'http://soundcloud.com/alec_empire',
                    'https://soundcloud.com/alec_empire',
                    'artist'
                ],
                // Discogs
                [
                    'http://www.discogs.com/Various-Out-Patients-2/release/5578',
                    'http://www.discogs.com/release/5578',
                    'release'
                ],
                [
                    // FIXME Need a "bad" archive.org link
                    'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
                    'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
                    'release'
                ],
                [
                    'http://www.jamendo.com/en/list/a84763/crossing-state-lines',
                    'http://www.jamendo.com/list/a84763',
                    'release'
                ],
                [
                    'http://www.jamendo.com/en/track/725574/giraffe',
                    'http://www.jamendo.com/track/725574',
                    'recording'
                ],
                [
                    'http://www.jamendo.com/en/album/56372',
                    'http://www.jamendo.com/album/56372',
                    'release'
                ],
                [
                    'http://wiki.rockinchina.com/w/Beyond_Cure_(TW)',
                    'http://www.rockinchina.com/w/Beyond_Cure_(TW)',
                    'artist'
                ],
                [
                    'http://dhhu.dk/w/Sort_Stue',
                    'http://www.dhhu.dk/w/Sort_Stue',
                    'artist'
                ],
                // The Session
                [
                    'http://www.thesession.org/tunes/display/2305',
                    'http://thesession.org/tunes/2305',
                    'work'
                ],
                [
                    'https://www.thesession.org/recordings/display/1488',
                    'http://thesession.org/recordings/1488',
                    'release_group'
                ],
                [
                    'thesession.org/recordings/1488#comment283364',
                    'http://thesession.org/recordings/1488',
                    'release_group'
                ],
                // ameblo.jp
                [
                    'http://ameblo.jp/murataayumi',
                    'http://ameblo.jp/murataayumi/',
                    'artist'
                ],
                // Creative Commons
                [
                    'http://creativecommons.org/publicdomain/zero/1.0/legalcode',
                    'http://creativecommons.org/publicdomain/zero/1.0/',
                    'release'
                ],
                [
                    'http://creativecommons.org/licenses/by-nc-nd/2.5/es/deed.es',
                    'http://creativecommons.org/licenses/by-nc-nd/2.5/es/',
                    'release'
                ],
                    // Facebook
                [
                    'http://www.facebook.com/sininemusic',
                    'https://www.facebook.com/sininemusic',
                    'artist'
                ],
                [
                    'https://www.facebook.com/RomanzMusic?fref=ts',
                    'https://www.facebook.com/RomanzMusic',
                    'artist'
                ],
                    // Google+
                [
                    'http://plus.google.com/u/0/101821796946045393834/about',
                    'https://plus.google.com/101821796946045393834',
                    'artist'
                ],
                [
                    // FIXME Need a bad link
                    'http://www.mange-disque.tv/fs/md_1643.jpg',
                    'http://www.mange-disque.tv/fs/md_1643.jpg',
                    'release'
                ],
                [
                    'https://embed.spotify.com/?uri=spotify:track:7gwRSZ0EmGWa697ZrE58GA',
                    'http://open.spotify.com/track/7gwRSZ0EmGWa697ZrE58GA',
                    'streamingmusic'
                ],
                [
                    'http://www.vimeo.com/1109226?pg=embed&sec=1109226',
                    'http://vimeo.com/1109226',
                    'streamingmusic'
                ],
                [
                    'http://youtu.be/UmHdefsaL6I',
                    'http://www.youtube.com/watch?v=UmHdefsaL6I',
                    'streamingmusic'
                ],
                [
                    'http://www.youtube.com/embed/UmHdefsaL6I',
                    'http://www.youtube.com/watch?v=UmHdefsaL6I',
                    'streamingmusic'
                ],
                [
                    'http://youtube.com/user/officialpsy/videos',
                    'http://www.youtube.com/user/officialpsy',
                    'artist'
                ],
                [
                    'http://www.jamendo.com/en/list/a81403/the-cabinet-ep',
                    'http://www.jamendo.com/list/a81403',
                    'release'
                ],
                // Allmusic
                [
                    'http://www.allmusic.com/artist/the-beatles-mn0000754032/credits',
                    'http://www.allmusic.com/artist/mn0000754032',
                    'artist'
                ],
                [
                    'http://www.allmusic.com/album/here-comes-the-sun-mw0002303439/releases',
                    'http://www.allmusic.com/album/mw0002303439',
                    'release_group'
                ],
                [
                    'http://www.allmusic.com/song/help!-mt0043064796',
                    'http://www.allmusic.com/song/mt0043064796',
                    'work'
                ],
                [
                    'http://www.allmusic.com/composition/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mc0002367338',
                    'http://www.allmusic.com/composition/mc0002367338',
                    'work'
                ],
                [
                    'http://www.allmusic.com/performance/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mq0000061129/credits',
                    'http://www.allmusic.com/performance/mq0000061129',
                    'recording'
                ],
                // iTunes
                [
                    'http://itunes.apple.com/artist/hangry-angry-f/id444923726',
                    'https://itunes.apple.com/artist/id444923726',
                    'artist'
                ],
                [
                    'http://itunes.apple.com/gb/album/now-thats-what-i-call-music!-82/id543575947?v0=WWW-EUUK-STAPG-MUSIC-PROMO',
                    'https://itunes.apple.com/gb/album/id543575947',
                    'release'
                ],
                [
                    'http://itunes.apple.com/au/preorder/the-last-of-the-tourists/id499465357',
                    'https://itunes.apple.com/au/preorder/id499465357',
                    'release'
                ],
                [
                    'http://itunes.apple.com/music-video/gangnam-style/id564322420?v0=WWW-NAUS-ITSTOP100-MUSICVIDEOS&ign-mpt=uo%3D2',
                    'https://itunes.apple.com/music-video/id564322420',
                    'recording'
                ],
                [
                    'https://itunes.apple.com/us/album/skyfall-single/id566322358',
                    'https://itunes.apple.com/us/album/id566322358',
                    'release'
                ],
                [
                    'https://pt.wikisource.org/wiki/A_Portuguesa',
                    'http://pt.wikisource.org/wiki/A_Portuguesa',
                    'work'
                ],

                // MBS-4810: exactly one terminating slash at the end
                [
                    'http://creativecommons.org/licenses/by-nc-sa/2.0/de//',
                    'http://creativecommons.org/licenses/by-nc-sa/2.0/de/',
                    'release'
                ],
                [
                    'http://creativecommons.org/licenses/by/2.0/scotland',
                    'http://creativecommons.org/licenses/by/2.0/scotland/',
                    'release'
                ],
                [
                    'http://creativecommons.org/licenses/publicdomain//',
                    'http://creativecommons.org/licenses/publicdomain/',
                    'release'
                ],
                [
                    'http://creativecommons.org/licenses/publicdomain',
                    'http://creativecommons.org/licenses/publicdomain/',
                    'release'
                ],
                [
                    'http://creativecommons.org/publicdomain/zero/1.0//',
                    'http://creativecommons.org/publicdomain/zero/1.0/',
                    'release'
                ],
                [
                    'http://creativecommons.org/publicdomain/zero/1.0',
                    'http://creativecommons.org/publicdomain/zero/1.0/',
                    'release'
                ],

                // MBS-4044: Cleanup Discogs URLs
                [
                    'http://www.discogs.com/artist/Teresa+Teng?anv=%E9%84%A7%E9%BA%97%E5%90%9B',
                    'http://www.discogs.com/artist/Teresa+Teng',
                    'artist'
                ],
                [
                    'http://www.discogs.com/artist/Guy+Balbaert#t=Credits_Writing-Arrangement&q=&p=1',
                    'http://www.discogs.com/artist/Guy+Balbaert',
                    'artist'
                ],

                // MBS-4284: Normalize URL encoding for specific sites
                [
                    'http://www.discogs.com/label/$&+,/:;=@[]%20%23%24%25%2B%2C%2F%3A%3B%3F%40',
                    'http://www.discogs.com/label/%24%26+%2C%2F%3A%3B%3D%40%5B%5D+%23%24%25%2B%2C%2F%3A%3B%3F%40',
                    'label'
                ],
                [
                    'http://en.wikipedia.org/wiki/$&+,/:;=@[]%20%23%24%25%2B%2C%2F%3A%3B%3F%40',
                    'http://en.wikipedia.org/wiki/$%26%2B,/:;%3D@%5B%5D_%23$%25%2B,/:;%3F@',
                    'label'
                ],
                [
                    'http://userserve-ak.last.fm/serve/_/13629495/Lab+Beat+Lab_Beat_Logo_500.gif',
                    'http://userserve-ak.last.fm/serve/_/13629495/Lab+Beat+Lab_Beat_Logo_500.gif'
                ],
                [
                    'http://sv.m.wikipedia.org/wiki/Bullet',
                    'http://sv.wikipedia.org/wiki/Bullet',
                ],
                // Open Library
                [
                    'http://openlibrary.org/books/OL8993487M/Harry_Potter_and_the_Philosopher\'s_Stone',
                    'http://openlibrary.org/books/OL8993487M/',
                ],
                // VIAF
                [
                    'http://viaf.org/viaf/16766997',
                    'http://viaf.org/viaf/16766997',
                ],
                [
                    'http://viaf.org/viaf/16766997/',
                    'http://viaf.org/viaf/16766997',
                ],
                [
                    'http://viaf.org/viaf/16766997/#Rovics,_David',
                    'http://viaf.org/viaf/16766997',
                ],
                [
                    'http://viaf.org/viaf/16766997/?test=true',
                    'http://viaf.org/viaf/16766997',
                ],
                [
                    'viaf.org/viaf/16766997/',
                    'http://viaf.org/viaf/16766997',
                ],
                [
                    'www.viaf.org/viaf/16766997/',
                    'http://viaf.org/viaf/16766997',
                ],
                [
                    'https://www.viaf.org/viaf/16766997?test=1#Rovics,_David',
                    'http://viaf.org/viaf/16766997',
                ],
                // Anime News Network
                [
                    'http://animenewsnetwork.com/encyclopedia/people.php?id=59062',
                    'http://www.animenewsnetwork.com/encyclopedia/people.php?id=59062',
                ],
                [
                    'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510#page_header',
                    'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510',
                ],
                // Generasia
                [
                    'http://generasia.com/wiki/Wink',
                    'http://www.generasia.com/wiki/Wink',
                ],
                [
                    'https://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
                    'http://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
                ],
                // Soundtrack Collector
                [
                    'http://soundtrackcollector.com/composer/94/Hans+Zimmer',
                    'http://soundtrackcollector.com/composer/94/',
                ]
            ];

        $.each(tests, function(i, test) {
            QUnit.equal(control.cleanUrl(test[2], test[0]), test[1], test[0]);
        });
    });
};

MB.tests.URLCleanup.Run = function() {
    MB.tests.URLCleanup.GuessType();
};
