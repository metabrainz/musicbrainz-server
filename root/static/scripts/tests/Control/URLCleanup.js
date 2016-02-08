// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

const {LINK_TYPES, cleanURL, guessType} = require('../../edit/URLCleanup');

test('Guess type', function (t) {
    var tests = [
            // Amazon
            [
                'release', 'http://www.amazon.co.uk/gp/product/B00005JIWP',
                LINK_TYPES.amazon.release
            ],
            [
                'release', 'http://www.amazon.in/gp/product/B006H1JVW4',
                LINK_TYPES.amazon.release
            ],
            [
                'release', 'http://www.amazon.com.br/gp/product/B00T8E47G2',
                LINK_TYPES.amazon.release
            ],
            // Wikipedia
            [
                'artist', 'http://en.wikipedia.org/wiki/Source_Direct_%28band%29',
                LINK_TYPES.wikipedia.artist
            ],
            [
                'release_group', 'http://en.wikipedia.org/wiki/Exorcise_the_Demons',
                LINK_TYPES.wikipedia.release_group
            ],
            [
                'label', 'http://en.wikipedia.org/wiki/Astralwerks',
                LINK_TYPES.wikipedia.label
            ],
            // Discogs
            [
                'artist', 'http://www.discogs.com/artist/Source+Direct',
                LINK_TYPES.discogs.artist
            ],
            [
                'artist', 'http://www.discogs.com/artist/301-Source-Direct',
                LINK_TYPES.discogs.artist
            ],
            [
                'label', 'http://www.discogs.com/label/Demonic',
                LINK_TYPES.discogs.label
            ],
            [
                'label', 'http://www.discogs.com/label/2262-Demonic',
                LINK_TYPES.discogs.label
            ],
            [
                'release', 'http://www.discogs.com/release/12130',
                LINK_TYPES.discogs.release
            ],
            [
                'release_group', 'http://www.discogs.com/Source-Direct-Exorcise-The-Demons/master/126685',
                LINK_TYPES.discogs.release_group
            ],
            // Bandcamp
            [
                'artist', 'http://davidrovics.bandcamp.com/',
                LINK_TYPES.bandcamp.artist
            ],
            [
                'label', 'http://idiotsikker.bandcamp.com/',
                LINK_TYPES.bandcamp.label
            ],
            // Last.fm
            [
                'artist', 'http://www.last.fm/music/Bj%C3%B6rk',
                LINK_TYPES.lastfm.artist
            ],
            [
                'event', 'http://www.last.fm/event/3291943+Pori+jazz',
                LINK_TYPES.lastfm.event
            ],
            // LinkedIn
            [
                'artist', 'http://www.linkedin.com/pub/trevor-muzzy/5/282/538',
                LINK_TYPES.socialnetwork.artist
            ],
            [
                'artist', 'https://www.linkedin.com/in/legselectric',
                LINK_TYPES.socialnetwork.artist
            ],
            // Foursquare
            [
                'place', 'https://foursquare.com/v/high-line/40f1d480f964a5206a0a1fe3',
                LINK_TYPES.socialnetwork.place
            ],
            [
                'place', 'https://foursquare.com/taimmobile',
                LINK_TYPES.socialnetwork.place
            ],
            // WhoSampled
            [
                'recording', 'http://www.whosampled.com/Just-to-Get-a-Rep/Gang-Starr/',
                LINK_TYPES.otherdatabases.recording
            ],
            // MusicMoz
            [
                'artist', 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release', 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/Discography/Superunknown/',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'artist', 'http://www.rockinchina.com/w/Beyond_Cure_(TW)',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'artist', 'http://www.dhhu.dk/w/%C3%98stkyst_Hustlers',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release',
                'http://www.dhhu.dk/w/Jonny_Hefty_%26_Gratismixtape.dk_pr%C3%A6senterer_Actionspeax_-_Louder_Than_Words_Mixtape,_MP3/',
                LINK_TYPES.otherdatabases.release
            ],
            // The Session
            [
                'release_group', 'http://thesession.org/recordings/1488',
                LINK_TYPES.otherdatabases.release_group
            ],
            [
                'work', 'http://thesession.org/tunes/2305',
                LINK_TYPES.otherdatabases.work
            ],
            [
                'artist', 'http://thesession.org/recordings/artists/2836',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'artist', 'https://www.triplejunearthed.com/artist/sampa-great',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'event', 'http://thesession.org/events/3811',
                LINK_TYPES.otherdatabases.event
            ],
            // Wikimedia Commons
            [
                'artist', 'http://commons.wikimedia.org/wiki/File:NIN2008.jpg',
                LINK_TYPES.image.artist
            ],
            [
                'label', 'http://commons.wikimedia.org/wiki/File:EMI_Records.svg',
                LINK_TYPES.image.label
            ],
            [
                'work', 'http://commons.wikimedia.org/wiki/File:Kimigayo.score.png',
                LINK_TYPES.image.work
            ],

            [
                'work', 'http://www3.cpdl.org/wiki/index.php/Amor_sei_bei_rubini_(Peter_Philips)',
                LINK_TYPES.score.work
            ],

            // IMDb
            [
                'artist', 'http://www.imdb.com/name/nm1539156/',
                LINK_TYPES.imdb.artist
            ],
            [
                'release_group', 'http://www.imdb.com/title/tt0421082/',
                LINK_TYPES.imdb.release_group
            ],
            [
                'label', 'http://www.imdb.com/company/co0109498/',
                LINK_TYPES.imdb.label
            ],
            // Mora
            [
                'release', 'http://mora.jp/package/43000001/4534530058010/',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://mora.jp/package/43000014/KIZC-211/',
                LINK_TYPES.downloadpurchase.release
            ],
            // MySpace
            [
                'artist', 'https://myspace.com/instramentaluk',
                LINK_TYPES.myspace.artist
            ],
            [
                'label', 'https://myspace.com/hospitalrecords',
                LINK_TYPES.myspace.label
            ],
            // Soundcloud
            [
                'artist', 'https://soundcloud.com/metro-luminal',
                LINK_TYPES.soundcloud.artist
            ],
            [
                'label', 'https://soundcloud.com/dimmakrecords',
                LINK_TYPES.soundcloud.label
            ],
            [
                'series', 'https://soundcloud.com/glastonburyofficial',
                LINK_TYPES.soundcloud.series
            ],
            // Purevolume
            [
                'artist', 'http://www.purevolume.com/withbloodcomescleansing',
                LINK_TYPES.purevolume.artist
            ],
            // Recochoku
            [
                'release', 'http://recochoku.jp/album/30282664/',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'recording', 'http://recochoku.jp/song/S21893898/',
                LINK_TYPES.downloadpurchase.recording
            ],
            // Rockens Danmarkskort
            [
                'place', 'http://www.rockensdanmarkskort.dk/steder/den-gr%C3%A5-hal',
                LINK_TYPES.otherdatabases.place
            ],
            // NeyZen
            [
                'work', 'http://www.neyzen.com/nota_arsivi/02_klasik_eserler/054_mahur_buselik/mahur_buselik_ss_aydin_oran.pdf',
                LINK_TYPES.score.work
            ],
            // IMSLP
            [
                'work', 'http://imslp.org/wiki/Die_Zauberfl%C3%B6te,_K.620_(Mozart,_Wolfgang_Amadeus)',
                LINK_TYPES.score.work
            ],
            [
                'artist', 'http://imslp.org/wiki/Category:Buxtehude%2C_Dietrich',
                LINK_TYPES.imslp.artist
            ],
            // Jamendo
            [
                'recording', 'http://www.jamendo.com/en/track/725574/giraffe',
                LINK_TYPES.downloadfree.recording
            ],
            [
                'release', 'http://www.jamendo.com/en/list/a84763/crossing-state-lines',
                LINK_TYPES.downloadfree.release
            ],
            [
                'release', 'http://www.jamendo.com/album/16090',
                LINK_TYPES.downloadfree.release
            ],
            // Trove
            [
                'artist', 'http://nla.gov.au/nla.party-548358',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release', 'http://nla.gov.au/anbd.bib-an11701020',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'release_group', 'http://trove.nla.gov.au/work/9438679',
                LINK_TYPES.otherdatabases.release_group
            ],
            [
                'label', 'http://nla.gov.au/nla.party-1448035',
                LINK_TYPES.otherdatabases.label
            ],
            // Instagram
            [
                'artist', 'http://instagram.com/deadmau5',
                LINK_TYPES.socialnetwork.artist
            ],
            // Tumblr
            [
                'artist', 'http://deadmau5.tumblr.com/',
                LINK_TYPES.blog.artist
            ],
            // Japanese blogs
            [
                'artist', 'http://ameblo.jp/murataayumi/',
                LINK_TYPES.blog.artist
            ],
            [
                'label', 'http://ameblo.jp/murataayumi/',
                LINK_TYPES.blog.label
            ],
            [
                'artist', 'http://blog.livedoor.jp/mintmania/',
                LINK_TYPES.blog.artist
            ],
            [
                'label', 'http://blog.livedoor.jp/mintmania/',
                LINK_TYPES.blog.label
            ],
            [
                'artist', 'http://milk-pu-rin.jugem.jp/',
                LINK_TYPES.blog.artist
            ],
            [
                'label', 'http://milk-pu-rin.jugem.jp/',
                LINK_TYPES.blog.label
            ],
            [
                'artist', 'http://psgarden.exblog.jp/',
                LINK_TYPES.blog.artist
            ],
            [
                'label', 'http://psgarden.exblog.jp/',
                LINK_TYPES.blog.label
            ],
            [
                'release', 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
                LINK_TYPES.lyrics.release
            ],
            [
                'recording', 'https://embed.spotify.com/?uri=spotify:track:7gwRSZ0EmGWa697ZrE58GA',
                LINK_TYPES.streamingmusic.recording
            ],
            [
                'artist', 'http://www.deezer.com/artist/243332',
                LINK_TYPES.streamingmusic.artist
            ],
            [
                'release', 'http://www.deezer.com/album/497382',
                LINK_TYPES.streamingmusic.release
            ],
            [
                'recording', 'http://www.deezer.com/track/3437226',
                LINK_TYPES.streamingmusic.recording
            ],
            // Lyrics
            [
                'release', 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
                LINK_TYPES.lyrics.release
            ],
            [
                'work', 'http://www.lieder.net/lieder/get_text.html?TextId=6448',
                LINK_TYPES.lyrics.work
            ],
            [
                'work', 'http://www.utamap.com/showkasi.php?surl=34985',
                LINK_TYPES.lyrics.work
            ],
            [
                'work', 'http://decoda.com/robi-on-ne-meurt-plus-damour-lyrics',
                LINK_TYPES.lyrics.work
            ],
            // Vimeo
            [
                'recording', 'http://vimeo.com/1109226',
                LINK_TYPES.streamingmusic.recording
            ],
            // YouTube
            [
                'recording', 'http://www.youtube.com/watch?v=UmHdefsaL6I',
                LINK_TYPES.streamingmusic.recording
            ],
            [
                'artist', 'http://youtube.com/user/officialpsy/videos',
                LINK_TYPES.youtube.artist
            ],
            [
                'label', 'http://youtube.com/user/officialpsy/videos',
                LINK_TYPES.youtube.label
            ],
            // iTunes
            [
                'artist', 'http://itunes.apple.com/artist/hangry-angry-f/id444923726',
                LINK_TYPES.downloadpurchase.artist
            ],
            [
                'release', 'http://itunes.apple.com/gb/album/now-thats-what-i-call-music!-82/id543575947?v0=WWW-EUUK-STAPG-MUSIC-PROMO',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://itunes.apple.com/au/preorder/the-last-of-the-tourists/id499465357',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'recording', 'http://itunes.apple.com/music-video/gangnam-style/id564322420?v0=WWW-NAUS-ITSTOP100-MUSICVIDEOS&ign-mpt=uo%3D2',
                LINK_TYPES.downloadpurchase.recording
            ],
            // Other download stores
            [
                'artist', 'https://play.google.com/store/music/artist/Daylight?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
                LINK_TYPES.downloadpurchase.artist
            ],
            [
                'release', 'https://play.google.com/store/music/album/Disasterpeace_The_Floor_is_Jelly_Original_Soundtra?id=Bxpxunylzxqoqiiostyvocjtuu4',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'artist', 'http://www.7digital.com/artist/the-impatient-sisters',
                LINK_TYPES.downloadpurchase.artist
            ],
            [
                'release', 'http://www.7digital.com/artist/el-p/release/cancer-4-cure-1',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'artist', 'http://es.7digital.com/artist/the-impatient-sisters',
                LINK_TYPES.downloadpurchase.artist
            ],
            [
                'release', 'http://fr-ca.7digital.com/artist/the-impatient-sisters',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'artist', 'http://www.zdigital.com.au/artist/the-impatient-sisters',
                LINK_TYPES.downloadpurchase.artist
            ],
            [
                'release', 'http://www.beatport.com/release/summertime-sadness-cedric-gervais-remix/1029002',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://www.junodownload.com/products/caspa-subscape-geordie-racer-notixx-remix/2141988-02/',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://www.audiojelly.com/releases/turn-up-the-sound/242895',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://hd-music.info/album.cgi/913',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://ototoy.jp/_/default/p/45622',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'release', 'http://www.e-onkyo.com/music/album/vpcd81809/',
                LINK_TYPES.downloadpurchase.release
            ],
            [
                'artist', 'https://loudr.fm/artist/kyle-landry/Z77SM',
                LINK_TYPES.downloadpurchase.artist
            ],
            [
                'release', 'https://loudr.fm/release/dearly-beloved-2014/Vv2cZ',
                LINK_TYPES.downloadpurchase.release
            ],
            // Allmusic
            [
                'artist', 'http://www.allmusic.com/artist/the-beatles-mn0000754032/credits',
                LINK_TYPES.allmusic.artist
            ],
            [
                'release_group', 'http://www.allmusic.com/album/here-comes-the-sun-mw0002303439/releases',
                LINK_TYPES.allmusic.release_group
            ],
            [
                'work', 'http://www.allmusic.com/song/help!-mt0043064796',
                LINK_TYPES.allmusic.work
            ],
            [
                'work', 'http://www.allmusic.com/composition/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mc0002367338',
                LINK_TYPES.allmusic.work
            ],
            [
                'recording', 'http://www.allmusic.com/performance/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mq0000061129/credits',
                LINK_TYPES.allmusic.recording
            ],
            // Open Library
            [
                'artist', 'http://openlibrary.org/authors/OL23919A/',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release', 'http://openlibrary.org/books/OL8993487M/',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'work', 'http://openlibrary.org/works/OL82592W/',
                LINK_TYPES.otherdatabases.work
            ],
            // ReverbNation
            [
                'artist', 'http://www.reverbnation.com/asangelsbleed',
                LINK_TYPES.socialnetwork.artist
            ],
            // Twitter
            [
                'artist', 'https://twitter.com/miguelgrimaldo',
                LINK_TYPES.socialnetwork.artist
            ],
            // SoundtrackCollector
            [
                'artist', 'http://soundtrackcollector.com/composer/9/John+Williams',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release_group', 'http://soundtrackcollector.com/title/5751/Jurassic+Park',
                LINK_TYPES.otherdatabases.release_group
            ],
            // Second Hand Songs
            [
                'artist', 'http://www.secondhandsongs.com/artist/103',
                LINK_TYPES.secondhandsongs.artist
            ],
            [
                'release', 'http://www.secondhandsongs.com/release/888',
                LINK_TYPES.secondhandsongs.release
            ],
            [
                'work', 'http://www.secondhandsongs.com/work/1409',
                LINK_TYPES.secondhandsongs.work
            ],
            // VIAF
            [
                'artist', 'http://viaf.org/viaf/109231256',
                LINK_TYPES.viaf.artist
            ],
            [
                'label', 'http://viaf.org/viaf/152662182',
                LINK_TYPES.viaf.label
            ],
            [
                'work', 'http://viaf.org/viaf/185694157',
                LINK_TYPES.viaf.work
            ],
            // Lyricsnmusic
            [
                'work', 'http://www.lyricsnmusic.com/david-hasselhoff/white-christmas-lyrics/27952232',
                LINK_TYPES.lyrics.work
            ],
            // BBC Music
            [
                'artist', 'http://www.bbc.co.uk/music/artists/b52dd210-909c-461a-a75d-19e85a522042',
                LINK_TYPES.bbcmusic.artist
            ],
            // Anime News Network
            [
                'artist', 'http://www.animenewsnetwork.com/encyclopedia/people.php?id=59062',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'label', 'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510',
                LINK_TYPES.otherdatabases.label
            ],
            // VK
            [
                'artist', 'http://vk.com/tin_sontsya',
                LINK_TYPES.socialnetwork.artist
            ],
            [
                'artist', 'https://vine.co/destorm',
                LINK_TYPES.socialnetwork.artist
            ],
            // Generasia
            [
                'artist', 'http://www.generasia.com/wiki/Wink',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release_group', 'http://www.generasia.com/wiki/Ai_ga_Tomaranai_~Turn_It_into_Love~',
                LINK_TYPES.otherdatabases.release_group
            ],
            [
                'work', 'http://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
                LINK_TYPES.otherdatabases.work
            ],
            // Japanese discography pages
            [
                'release', 'http://www.universal-music.co.jp/sweety/products/umca-59007/',
                LINK_TYPES.discographyentry.release
            ],
            [
                'release', 'http://www.lantis.jp/release-item2.php?id=326c88aa1cd230f96ef350e380a23078',
                LINK_TYPES.discographyentry.release
            ],
            [
                'release', 'http://www.jvcmusic.co.jp/-/Discography/A015120/VICC-60560.html',
                LINK_TYPES.discographyentry.release
            ],
            [
                'release', 'http://wmg.jp/artist/ayaka/WPCL000010415.html',
                LINK_TYPES.discographyentry.release
            ],
            [
                'release', 'http://avexnet.jp/id/supeg/discography/product/CTCR-11051.html',
                LINK_TYPES.discographyentry.release
            ],
            [
                'release', 'http://www.kingrecords.co.jp/cs/g/gKICM-1091/',
                LINK_TYPES.discographyentry.release
            ],
            // Classical discography pages
            [
                'release', 'http://www.naxos.com/catalogue/item.asp?item_code=8.553162',
                LINK_TYPES.discographyentry.release
            ],
            [
                'release', 'http://bis.se/index.php?op=album&aID=BIS-1961',
                LINK_TYPES.discographyentry.release
            ],
            // Wikidata
            [
                'artist', 'http://www.wikidata.org/wiki/Q42',
                LINK_TYPES.wikidata.artist
            ],
            [
                'label', 'http://www.wikidata.org/wiki/Q42',
                LINK_TYPES.wikidata.label
            ],
            [
                'release_group', 'http://www.wikidata.org/wiki/Q42',
                LINK_TYPES.wikidata.release_group
            ],
            [
                'work', 'http://www.wikidata.org/wiki/Q42',
                LINK_TYPES.wikidata.work
            ],
            // Rockipedia
            [
                'artist', 'http://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'label', 'http://www.rockipedia.no/plateselskap/universal_music-1719/',
                LINK_TYPES.otherdatabases.label
            ],
            [
                'release', 'http://www.rockipedia.no/utgivelser/hunting_high_and_low_-_remastered_and_ex-7991/',
                LINK_TYPES.otherdatabases.release
            ],
            // VGMdb
            [
                'artist', 'http://vgmdb.net/artist/431',
                LINK_TYPES.vgmdb.artist
            ],
            [
                'label', 'http://vgmdb.com/org/284',
                LINK_TYPES.vgmdb.label
            ],
            [
                'artist', 'http://vgmdb.com/org/284', // VGMdb orgs can be groups
                LINK_TYPES.vgmdb.artist
            ],
            [
                'release', 'http://vgmdb.net/album/29727',
                LINK_TYPES.vgmdb.release
            ],
            [
                'release_group', 'http://www.metal-archives.com/reviews/Myrkwid/Part_I/36375/',
                LINK_TYPES.review.release_group
            ],
            [
                'artist', 'http://www.metal-archives.com/bands/Karna/26483',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release_group', 'http://www.metal-archives.com/albums/Corubo/Ypykuera/193860',
                LINK_TYPES.otherdatabases.release_group
            ],
            [
                'area', 'http://www.geonames.org/6255147/asia.html',
                LINK_TYPES.geonames.area
            ],
            // setlist.fm
            [
                'artist', 'http://www.setlist.fm/setlists/foo-fighters-bd6893a.html',
                LINK_TYPES.setlistfm.artist
            ],
            [
                'event', 'http://www.setlist.fm/setlist/foo-fighters/2014/house-of-blues-new-orleans-la-13cda5b1.html',
                LINK_TYPES.setlistfm.event
            ],
            [
                'place', 'http://www.setlist.fm/venue/house-of-blues-new-orleans-la-usa-23d61c9f.html',
                LINK_TYPES.setlistfm.place
            ],
            [
                'release', 'http://mainlynorfolk.info/martin.carthy/records/themoraloftheelephant.html',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'artist', 'http://tedcrane.com/DanceDB/DisplayIdent.com?key=DONNA_HUNT',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'artist', 'http://www.bibliotekapiosenki.pl/Trzetrzelewska_Barbara',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'artist', 'http://www.qim.com/artistes/biographie.asp?artistid=47',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'artist', 'http://www.thedancegypsy.com/performerList.php?musician=George+Marshall',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release', 'https://www.finna.fi/Record/viola.163990',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'recording', 'http://www.mvdbase.com/video.php?id=4',
                LINK_TYPES.otherdatabases.recording
            ],
            [
                'release', 'http://videogam.in/music/?id=PCCG-00486',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'work', 'http://tunearch.org/wiki/Lovely_Lass_to_a_Friar_Came_(2)_(A)',
                LINK_TYPES.otherdatabases.work
            ],
            [
                'artist', 'http://www.folkwiki.se/Personer/SvenDonat',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'artist', 'http://www.spirit-of-rock.com/groupe-groupe-Explosions_In_The_Sky-l-en.html',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release_group', 'http://castalbums.org/recordings/The-Scottsboro-Boys-2014-Original-London-Cast/28967',
                LINK_TYPES.otherdatabases.release_group
            ],
            [
                'release_group', 'http://smdb.kb.se/catalog/id/001508972',
                LINK_TYPES.otherdatabases.release_group
            ],
            [
                'work', 'http://www.operadis-opera-discography.org.uk/CLBABLUE.HTM',
                LINK_TYPES.otherdatabases.work
            ],
            // ClassicalArchives.com
            [
                'artist', 'http://www.classicalarchives.com/composer/2806.html',
                LINK_TYPES.otherdatabases.artist
            ],
            [
                'release', 'http://www.classicalarchives.com/album/menlo-201409.html',
                LINK_TYPES.otherdatabases.release
            ],
            [
                'work', 'http://www.classicalarchives.com/work/1119282.html',
                LINK_TYPES.otherdatabases.work
            ],
            // CDJapan.co.jp
            [
                'artist', 'http://www.cdjapan.co.jp/person/76324',
                LINK_TYPES.mailorder.artist
            ],
            [
                'release', 'http://www.cdjapan.co.jp/product/COCC-72267',
                LINK_TYPES.mailorder.release
            ]
        ];

    $.each(tests, function (i, test) {
        t.equal(guessType(test[0], test[1]), test[2], test[1] + " (" + test[0] + ")");
    });

    t.end();
});

test('Cleanup', function (t) {
    var tests = [
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
                'http://www.amazon.in/dp/B006H1JVW4',
                'http://www.amazon.in/gp/product/B006H1JVW4',
                'release'
            ],
            [
                'http://amazon.com.br/dp/B00T8E47G2',
                'http://www.amazon.com.br/gp/product/B00T8E47G2',
                'release'
            ],
            // %E2%80%8E cleanup
            [
                'https://soundcloud.com/alisonwonderland%E2%80%8E',
                'https://soundcloud.com/alisonwonderland',
                'artist'
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
            // Twitter
            [
                'http://twitter.com/miguelgrimaldo',
                'https://twitter.com/miguelgrimaldo',
                'artist'
            ],
            [
                'https://mobile.twitter.com/cirrhaniva',
                'https://twitter.com/cirrhaniva',
                'artist'
            ],
            [
                'https://twitter.com/@UNIVERSAL_D',
                'https://twitter.com/UNIVERSAL_D',
                'artist'
            ],
            [
                'http://twitter.com/ACEHOOD/',
                'https://twitter.com/ACEHOOD',
                'artist'
            ],
            // SoundCloud
            [
                'http://soundcloud.com/alec_empire',
                'https://soundcloud.com/alec_empire',
                'artist'
            ],
            [ // mobile subdomain should be removed
                'http://m.soundcloud.com/octobersveryown',
                'https://soundcloud.com/octobersveryown',
                'artist'
            ],
            [ // #! should be removed
                'http://www.reverbnation.com/#!/benwebbmusic',
                'http://www.reverbnation.com/benwebbmusic',
                'artist'
            ],
            [ // scheme should be http
                'https://www.reverbnation.com/littlesparrow',
                'http://www.reverbnation.com/littlesparrow',
                'artist'
            ],
            [ // www should be included
                'http://reverbnation.com/negator',
                'http://www.reverbnation.com/negator',
                'artist'
            ],
            [ // mobile subdomain should be www
                'http://m.reverbnation.com/venue/602562',
                'http://www.reverbnation.com/venue/602562',
                'event'
            ],
            // Discogs
            [
                'http://www.discogs.com/Various-Out-Patients-2/release/5578',
                'http://www.discogs.com/release/5578',
                'release'
            ],
            [
                'http://www.discogs.com/artist/3080207-Maybebop',
                'http://www.discogs.com/artist/3080207',
                'artist'
            ],
            [
                'http://www.discogs.com/artist/1944002-',
                'http://www.discogs.com/artist/1944002',
                'artist'
            ],
            [
                'http://www.discogs.com/master/view/267989',
                'http://www.discogs.com/master/267989',
                'release_group'
            ],
            [
                // FIXME Need a "bad" archive.org link
                'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
                'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
                'release'
            ],
            [
                'http://www.archive.org/download/JudasHalo/cover.jpg',
                'https://archive.org/download/JudasHalo/cover.jpg',
            ],
            [
                'https://archive.org/details/NormRejection-MaltaNotForSaleEp-Dtm020/',
                'https://archive.org/details/NormRejection-MaltaNotForSaleEp-Dtm020',
            ],
            [
                'http://ia700301.us.archive.org/32/items/NormRejection-MaltaNotForSaleEp-Dtm020/DTM020sml.jpg',
                'https://archive.org/download/NormRejection-MaltaNotForSaleEp-Dtm020/DTM020sml.jpg',
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
                'thesession.org/events/3811#comment748363',
                'http://thesession.org/events/3811',
                'event'
            ],
            [
                'http://thesession.org/recordings/4740/edit',
                'http://thesession.org/recordings/4740',
                'release_group'
            ],
            [
                'http://thesession.org/recordings/artists/793?test',
                'http://thesession.org/recordings/artists/793',
                'artist'
            ],
            // Blogspot
            [
                'http://49swimmingpools.blogspot.fr/',
                'http://49swimmingpools.blogspot.com/',
                'artist'
            ],
            [
                'www.afroliciousoriginal.blogspot.pt',
                'afroliciousoriginal.blogspot.com/',
                'artist'
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
            [
                'http://www.facebook.com/pages/De_Tot_Cor/133207893384897/',
                'https://www.facebook.com/pages/De_Tot_Cor/133207893384897',
                'artist'
            ],
            [
                'https://www.facebook.com/events/779218695457920/?ref=2&ref_dashboard_filter=past&sid_reminder=1385056373762424832',
                'https://www.facebook.com/events/779218695457920',
                'event'
            ],
            [
                'https://www.facebook.com/event.php?eid=129606980393356',
                'https://www.facebook.com/events/129606980393356',
                'event'
            ],
            [
                'http://www.lastfm.de/event/671822+Ruhrpott+rodeo+at+Flugplatz+Schwarze+Heide+on+27+June+2008',
                'http://www.last.fm/event/671822+Ruhrpott+rodeo+at+Flugplatz+Schwarze+Heide+on+27+June+2008',
                'event'
            ],
            [
                'http://www.lastfm.de/festival/297838+Death+Feast+2008',
                'http://www.last.fm/festival/297838+Death+Feast+2008',
                'event'
            ],
            [
                'http://www.songkick.com/venues/1141041-flugplatz-schwarze-heide',
                'https://www.songkick.com/venues/1141041-flugplatz-schwarze-heide',
                'event'
            ],
            [
                'http://www.songkick.com/festivals/74586-ruhrpott-rodeo/id/19803209-ruhrpott-rodeo-festival-2014',
                'https://www.songkick.com/festivals/74586-ruhrpott-rodeo/id/19803209-ruhrpott-rodeo-festival-2014',
                'event'
            ],

                // Google+
            [
                'http://plus.google.com/u/0/101821796946045393834/about',
                'https://plus.google.com/101821796946045393834',
                'artist'
            ],
            [
                'http://www.deezer.com/artist/6509511?test',
                'https://www.deezer.com/artist/6509511',
                'streamingmusic'
            ],
            [
                'https://deezer.com/album/8935347',
                'https://www.deezer.com/album/8935347',
                'streamingmusic'
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
            // YouTube
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
                'https://www.youtube.com/user/JessVincentMusic?feature=watch',
                'http://www.youtube.com/user/JessVincentMusic',
                'artist'
            ],
            [
                'http://m.youtube.com/#/user/JessVincentMusic',
                'http://www.youtube.com/user/JessVincentMusic',
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
            // Bandcamp
            [
                'https://davidrovics.bandcamp.com?test',
                'http://davidrovics.bandcamp.com/',
                'artist'
            ],
            [
                'http://idiotsikker.bandcamp.com/tra#top',
                'http://idiotsikker.bandcamp.com/',
                'label'
            ],
            [
                'https://andrewhuang.bandcamp.com/track/boom-box/?test',
                'http://andrewhuang.bandcamp.com/track/boom-box',
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
                'https://itunes.apple.com/album/beatbox-+-iphone-+-guitar/id589456329?ign-mpt=uo%3D4',
                'https://itunes.apple.com/album/id589456329',
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
                'https://itunes.apple.com/us/album/timber-feat.-ke$ha-single/id721686178',
                'https://itunes.apple.com/us/album/id721686178',
                'release'
            ],
            [
                'https://loudr.fm/artist/kyle-landry/Z77SM?test',
                'https://loudr.fm/artist/kyle-landry/Z77SM',
                'artist'
            ],
            [
                'http://loudr.fm/release/dearly-beloved-2014/Vv2cZ',
                'https://loudr.fm/release/dearly-beloved-2014/Vv2cZ',
                'release'
            ],
            [
                'https://play.google.com/store/music/artist/Daylight?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
                'https://play.google.com/store/music/artist?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
                'artist'
            ],
            [
                'https://play.google.com/store/music/album/Disasterpeace_The_Floor_is_Jelly_Original_Soundtra?id=Bxpxunylzxqoqiiostyvocjtuu4',
                'https://play.google.com/store/music/album?id=Bxpxunylzxqoqiiostyvocjtuu4',
                'release'
            ],

            [ // scheme should be https
                'http://play.google.com/store/music/artist?id=Aathd3z2apf2hbln4wgkrthmhqu',
                'https://play.google.com/store/music/artist?id=Aathd3z2apf2hbln4wgkrthmhqu',
                'artist'
            ],
            [ // other parameters should be removed
                'https://play.google.com/store/music/artist/Julia_Haltigan_The_Hooligans?id=Avnwgjjbdf6la5zvdjf62k4jylq&hl=en',
                'https://play.google.com/store/music/artist?id=Avnwgjjbdf6la5zvdjf62k4jylq',
                'artist'
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
            [
                'http://wikipedia.org/wiki/Oberhofer',
                'https://en.wikipedia.org/wiki/Oberhofer',
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
            [
                'http://viaf.org/viaf/32197206/#Mozart,_Wolfgang_Amadeus,_1756-1791',
                'http://viaf.org/viaf/32197206',
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
            // Mora
            [
                'https://www.mora.jp/package/43000002/ANTCD-3106?test',
                'http://mora.jp/package/43000002/ANTCD-3106/',
            ],
            [
                'mora.jp/package/43000002/ANTCD-3106/',
                'http://mora.jp/package/43000002/ANTCD-3106/',
            ],
            [
                'http://mora.jp/package/43000021/SQEX-20016_F/#',
                'http://mora.jp/package/43000021/SQEX-20016_F/',
            ],
            // Soundtrack Collector
            [
                'http://soundtrackcollector.com/composer/94/Hans+Zimmer',
                'http://soundtrackcollector.com/composer/94/',
                'artist'
            ],
            [
                'http://www.soundtrackcollector.com/title/39473/Pledge%2C+The',
                'http://soundtrackcollector.com/title/39473/',
                'release_group'
            ],
            [
                'https://www.soundtrackcollector.com/catalog/soundtrackdetail.php?movieid=99711',
                'http://soundtrackcollector.com/title/99711/',
                'release_group'
            ],
            [
                'http://www.soundtrackcollector.com/catalog/composerdiscography.php?composerid=94',
                'http://soundtrackcollector.com/composer/94/',
                'artist'
            ],
            // Recochoku
            [
                'https://www.recochoku.jp/album/30282664?test',
                'http://recochoku.jp/album/30282664/',
            ],
            [
                'recochoku.jp/song/S21893898/',
                'http://recochoku.jp/song/S21893898/',
            ],
            // Rockipedia
            [
                'https://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/?test',
                'http://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/',
            ],
            // VGMdb
            [
                'https://vgmdb.net/artist/431',
                'http://vgmdb.net/artist/431',
                'artist'
            ],
            [
                'https://vgmdb.com/org/284',
                'http://vgmdb.net/org/284',
                'label'
            ],
            [
                'vgmdb.net/album/29727',
                'http://vgmdb.net/album/29727',
                'release'
            ],
            [
                'http://www.lastfm.com.br/venue/8803923+Gigantinho',
                'http://www.last.fm/venue/8803923+Gigantinho',
            ],
            [
                'http://www.lastfm.com/music/Carving+Colours',
                'http://www.last.fm/music/Carving+Colours',
            ],
            [
                'http://commons.wikimedia.org/wiki/File:Kimigayo.score.png?uselang=de',
                'https://commons.wikimedia.org/wiki/File:Kimigayo.score.png',
                'work'
            ],
            [
                'http://commons.wikimedia.org/wiki/Main_Page#mediaviewer/File:Origanum_vulgare_-_harilik_pune.jpg',
                'https://commons.wikimedia.org/wiki/File:Origanum_vulgare_-_harilik_pune.jpg'
            ],
            [
                'http://www.geonames.org/6255147/asia.html',
                'http://sws.geonames.org/6255147/',
                'area'
            ],
            // Genius
            [
                'http://genius.com/artists/Dramatik',
                'http://genius.com/artists/Dramatik',
                'artist'
            ],
            [
                'http://genius.com/albums/The-dream/Terius-nash-1977',
                'http://genius.com/albums/The-dream/Terius-nash-1977',
                'release_group'
            ],
            [
                'http://rock.genius.com/The-beatles-she-loves-you-lyrics',
                'http://rock.genius.com/The-beatles-she-loves-you-lyrics',
                'work'
            ],
            // Trove
            [
                'http://trove.nla.gov.au/people/1448035?c=people',
                'http://nla.gov.au/nla.party-1448035',
                'label'
            ],
            [
                'https://nla.gov.au/nla.party-548358/',
                'http://nla.gov.au/nla.party-548358',
                'artist'
            ],
            [
                'trove.nla.gov.au/work/9438679',
                'http://trove.nla.gov.au/work/9438679',
                'release_group'
            ],
            [
                'http://nla.gov.au/anbd.bib-an11701020#',
                'http://nla.gov.au/anbd.bib-an11701020',
                'release_group'
            ],
            // ClassicalArchives.com
            [
                'www.classicalarchives.com/composer/2806.html#tvf=tracks&tv=albums',
                'http://www.classicalarchives.com/composer/2806.html',
                'artist'
            ],
            [
                'http://classicalarchives.com/album/menlo-201409.html?test',
                'http://www.classicalarchives.com/album/menlo-201409.html',
                'release'
            ],
            [
                'https://www.classicalarchives.com/work/1119282.html',
                'http://www.classicalarchives.com/work/1119282.html',
                'work'
            ],
            // CDJapan.co.jp
            [
                'www.cdjapan.co.jp/person/76324#test',
                'http://www.cdjapan.co.jp/person/76324',
                'artist'
            ],
            [
                'https://cdjapan.co.jp/product/COCC-72267?test',
                'http://www.cdjapan.co.jp/product/COCC-72267',
                'release'
            ],
            // Sina Weibo
            [
                'www.weibo.com/mchotdog2010#test',
                'http://www.weibo.com/mchotdog2010',
                'artist'
            ],
            [
                'https://weibo.com/mchotdog2010?test',
                'http://www.weibo.com/mchotdog2010',
                'label'
            ],
            // LinkedIn
            [
                'http://www.linkedin.com/in/test',
                'https://www.linkedin.com/in/test',
                'artist'
            ],
            // Foursquare
            [
                'http://www.foursquare.com/test',
                'https://foursquare.com/test',
                'place'
            ],
            [
                'http://foursquare.com/v/high-line/40f1d480f964a5206a0a1fe3',
                'https://foursquare.com/v/high-line/40f1d480f964a5206a0a1fe3',
                'place'
            ],
            // MBS-8457: Remove "?oldformat=true" from Wikipedia URLs
            [
                'http://en.wikipedia.org/wiki/Ramesh_Vinayakam?oldformat=true',
                'http://en.wikipedia.org/wiki/Ramesh_Vinayakam'
            ]
        ];

    $.each(tests, function (i, test) {
        t.equal(cleanURL(test[0]), test[1], test[0] + (test[2] ? " (" + test[2] + ")": "") + " -> " + test[1]);
    });

    t.end();
});
