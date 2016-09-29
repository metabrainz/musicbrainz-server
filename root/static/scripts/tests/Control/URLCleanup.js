// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

const _ = require('lodash');

const {LINK_TYPES, cleanURL, guessType, validationRules} = require('../../edit/URLCleanup');

test('URL cleanup component: auto-select, clean-up, and validation', {}, function (t) {
    const test_data = [
        // 7digital (zdigital)
        {
                             input_url: 'http://es.7digital.com/artist/the-impatient-sisters',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
        },
        {
                             input_url: 'http://www.7digital.com/artist/the-impatient-sisters',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
        },
        {
                             input_url: 'http://www.zdigital.com.au/artist/the-impatient-sisters',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
        },
        {
                             input_url: 'http://fr-ca.7digital.com/artist/the-impatient-sisters',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        {
                             input_url: 'http://www.7digital.com/artist/el-p/release/cancer-4-cure-1',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // AllMusic
        {
                             input_url: 'http://www.allmusic.com/artist/the-beatles-mn0000754032/credits',
                     input_entity_type: 'artist',
            expected_relationship_type: 'allmusic',
                    expected_clean_url: 'http://www.allmusic.com/artist/mn0000754032',
               only_valid_entity_types: ['artist']
        },
        {
                             input_url: 'http://www.allmusic.com/performance/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mq0000061129/credits',
                     input_entity_type: 'recording',
            expected_relationship_type: 'allmusic',
                    expected_clean_url: 'http://www.allmusic.com/performance/mq0000061129',
               only_valid_entity_types: ['recording']
        },
        {
                             input_url: 'http://www.allmusic.com/album/here-comes-the-sun-mw0002303439/releases',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'allmusic',
                    expected_clean_url: 'http://www.allmusic.com/album/mw0002303439',
               only_valid_entity_types: ['release_group']
        },
        {
                             input_url: 'http://www.allmusic.com/composition/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mc0002367338',
                     input_entity_type: 'work',
            expected_relationship_type: 'allmusic',
                    expected_clean_url: 'http://www.allmusic.com/composition/mc0002367338',
               only_valid_entity_types: ['work']
        },
        {
                             input_url: 'http://www.allmusic.com/song/help!-mt0043064796',
                     input_entity_type: 'work',
            expected_relationship_type: 'allmusic',
                    expected_clean_url: 'http://www.allmusic.com/song/mt0043064796',
               only_valid_entity_types: ['work']
        },
        // Amazon
        {
                             input_url: 'http://www.amazon.co.uk/gp/product/B00005JIWP',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
        },
        {
                             input_url: 'http://amazon.com.br/dp/B00T8E47G2',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.com.br/gp/product/B00T8E47G2',
        },
        {
                             input_url: 'http://www.amazon.in/dp/B006H1JVW4',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.in/gp/product/B006H1JVW4',
        },
        {
                             input_url: 'http://amzn.com/B000005SU4',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.com/gp/product/B000005SU4',
        },
        {
                             input_url: 'http://www.amazon.co.jp/dp/tracks/B000Y3JG8U#disc_1',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.co.jp/gp/product/B000Y3JG8U',
        },
        {
                             input_url: 'http://www.amazon.co.uk/IMPOSSIBLE/dp/B00008CQP2/ref=sr_1_1?ie=UTF8&qid=1344584322&sr=8-1',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.co.uk/gp/product/B00008CQP2',
        },
        {
                             input_url: 'http://www.amazon.co.uk/Out-Patients-Vol-3-Various-Artists/dp/B00009W0XE/ref=pd_sim_m_h__1',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.co.uk/gp/product/B00009W0XE',
        },
        {
                             input_url: 'http://www.amazon.com/Shine-We-Are-BoA/dp/B00015007W%3FSubscriptionId%3D14P3HXS0ZAYFZPH45TR2%26tag%3Dws%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3DB00015007W',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.com/gp/product/B00015007W',
        },
        {
                             input_url: 'https://www.amazon.co.jp/AMARANTHUS%E3%80%90%E9%80%9A%E5%B8%B8%E7%9B%A4%E3%80%91-%E3%82%82%E3%82%82%E3%81%84%E3%82%8D%E3%82%AF%E3%83%AD%E3%83%BC%E3%83%90%E3%83%BCZ/dp/B0136OCSS8/376-0245530-0562731?ie=UTF8&keywords=4988003477523&qid=1455928973&ref_=sr_1_1&sr=8-1',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.co.jp/gp/product/B0136OCSS8',
        },
        {
                             input_url: 'https://www.amazon.co.uk/Nigel-Kennedy-Polish-Emil-Mynarski/dp/B000VLR0II',
                     input_entity_type: 'release',
            expected_relationship_type: 'amazon',
                    expected_clean_url: 'http://www.amazon.co.uk/gp/product/B000VLR0II',
        },
        {
                             input_url: 'http://www.amazon.co.uk/Kosheen/e/B000APRTKE',
                    expected_clean_url: 'http://www.amazon.co.uk/-/e/B000APRTKE',
        },
        {
                             input_url: 'http://www.amazon.com/gp/redirect.html/ref=amb_link_7764682_1?location=http://www.amazon.com/Carrie-Underwood/e/B0017PAU8Y/%20&token=3A0F170E7CEFE27BDC730D3D7344512BC1296B83&pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-4&pf_rd_r=0WX9S8HSE9M2WG1YZJE4&pf_rd_t=101&pf_rd_p=80631142&pf_rd_i=721517011',
                    expected_clean_url: 'http://www.amazon.com/-/e/B0017PAU8Y',
        },
        // Ameba
        {
                             input_url: 'http://ameblo.jp/murataayumi',
                     input_entity_type: 'artist',
            expected_relationship_type: 'blog',
                    expected_clean_url: 'http://ameblo.jp/murataayumi/',
        },
        {
                             input_url: 'http://ameblo.jp/murataayumi/',
                     input_entity_type: 'label',
            expected_relationship_type: 'blog',
        },
        // Anime News Network
        {
                             input_url: 'http://animenewsnetwork.com/encyclopedia/people.php?id=59062',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.animenewsnetwork.com/encyclopedia/people.php?id=59062',
        },
        {
                             input_url: 'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510#page_header',
                     input_entity_type: 'label',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510',
        },
        // (Internet) Archive
        {
                             input_url: 'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
                     input_entity_type: 'release',
            expected_relationship_type: undefined,
                    expected_clean_url: 'http://web.archive.org/web/20100904165354/i265.photobucket.com/albums/ii229/drsaunde/487015.jpg',
        },
        {
                             input_url: 'http://ia700301.us.archive.org/32/items/NormRejection-MaltaNotForSaleEp-Dtm020/DTM020sml.jpg',
                    expected_clean_url: 'https://archive.org/download/NormRejection-MaltaNotForSaleEp-Dtm020/DTM020sml.jpg',
        },
        {
                             input_url: 'http://www.archive.org/download/JudasHalo/cover.jpg',
                    expected_clean_url: 'https://archive.org/download/JudasHalo/cover.jpg',
        },
        {
                             input_url: 'https://archive.org/details/NormRejection-MaltaNotForSaleEp-Dtm020/',
                    expected_clean_url: 'https://archive.org/details/NormRejection-MaltaNotForSaleEp-Dtm020',
        },
        // Audiojelly
        {
                             input_url: 'http://www.audiojelly.com/releases/turn-up-the-sound/242895',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // Avex Trax
        {
                             input_url: 'http://avexnet.jp/id/supeg/discography/product/CTCR-11051.html',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Bandcamp
        {
                             input_url: 'https://davidrovics.bandcamp.com?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'bandcamp',
                    expected_clean_url: 'http://davidrovics.bandcamp.com/',
               only_valid_entity_types: ['artist', 'label']
        },
        {
                             input_url: 'http://idiotsikker.bandcamp.com/tra#top',
                     input_entity_type: 'label',
            expected_relationship_type: 'bandcamp',
                    expected_clean_url: 'http://idiotsikker.bandcamp.com/',
               only_valid_entity_types: ['artist', 'label']
        },
        {
                             input_url: 'https://andrewhuang.bandcamp.com/track/boom-box/?test',
                     input_entity_type: 'recording',
            expected_relationship_type: undefined,
                    expected_clean_url: 'http://andrewhuang.bandcamp.com/track/boom-box',
               input_relationship_type: 'bandcamp',
               only_valid_entity_types: []
        },
        // BBC Music
        {
                             input_url: 'http://www.bbc.co.uk/music/artists/b52dd210-909c-461a-a75d-19e85a522042',
                     input_entity_type: 'artist',
            expected_relationship_type: 'bbcmusic',
        },
        // Beatport
        {
                             input_url: 'http://www.beatport.com/release/summertime-sadness-cedric-gervais-remix/1029002',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // Biblioteka Polskiej Piosenki
        {
                             input_url: 'http://www.bibliotekapiosenki.pl/Trzetrzelewska_Barbara',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // BIS Records
        {
                             input_url: 'http://bis.se/index.php?op=album&aID=BIS-1961',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Blogspot
        {
                             input_url: 'http://49swimmingpools.blogspot.fr/',
                     input_entity_type: 'artist',
            expected_relationship_type: undefined,
                    expected_clean_url: 'http://49swimmingpools.blogspot.com/',
        },
        {
                             input_url: 'www.afroliciousoriginal.blogspot.pt',
                     input_entity_type: 'artist',
            expected_relationship_type: undefined,
                    expected_clean_url: 'afroliciousoriginal.blogspot.com/',
        },
        // BookBrainz
        {
                             input_url: 'https://bookbrainz.org/creator/8f3d202f-fa37-4b71-9e81-652db0f8b83d?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'bookbrainz',
                    expected_clean_url: 'https://bookbrainz.org/creator/8f3d202f-fa37-4b71-9e81-652db0f8b83d',
        },
        {
                             input_url: 'https://bookbrainz.org/creator/8f3d202f-fa37-4b71-9e81-652db0f8b83d#content',
                     input_entity_type: 'artist',
            expected_relationship_type: 'bookbrainz',
                    expected_clean_url: 'https://bookbrainz.org/creator/8f3d202f-fa37-4b71-9e81-652db0f8b83d',
        },
        {
                             input_url: 'http://bookbrainz.org/publisher/252aed09-dc5f-46d6-aa32-323d5d44351d',
                     input_entity_type: 'label',
            expected_relationship_type: 'bookbrainz',
                    expected_clean_url: 'https://bookbrainz.org/publisher/252aed09-dc5f-46d6-aa32-323d5d44351d',
        },
        {
                             input_url: 'bookbrainz.org/edition/9f8f399f-7221-4e98-86aa-d117302c60de',
                     input_entity_type: 'release',
            expected_relationship_type: 'bookbrainz',
                    expected_clean_url: 'https://bookbrainz.org/edition/9f8f399f-7221-4e98-86aa-d117302c60de',
        },
        {
                             input_url: 'https://bookbrainz.org/publication/e8da2663-0ffc-45b1-a95d-eb2a0917f8de/',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'bookbrainz',
                    expected_clean_url: 'https://bookbrainz.org/publication/e8da2663-0ffc-45b1-a95d-eb2a0917f8de',
        },
        {
                             input_url: 'https://bookbrainz.org/work/65e71f2e-7245-42df-b93e-89463a28f75c/edits',
                     input_entity_type: 'work',
            expected_relationship_type: 'bookbrainz',
                    expected_clean_url: 'https://bookbrainz.org/work/65e71f2e-7245-42df-b93e-89463a28f75c',
        },
        // CastAlbums.org
        {
                             input_url: 'http://castalbums.org/recordings/The-Scottsboro-Boys-2014-Original-London-Cast/28967',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
        },
        // CDJapan
        {
                             input_url: 'www.cdjapan.co.jp/person/76324#test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'mailorder',
                    expected_clean_url: 'http://www.cdjapan.co.jp/person/76324',
        },
        {
                             input_url: 'https://cdjapan.co.jp/product/COCC-72267?test',
                     input_entity_type: 'release',
            expected_relationship_type: 'mailorder',
                    expected_clean_url: 'http://www.cdjapan.co.jp/product/COCC-72267',
        },
        // ChangeTip (Tip.Me)
        {
                             input_url: 'https://www.changetip.com/tipme/example',
                     input_entity_type: 'artist',
            expected_relationship_type: 'patronage',
                    expected_clean_url: 'https://www.changetip.com/tipme/example',
        },
        {
                             input_url: 'example.tip.me',
                     input_entity_type: 'event',
            expected_relationship_type: 'patronage',
                    expected_clean_url: 'https://www.changetip.com/tipme/example',
        },
        // Classical Archives
        {
                             input_url: 'www.classicalarchives.com/composer/2806.html#tvf=tracks&tv=albums',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.classicalarchives.com/composer/2806.html',
        },
        {
                             input_url: 'http://classicalarchives.com/album/menlo-201409.html?test',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.classicalarchives.com/album/menlo-201409.html',
        },
        {
                             input_url: 'https://www.classicalarchives.com/work/1119282.html',
                     input_entity_type: 'work',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.classicalarchives.com/work/1119282.html',
        },
        // CPDL (Choral Public Domain Library)
        {
                             input_url: 'http://cpdl.org/wiki/index.php/Amor_sei_bei_rubini_(Peter_Philips)',
                     input_entity_type: 'work',
            expected_relationship_type: 'score',
        },
        {
                             input_url: 'www2.cpdl.org/wiki/index.php/Weave_Me_A_Poem_(Tim_Blickhan)',
                     input_entity_type: 'work',
            expected_relationship_type: 'score',
                    expected_clean_url: 'http://cpdl.org/wiki/index.php/Weave_Me_A_Poem_(Tim_Blickhan)',
        },
        // Creative Commons
        {
                             input_url: 'http://creativecommons.org/licenses/by-nc-nd/2.5/es/deed.es',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/licenses/by-nc-nd/2.5/es/',
        },
        {
                             input_url: 'http://creativecommons.org/licenses/by-nc-sa/2.0/de//',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/licenses/by-nc-sa/2.0/de/',
        },
        {
                             input_url: 'http://creativecommons.org/licenses/by/2.0/scotland',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/licenses/by/2.0/scotland/',
        },
        {
                             input_url: 'http://creativecommons.org/licenses/publicdomain',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/licenses/publicdomain/',
        },
        {
                             input_url: 'http://creativecommons.org/licenses/publicdomain//',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/licenses/publicdomain/',
        },
        {
                             input_url: 'http://creativecommons.org/publicdomain/zero/1.0',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/publicdomain/zero/1.0/',
        },
        {
                             input_url: 'http://creativecommons.org/publicdomain/zero/1.0//',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/publicdomain/zero/1.0/',
        },
        {
                             input_url: 'http://creativecommons.org/publicdomain/zero/1.0/legalcode',
                     input_entity_type: 'release',
            expected_relationship_type: 'license',
                    expected_clean_url: 'http://creativecommons.org/publicdomain/zero/1.0/',
        },
        // Decoda
        {
                             input_url: 'http://decoda.com/robi-on-ne-meurt-plus-damour-lyrics',
                     input_entity_type: 'work',
            expected_relationship_type: 'lyrics',
        },
        // Deezer
        {
                             input_url: 'http://www.deezer.com/artist/243332',
                     input_entity_type: 'artist',
            expected_relationship_type: 'streamingmusic',
        },
        {
                             input_url: 'http://www.deezer.com/artist/6509511?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'streamingmusic',
                    expected_clean_url: 'https://www.deezer.com/artist/6509511',
        },
        {
                             input_url: 'https://deezer.com/album/8935347',
                     input_entity_type: 'release',
            expected_relationship_type: 'streamingmusic',
                    expected_clean_url: 'https://www.deezer.com/album/8935347',
        },
        {
                             input_url: 'http://www.deezer.com/track/3437226',
                     input_entity_type: 'recording',
            expected_relationship_type: 'streamingmusic',
        },
        {
                             input_url: 'http://www.deezer.com/album/497382',
                     input_entity_type: 'release',
            expected_relationship_type: 'streamingmusic',
        },
        // DHHU
        {
                             input_url: 'http://www.dhhu.dk/w/%C3%98stkyst_Hustlers',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://dhhu.dk/w/Sort_Stue',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.dhhu.dk/w/Sort_Stue',
        },
        {
                             input_url: 'http://www.dhhu.dk/w/Jonny_Hefty_%26_Gratismixtape.dk_pr%C3%A6senterer_Actionspeax_-_Louder_Than_Words_Mixtape,_MP3/',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        // Discogs
        {
                             input_url: 'http://www.discogs.com/artist/301-Source-Direct',
                     input_entity_type: 'artist',
            expected_relationship_type: 'discogs',
        },
        {
                             input_url: 'http://www.discogs.com/artist/Source+Direct',
                     input_entity_type: 'artist',
            expected_relationship_type: 'discogs',
        },
        {
                             input_url: 'http://www.discogs.com/artist/1944002-',
                     input_entity_type: 'artist',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/artist/1944002',
        },
        {
                             input_url: 'http://www.discogs.com/artist/3080207-Maybebop',
                     input_entity_type: 'artist',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/artist/3080207',
        },
        {
                             input_url: 'http://www.discogs.com/artist/Guy+Balbaert#t=Credits_Writing-Arrangement&q=&p=1',
                     input_entity_type: 'artist',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/artist/Guy+Balbaert',
        },
        {
                             input_url: 'http://www.discogs.com/artist/Teresa+Teng?anv=%E9%84%A7%E9%BA%97%E5%90%9B',
                     input_entity_type: 'artist',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/artist/Teresa+Teng',
               only_valid_entity_types: ['artist', 'place']
        },
        {
                             input_url: 'http://www.discogs.com/label/2262-Demonic',
                     input_entity_type: 'label',
            expected_relationship_type: 'discogs',
        },
        {
                             input_url: 'http://www.discogs.com/label/Demonic',
                     input_entity_type: 'label',
            expected_relationship_type: 'discogs',
        },
        {
                             input_url: 'http://www.discogs.com/label/$&+,/:;=@[]%20%23%24%25%2B%2C%2F%3A%3B%3F%40',
                     input_entity_type: 'label',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/label/%24%26+%2C%2F%3A%3B%3D%40%5B%5D+%23%24%25%2B%2C%2F%3A%3B%3F%40',
               only_valid_entity_types: ['label', 'place', 'series']
        },
        {
                             input_url: 'http://www.discogs.com/release/12130',
                     input_entity_type: 'release',
            expected_relationship_type: 'discogs',
               only_valid_entity_types: ['release']
        },
        {
                             input_url: 'http://www.discogs.com/Source-Direct-Exorcise-The-Demons/master/126685',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'discogs',
        },
        {
                             input_url: 'http://www.discogs.com/master/view/267989',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/master/267989',
               only_valid_entity_types: ['release_group']
        },
        {
                             input_url: 'http://www.discogs.com/Various-Out-Patients-2/release/5578',
                     input_entity_type: 'release',
            expected_relationship_type: 'discogs',
                    expected_clean_url: 'http://www.discogs.com/release/5578',
        },
        // e-onkyo music
        {
                             input_url: 'http://www.e-onkyo.com/music/album/vpcd81809/',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // excite
        {
                             input_url: 'http://psgarden.exblog.jp/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'blog',
        },
        {
                             input_url: 'http://psgarden.exblog.jp/',
                     input_entity_type: 'label',
            expected_relationship_type: 'blog',
        },
        // Facebook
        {
                             input_url: 'http://www.facebook.com/pages/De_Tot_Cor/133207893384897/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://www.facebook.com/pages/De_Tot_Cor/133207893384897',
        },
        {
                             input_url: 'http://www.facebook.com/sininemusic',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://www.facebook.com/sininemusic',
        },
        {
                             input_url: 'https://www.facebook.com/RomanzMusic?fref=ts',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://www.facebook.com/RomanzMusic',
        },
        {
                             input_url: 'https://www.facebook.com/event.php?eid=129606980393356',
                     input_entity_type: 'event',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://www.facebook.com/events/129606980393356',
        },
        {
                             input_url: 'https://www.facebook.com/events/779218695457920/?ref=2&ref_dashboard_filter=past&sid_reminder=1385056373762424832',
                     input_entity_type: 'event',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://www.facebook.com/events/779218695457920',
        },
        // Finna.fi
        {
                             input_url: 'https://www.finna.fi/Record/viola.163990',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        // Flattr
        {
                             input_url: 'http://www.flattr.com/profile/example',
                     input_entity_type: 'label',
            expected_relationship_type: 'patronage',
                    expected_clean_url: 'https://flattr.com/profile/example',
        },
        // FolkWiki
        {
                             input_url: 'http://www.folkwiki.se/Personer/SvenDonat',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // Foursquare
        {
                             input_url: 'http://foursquare.com/taimmobile',
                     input_entity_type: 'place',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://foursquare.com/taimmobile',
        },
        {
                             input_url: 'http://foursquare.com/v/high-line/40f1d480f964a5206a0a1fe3',
                     input_entity_type: 'place',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://foursquare.com/v/high-line/40f1d480f964a5206a0a1fe3',
        },
        // generasia
        {
                             input_url: 'http://generasia.com/wiki/Wink',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.generasia.com/wiki/Wink',
        },
        {
                             input_url: 'http://www.generasia.com/wiki/Ai_ga_Tomaranai_~Turn_It_into_Love~',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'https://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
                     input_entity_type: 'work',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
        },
        // Genius
        {
                             input_url: 'http://genius.com/artists/Dramatik',
                     input_entity_type: 'artist',
            expected_relationship_type: 'lyrics',
                    expected_clean_url: 'http://genius.com/artists/Dramatik',
        },
        {
                             input_url: 'http://genius.com/albums/The-dream/Terius-nash-1977',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'lyrics',
                    expected_clean_url: 'http://genius.com/albums/The-dream/Terius-nash-1977',
        },
        {
                             input_url: 'http://rock.genius.com/The-beatles-she-loves-you-lyrics',
                     input_entity_type: 'work',
            expected_relationship_type: 'lyrics',
                    expected_clean_url: 'http://rock.genius.com/The-beatles-she-loves-you-lyrics',
        },
        // GeoNames
        {
                             input_url: 'http://www.geonames.org/6255147/asia.html',
                     input_entity_type: 'area',
            expected_relationship_type: 'geonames',
                    expected_clean_url: 'http://sws.geonames.org/6255147/',
        },
        // Google
        {
                             input_url: 'https://play.google.com/store/music/artist/Daylight?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://play.google.com/store/music/artist?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
        },
        {
                             input_url: 'http://play.google.com/store/music/artist?id=Aathd3z2apf2hbln4wgkrthmhqu',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://play.google.com/store/music/artist?id=Aathd3z2apf2hbln4wgkrthmhqu',
        },
        {
                             input_url: 'http://plus.google.com/u/0/101821796946045393834/about',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://plus.google.com/101821796946045393834',
        },
        {
                             input_url: 'https://play.google.com/store/music/artist/Julia_Haltigan_The_Hooligans?id=Avnwgjjbdf6la5zvdjf62k4jylq&hl=en',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://play.google.com/store/music/artist?id=Avnwgjjbdf6la5zvdjf62k4jylq',
        },
        {
                             input_url: 'https://play.google.com/store/music/album/Disasterpeace_The_Floor_is_Jelly_Original_Soundtra?id=Bxpxunylzxqoqiiostyvocjtuu4',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://play.google.com/store/music/album?id=Bxpxunylzxqoqiiostyvocjtuu4',
        },
        // (VICTOR STUDIO) HD-Music.
        {
                             input_url: 'http://hd-music.info/album.cgi/913',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // IMDb (Internet Movie Database)
        {
                             input_url: 'http://www.imdb.com/name/nm1539156/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'imdb',
        },
        {
                             input_url: 'http://www.imdb.com/company/co0109498/',
                     input_entity_type: 'label',
            expected_relationship_type: 'imdb',
        },
        {
                             input_url: 'http://www.imdb.com/title/tt0421082/',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'imdb',
        },
        // IMSLP (International Music Score Library Project)
        {
                             input_url: 'http://imslp.org/wiki/Category:Buxtehude%2C_Dietrich',
                     input_entity_type: 'artist',
            expected_relationship_type: 'imslp',
        },
        {
                             input_url: 'http://imslp.org/wiki/Die_Zauberfl%C3%B6te,_K.620_(Mozart,_Wolfgang_Amadeus)',
                     input_entity_type: 'work',
            expected_relationship_type: 'score',
        },
        // Indiegogo
        {
                             input_url: 'https://www.indiegogo.com/individuals/0123456789/campaigns',
                     input_entity_type: 'artist',
            expected_relationship_type: 'crowdfunding',
                    expected_clean_url: 'https://www.indiegogo.com/individuals/0123456789',
        },
        {
                             input_url: 'https://www.indiegogo.com/projects/common-example?locale=es#/',
                     input_entity_type: 'event',
            expected_relationship_type: 'crowdfunding',
                    expected_clean_url: 'https://www.indiegogo.com/projects/common-example',
        },
        // Instagram
        {
                             input_url: 'http://instagram.com/deadmau5',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
        },
        // (Apple) iTunes
        {
                             input_url: 'http://itunes.apple.com/artist/hangry-angry-f/id444923726',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/artist/id444923726',
        },
        {
                             input_url: 'http://itunes.apple.com/music-video/gangnam-style/id564322420?v0=WWW-NAUS-ITSTOP100-MUSICVIDEOS&ign-mpt=uo%3D2',
                     input_entity_type: 'recording',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/music-video/id564322420',
        },
        {
                             input_url: 'http://itunes.apple.com/au/preorder/the-last-of-the-tourists/id499465357',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/au/preorder/id499465357',
        },
        {
                             input_url: 'http://itunes.apple.com/gb/album/now-thats-what-i-call-music!-82/id543575947?v0=WWW-EUUK-STAPG-MUSIC-PROMO',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/gb/album/id543575947',
        },
        {
                             input_url: 'https://itunes.apple.com/album/beatbox-+-iphone-+-guitar/id589456329?ign-mpt=uo%3D4',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/album/id589456329',
        },
        {
                             input_url: 'https://itunes.apple.com/us/album/skyfall-single/id566322358',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/us/album/id566322358',
        },
        {
                             input_url: 'https://itunes.apple.com/us/album/timber-feat.-ke$ha-single/id721686178',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://itunes.apple.com/us/album/id721686178',
        },
        // Jamendo Music
        {
                             input_url: 'http://www.jamendo.com/en/track/725574/giraffe',
                     input_entity_type: 'recording',
            expected_relationship_type: 'downloadfree',
                    expected_clean_url: 'http://www.jamendo.com/track/725574',
        },
        {
                             input_url: 'http://www.jamendo.com/en/list/a84763/crossing-state-lines',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadfree',
                    expected_clean_url: 'http://www.jamendo.com/list/a84763',
        },
        {
                             input_url: 'http://www.jamendo.com/en/album/56372',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadfree',
                    expected_clean_url: 'http://www.jamendo.com/album/56372',
        },
        // JUGEM
        {
                             input_url: 'http://milk-pu-rin.jugem.jp/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'blog',
        },
        {
                             input_url: 'http://milk-pu-rin.jugem.jp/',
                     input_entity_type: 'label',
            expected_relationship_type: 'blog',
        },
        // Juno Download
        {
                             input_url: 'http://www.junodownload.com/products/caspa-subscape-geordie-racer-notixx-remix/2141988-02/',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // JVC Music
        {
                             input_url: 'http://www.jvcmusic.co.jp/-/Discography/A015120/VICC-60560.html',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Kickstarter
        {
                             input_url: 'https://www.kickstarter.com/profile/0123456789/bio',
                     input_entity_type: 'label',
            expected_relationship_type: 'crowdfunding',
                    expected_clean_url: 'https://www.kickstarter.com/profile/0123456789',
        },
        {
                             input_url: 'https://www.kickstarter.com/projects/0123456789/common-example#main-navigation',
                     input_entity_type: 'place',
            expected_relationship_type: 'crowdfunding',
                    expected_clean_url: 'https://www.kickstarter.com/projects/0123456789/common-example',
        },
        // KING RECORDS
        {
                             input_url: 'http://www.kingrecords.co.jp/cs/g/gKICM-1091/',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Lantis
        {
                             input_url: 'http://www.lantis.jp/release-item2.php?id=326c88aa1cd230f96ef350e380a23078',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Last.fm
        {
                             input_url: 'http://www.last.fm/music/Bj%C3%B6rk',
                     input_entity_type: 'artist',
            expected_relationship_type: 'lastfm',
        },
        {
                             input_url: 'http://www.last.fm/event/3291943+Pori+jazz',
                     input_entity_type: 'event',
            expected_relationship_type: 'lastfm',
        },
        {
                             input_url: 'http://www.lastfm.de/event/671822+Ruhrpott+rodeo+at+Flugplatz+Schwarze+Heide+on+27+June+2008',
                     input_entity_type: 'event',
            expected_relationship_type: 'lastfm',
                    expected_clean_url: 'http://www.last.fm/event/671822+Ruhrpott+rodeo+at+Flugplatz+Schwarze+Heide+on+27+June+2008',
        },
        {
                             input_url: 'http://www.lastfm.de/festival/297838+Death+Feast+2008',
                     input_entity_type: 'event',
            expected_relationship_type: 'lastfm',
                    expected_clean_url: 'http://www.last.fm/festival/297838+Death+Feast+2008',
        },
        {
                             input_url: 'http://userserve-ak.last.fm/serve/_/13629495/Lab+Beat+Lab_Beat_Logo_500.gif',
                    expected_clean_url: 'http://userserve-ak.last.fm/serve/_/13629495/Lab+Beat+Lab_Beat_Logo_500.gif',
        },
        {
                             input_url: 'http://www.lastfm.com.br/venue/8803923+Gigantinho',
                    expected_clean_url: 'http://www.last.fm/venue/8803923+Gigantinho',
        },
        {
                             input_url: 'http://www.lastfm.com/music/Carving+Colours',
                    expected_clean_url: 'http://www.last.fm/music/Carving+Colours',
        },
        // LiederNet Archive
        {
                             input_url: 'http://www.lieder.net/lieder/get_text.html?TextId=6448',
                     input_entity_type: 'work',
            expected_relationship_type: 'lyrics',
        },
        // LinkedIn
        {
                             input_url: 'http://www.linkedin.com/pub/trevor-muzzy/5/282/538',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
        },
        {
                             input_url: 'http://www.linkedin.com/in/legselectric',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://www.linkedin.com/in/legselectric',
        },
        // livedoor
        {
                             input_url: 'http://blog.livedoor.jp/mintmania/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'blog',
        },
        {
                             input_url: 'http://blog.livedoor.jp/mintmania/',
                     input_entity_type: 'label',
            expected_relationship_type: 'blog',
        },
        // Loudr
        {
                             input_url: 'https://loudr.fm/artist/kyle-landry/Z77SM?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://loudr.fm/artist/kyle-landry/Z77SM',
        },
        {
                             input_url: 'http://loudr.fm/release/dearly-beloved-2014/Vv2cZ',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'https://loudr.fm/release/dearly-beloved-2014/Vv2cZ',
        },
        // LYRICSnMUSIC
        {
                             input_url: 'http://www.lyricsnmusic.com/david-hasselhoff/white-christmas-lyrics/27952232',
                     input_entity_type: 'work',
            expected_relationship_type: 'lyrics',
        },
        // Mainly Norfolk
        {
                             input_url: 'http://mainlynorfolk.info/martin.carthy/records/themoraloftheelephant.html',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        // (The) Metal Archives
        {
                             input_url: 'http://www.metal-archives.com/bands/Karna/26483',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://www.metal-archives.com/albums/Corubo/Ypykuera/193860',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://www.metal-archives.com/reviews/Myrkwid/Part_I/36375/',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'review',
        },
        // mora
        {
                             input_url: 'http://mora.jp/package/43000001/4534530058010/',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        {
                             input_url: 'http://mora.jp/package/43000014/KIZC-211/',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        {
                             input_url: 'http://mora.jp/package/43000021/SQEX-20016_F/#',
                    expected_clean_url: 'http://mora.jp/package/43000021/SQEX-20016_F/',
        },
        {
                             input_url: 'https://www.mora.jp/package/43000002/ANTCD-3106?test',
                    expected_clean_url: 'http://mora.jp/package/43000002/ANTCD-3106/',
        },
        {
                             input_url: 'mora.jp/package/43000002/ANTCD-3106/',
                    expected_clean_url: 'http://mora.jp/package/43000002/ANTCD-3106/',
        },
        // MusicMoz
        {
                             input_url: 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://musicmoz.org/Bands_and_Artists/S/Soundgarden/Discography/Superunknown/',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        // Musik-Sammler.de
        {
                             input_url: 'http://www.musik-sammler.de/artist/100743',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://www.musik-sammler.de/artist/end-of-a-year/#',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'https://www.musik-sammler.de/artist/end-of-a-year/',
        },
        {
                             input_url: 'https://musik-sammler.de/artist/100743?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'https://www.musik-sammler.de/artist/100743/',
        },
        {
                             input_url: 'http://www.musik-sammler.de/media/594158',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://www.musik-sammler.de/album/364515',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'https://www.musik-sammler.de/album/804508/review/rain/',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'https://www.musik-sammler.de/album/804508/',
        },
        {
                             input_url: 'musik-sammler.de/media/594158',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'https://www.musik-sammler.de/media/594158/',
        },
        // mvdbase.com (The Music Video DataBase)
        {
                             input_url: 'http://www.mvdbase.com/video.php?id=4',
                     input_entity_type: 'recording',
            expected_relationship_type: 'otherdatabases',
        },
        // Myspace
        {
                             input_url: 'https://myspace.com/instramentaluk',
                     input_entity_type: 'artist',
            expected_relationship_type: 'myspace',
        },
        {
                             input_url: 'http://fr.myspace.com/jujusasadada',
                     input_entity_type: 'artist',
            expected_relationship_type: 'myspace',
                    expected_clean_url: 'https://myspace.com/jujusasadada',
        },
        {
                             input_url: 'http://myspace.de/diekisten',
                     input_entity_type: 'artist',
            expected_relationship_type: 'myspace',
                    expected_clean_url: 'https://myspace.com/diekisten',
        },
        {
                             input_url: 'http://www.myspace.com/whoevenusesthisanymore',
                     input_entity_type: 'label',
            expected_relationship_type: 'myspace',
                    expected_clean_url: 'https://myspace.com/whoevenusesthisanymore',
        },
        // Naxos Records
        {
                             input_url: 'http://www.naxos.com/catalogue/item.asp?item_code=8.553162',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Ney Nota Arşivi 
        {
                             input_url: 'http://www.neyzen.com/nota_arsivi/02_klasik_eserler/054_mahur_buselik/mahur_buselik_ss_aydin_oran.pdf',
                     input_entity_type: 'work',
            expected_relationship_type: 'score',
        },
        // NLA (National Library of Australia)
        {
                             input_url: 'https://nla.gov.au/nla.party-548358/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://nla.gov.au/nla.party-548358',
        },
        {
                             input_url: 'http://trove.nla.gov.au/people/1448035?c=people',
                     input_entity_type: 'label',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://nla.gov.au/nla.party-1448035',
        },
        {
                             input_url: 'http://nla.gov.au/anbd.bib-an11701020#',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://nla.gov.au/anbd.bib-an11701020',
        },
        {
                             input_url: 'trove.nla.gov.au/work/9438679',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://trove.nla.gov.au/work/9438679',
        },
        // Open Library
        {
                             input_url: 'http://openlibrary.org/authors/OL23919A/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://openlibrary.org/books/OL8993487M/Harry_Potter_and_the_Philosopher\'s_Stone',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://openlibrary.org/books/OL8993487M/',
        },
        {
                             input_url: 'http://openlibrary.org/works/OL82592W/',
                     input_entity_type: 'work',
            expected_relationship_type: 'otherdatabases',
        },
        // OPERADIS Operatic Discography
        {
                             input_url: 'http://www.operadis-opera-discography.org.uk/CLBABLUE.HTM',
                     input_entity_type: 'work',
            expected_relationship_type: 'otherdatabases',
        },
        // OTOTOY
        {
                             input_url: 'http://ototoy.jp/_/default/p/45622',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
        },
        // Patreon
        {
                             input_url: 'https://patreon.com/example#reactTargetCreatorPage',
                     input_entity_type: 'place',
            expected_relationship_type: 'patronage',
                    expected_clean_url: 'https://www.patreon.com/example',
        },
        // PayPal.Me
        {
                             input_url: 'https://paypal.me/example',
                     input_entity_type: 'series',
            expected_relationship_type: 'patronage',
        },
        {
                             input_url: 'https://www.paypal.me/example?q=test',
                    expected_clean_url: 'https://www.paypal.me/example',
        },
        // PureVolume
        {
                             input_url: 'http://www.purevolume.com/withbloodcomescleansing',
                     input_entity_type: 'artist',
            expected_relationship_type: 'purevolume',
        },
        // QIM (Québec Info Musique)
        {
                             input_url: 'http://www.qim.com/artistes/biographie.asp?artistid=47',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // RecoChoku
        {
                             input_url: 'recochoku.jp/song/S21893898/',
                     input_entity_type: 'recording',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'http://recochoku.jp/song/S21893898/',
        },
        {
                             input_url: 'https://www.recochoku.jp/album/30282664?test',
                     input_entity_type: 'release',
            expected_relationship_type: 'downloadpurchase',
                    expected_clean_url: 'http://recochoku.jp/album/30282664/',
        },
        // Resident Advisor (RA)
        {
                             input_url: 'https://www.residentadvisor.net/dj/adamx',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'https://www.residentadvisor.net/event.aspx?860109',
                     input_entity_type: 'event',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'https://www.residentadvisor.net/record-label.aspx?id=2795',
                     input_entity_type: 'label',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'https://www.residentadvisor.net/track.aspx?544258',
                     input_entity_type: 'recording',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'https://www.residentadvisor.net/reviews/7636',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'review',
               input_relationship_type: 'otherdatabases',
               only_valid_entity_types: []
        },
        // ReverbNation
        {
                             input_url: 'http://reverbnation.com/negator',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'http://www.reverbnation.com/negator',
        },
        {
                             input_url: 'http://www.reverbnation.com/#!/benwebbmusic',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'http://www.reverbnation.com/benwebbmusic',
        },
        {
                             input_url: 'https://www.reverbnation.com/littlesparrow',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'http://www.reverbnation.com/littlesparrow',
        },
        {
                             input_url: 'http://m.reverbnation.com/venue/602562',
                     input_entity_type: 'place',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'http://www.reverbnation.com/venue/602562',
        },
        // Rockens Danmarkskort
        {
                             input_url: 'http://www.rockensdanmarkskort.dk/steder/den-gr%C3%A5-hal',
                     input_entity_type: 'place',
            expected_relationship_type: 'otherdatabases',
        },
        // Rock in China
        {
                             input_url: 'http://wiki.rockinchina.com/w/Beyond_Cure_(TW)',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.rockinchina.com/w/Beyond_Cure_(TW)',
        },
        // Rockipedia
        {
                             input_url: 'https://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/',
        },
        {
                             input_url: 'http://www.rockipedia.no/plateselskap/universal_music-1719/',
                     input_entity_type: 'label',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://www.rockipedia.no/utgivelser/hunting_high_and_low_-_remastered_and_ex-7991/',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        // SecondHandSongs
        {
                             input_url: 'http://www.secondhandsongs.com/artist/103',
                     input_entity_type: 'artist',
            expected_relationship_type: 'secondhandsongs',
               only_valid_entity_types: ['artist']
        },
        {
                             input_url: 'http://www.secondhandsongs.com/release/888',
                     input_entity_type: 'release',
            expected_relationship_type: 'secondhandsongs',
               only_valid_entity_types: ['release']
        },
        {
                             input_url: 'http://www.secondhandsongs.com/work/1409',
                     input_entity_type: 'work',
            expected_relationship_type: 'secondhandsongs',
               only_valid_entity_types: ['work']
        },
        // setlist.fm
        {
                             input_url: 'http://www.setlist.fm/setlists/foo-fighters-bd6893a.html',
                     input_entity_type: 'artist',
            expected_relationship_type: 'setlistfm',
               only_valid_entity_types: ['artist']
        },
        {
                             input_url: 'http://www.setlist.fm/setlist/foo-fighters/2014/house-of-blues-new-orleans-la-13cda5b1.html',
                     input_entity_type: 'event',
            expected_relationship_type: 'setlistfm',
               only_valid_entity_types: ['event']
        },
        {
                             input_url: 'http://www.setlist.fm/venue/house-of-blues-new-orleans-la-usa-23d61c9f.html',
                     input_entity_type: 'place',
            expected_relationship_type: 'setlistfm',
               only_valid_entity_types: ['place']
        },
        // (SMDB) Svensk mediedatabas
        {
                             input_url: 'http://smdb.kb.se/catalog/id/001508972',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
        },
        // Songkick
        {
                             input_url: 'http://www.songkick.com/festivals/74586-ruhrpott-rodeo/id/19803209-ruhrpott-rodeo-festival-2014',
                     input_entity_type: 'event',
            expected_relationship_type: 'songkick',
                    expected_clean_url: 'https://www.songkick.com/festivals/74586-ruhrpott-rodeo/id/19803209-ruhrpott-rodeo-festival-2014',
               only_valid_entity_types: ['event', 'place']
        },
        {
                             input_url: 'http://www.songkick.com/venues/1141041-flugplatz-schwarze-heide',
                     input_entity_type: 'place',
            expected_relationship_type: 'songkick',
                    expected_clean_url: 'https://www.songkick.com/venues/1141041-flugplatz-schwarze-heide',
               only_valid_entity_types: ['place']
        },
        // SoundCloud
        {
                             input_url: 'https://soundcloud.com/metro-luminal',
                     input_entity_type: 'artist',
            expected_relationship_type: 'soundcloud',
        },
        {
                             input_url: 'http://m.soundcloud.com/octobersveryown',
                     input_entity_type: 'artist',
            expected_relationship_type: 'soundcloud',
                    expected_clean_url: 'https://soundcloud.com/octobersveryown',
        },
        {
                             input_url: 'http://soundcloud.com/alec_empire',
                     input_entity_type: 'artist',
            expected_relationship_type: 'soundcloud',
                    expected_clean_url: 'https://soundcloud.com/alec_empire',
        },
        {
                             input_url: 'https://soundcloud.com/alisonwonderland%E2%80%8E',
                     input_entity_type: 'artist',
            expected_relationship_type: 'soundcloud',
                    expected_clean_url: 'https://soundcloud.com/alisonwonderland',
        },
        {
                             input_url: 'https://soundcloud.com/dimmakrecords',
                     input_entity_type: 'label',
            expected_relationship_type: 'soundcloud',
        },
        {
                             input_url: 'https://soundcloud.com/glastonburyofficial',
                     input_entity_type: 'series',
            expected_relationship_type: 'soundcloud',
               only_valid_entity_types: ['artist', 'label', 'series']
        },
        {
                             input_url: 'https://soundcloud.com/tags/bug',
               input_relationship_type: 'soundcloud',
               only_valid_entity_types: []
        },
        {
                             input_url: 'https://soundcloud.com/search?q=some%20bug',
               input_relationship_type: 'soundcloud',
               only_valid_entity_types: []
        },
        // SoundtrackCollector
        {
                             input_url: 'http://soundtrackcollector.com/composer/94/Hans+Zimmer',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://soundtrackcollector.com/composer/94/',
        },
        {
                             input_url: 'http://www.soundtrackcollector.com/catalog/composerdiscography.php?composerid=94',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://soundtrackcollector.com/composer/94/',
               only_valid_entity_types: ['artist']
        },
        {
                             input_url: 'http://soundtrackcollector.com/title/5751/Jurassic+Park',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
        },
        {
                             input_url: 'http://www.soundtrackcollector.com/title/39473/Pledge%2C+The',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://soundtrackcollector.com/title/39473/',
        },
        {
                             input_url: 'https://www.soundtrackcollector.com/catalog/soundtrackdetail.php?movieid=99711',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://soundtrackcollector.com/title/99711/',
               only_valid_entity_types: ['release_group']
        },
        // Spirit of Rock
        {
                             input_url: 'http://www.spirit-of-rock.com/groupe-groupe-Explosions_In_The_Sky-l-en.html',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // Spotify
        {
                             input_url: 'https://embed.spotify.com/?uri=spotify:track:7gwRSZ0EmGWa697ZrE58GA',
                     input_entity_type: 'recording',
            expected_relationship_type: 'streamingmusic',
                    expected_clean_url: 'http://open.spotify.com/track/7gwRSZ0EmGWa697ZrE58GA',
        },
        // Ted Crane
        {
                             input_url: 'http://tedcrane.com/DanceDB/DisplayIdent.com?key=DONNA_HUNT',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // The Dance Gypsy
        {
                             input_url: 'http://www.thedancegypsy.com/performerList.php?musician=George+Marshall',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // The Session
        {
                             input_url: 'http://thesession.org/recordings/artists/793?test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://thesession.org/recordings/artists/793',
               only_valid_entity_types: ['artist']
        },
        {
                             input_url: 'http://thesession.org/members/01234',
                     input_entity_type: 'artist',
            expected_relationship_type: undefined,
               input_relationship_type: 'otherdatabases',
               only_valid_entity_types: []
        },
        {
                             input_url: 'thesession.org/events/3811#comment748363',
                     input_entity_type: 'event',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://thesession.org/events/3811',
               only_valid_entity_types: ['event']
        },
        {
                             input_url: 'https://www.thesession.org/recordings/display/1488',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://thesession.org/recordings/1488',
        },
        {
                             input_url: 'http://thesession.org/recordings/4740/edit',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://thesession.org/recordings/4740',
               only_valid_entity_types: ['release_group']
        },
        {
                             input_url: 'http://www.thesession.org/tunes/display/2305',
                     input_entity_type: 'work',
            expected_relationship_type: 'otherdatabases',
                    expected_clean_url: 'http://thesession.org/tunes/2305',
               only_valid_entity_types: ['work']
        },
        // Tipeee
        {
                             input_url: 'https://www.tipeee.com/example/news',
                     input_entity_type: 'artist',
            expected_relationship_type: 'patronage',
                    expected_clean_url: 'https://www.tipeee.com/example',
        },
        // triple j Unearthed
        {
                             input_url: 'https://www.triplejunearthed.com/artist/sampa-great',
                     input_entity_type: 'artist',
            expected_relationship_type: 'otherdatabases',
        },
        // Tumblr
        {
                             input_url: 'http://deadmau5.tumblr.com/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'blog',
        },
        // TuneArch (TTA) Traditional Tune Archive
        {
                             input_url: 'http://tunearch.org/wiki/Lovely_Lass_to_a_Friar_Came_(2)_(A)',
                     input_entity_type: 'work',
            expected_relationship_type: 'otherdatabases',
        },
        // Twitter
        {
                             input_url: 'http://twitter.com/miguelgrimaldo',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/miguelgrimaldo',
        },
        {
                             input_url: 'http://twitter.com/ACEHOOD/',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/ACEHOOD',
        },
        {
                             input_url: 'http://twitter.com/miguelgrimaldo/media',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/miguelgrimaldo',
        },
        {
                             input_url: 'https://mobile.twitter.com/cirrhaniva',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/cirrhaniva',
        },
        {
                             input_url: 'https://mobile.twitter.com/cirrhaniva?lang=en-gb',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/cirrhaniva',
        },
        {
                             input_url: 'https://twitter.com/@UNIVERSAL_D',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/UNIVERSAL_D',
        },
        {
                             input_url: 'https://twitter.com/@UNIVERSAL_D#content-main-heading',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'https://twitter.com/UNIVERSAL_D',
        },
        // Universal Music
        {
                             input_url: 'http://www.universal-music.co.jp/sweety/products/umca-59007/',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // Utamap
        {
                             input_url: 'http://www.utamap.com/showkasi.php?surl=34985',
                     input_entity_type: 'work',
            expected_relationship_type: 'lyrics',
        },
        // VGMDb
        {
                             input_url: 'http://vgmdb.com/org/284',
                     input_entity_type: 'artist',
            expected_relationship_type: 'vgmdb',
        },
        {
                             input_url: 'http://vgmdb.com/org/284',
                     input_entity_type: 'label',
            expected_relationship_type: 'vgmdb',
        },
        // VGMDb (Video Game Music and Anime Soundtrack Database)
        {
                             input_url: 'https://vgmdb.net/artist/431',
                     input_entity_type: 'artist',
            expected_relationship_type: 'vgmdb',
                    expected_clean_url: 'http://vgmdb.net/artist/431',
        },
        {
                             input_url: 'https://vgmdb.com/org/284',
                     input_entity_type: 'label',
            expected_relationship_type: 'vgmdb',
                    expected_clean_url: 'http://vgmdb.net/org/284',
        },
        {
                             input_url: 'vgmdb.net/album/29727',
                     input_entity_type: 'release',
            expected_relationship_type: 'vgmdb',
                    expected_clean_url: 'http://vgmdb.net/album/29727',
        },
        // VIAF (Virtual International Authority File)
        {
                             input_url: 'http://viaf.org/viaf/109231256',
                     input_entity_type: 'artist',
            expected_relationship_type: 'viaf',
        },
        {
                             input_url: 'http://viaf.org/viaf/152662182',
                     input_entity_type: 'label',
            expected_relationship_type: 'viaf',
        },
        {
                             input_url: 'http://viaf.org/viaf/185694157',
                     input_entity_type: 'work',
            expected_relationship_type: 'viaf',
        },
        {
                             input_url: 'http://viaf.org/viaf/16766997',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        {
                             input_url: 'http://viaf.org/viaf/16766997/',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        {
                             input_url: 'http://viaf.org/viaf/16766997/?test=true',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        {
                             input_url: 'http://viaf.org/viaf/16766997/#Rovics,_David',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        {
                             input_url: 'http://viaf.org/viaf/32197206/#Mozart,_Wolfgang_Amadeus,_1756-1791',
                    expected_clean_url: 'http://viaf.org/viaf/32197206',
        },
        {
                             input_url: 'https://www.viaf.org/viaf/16766997?test=1#Rovics,_David',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        {
                             input_url: 'viaf.org/viaf/16766997/',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        {
                             input_url: 'www.viaf.org/viaf/16766997/',
                    expected_clean_url: 'http://viaf.org/viaf/16766997',
        },
        // Videogam.in
        {
                             input_url: 'http://videogam.in/music/?id=PCCG-00486',
                     input_entity_type: 'release',
            expected_relationship_type: 'otherdatabases',
        },
        // Vimeo
        {
                             input_url: 'http://www.vimeo.com/1109226?pg=embed&sec=1109226',
                     input_entity_type: 'recording',
            expected_relationship_type: 'streamingmusic',
                    expected_clean_url: 'http://vimeo.com/1109226',
        },
        // Vine
        {
                             input_url: 'https://vine.co/destorm',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
        },
        // VKontakte 
        {
                             input_url: 'http://vk.com/tin_sontsya',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
        },
        // Weibo 
        {
                             input_url: 'www.weibo.com/mchotdog2010#test',
                     input_entity_type: 'artist',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'http://www.weibo.com/mchotdog2010',
        },
        {
                             input_url: 'https://weibo.com/mchotdog2010?test',
                     input_entity_type: 'label',
            expected_relationship_type: 'socialnetwork',
                    expected_clean_url: 'http://www.weibo.com/mchotdog2010',
        },
        // WhoSampled
        {
                             input_url: 'http://www.whosampled.com/Just-to-Get-a-Rep/Gang-Starr/',
                     input_entity_type: 'recording',
            expected_relationship_type: 'otherdatabases',
        },
        // Wikia
        {
                             input_url: 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'lyrics',
        },
        // Wikidata
        {
                             input_url: 'https://www.wikidata.org/wiki/Q42',
                     input_entity_type: 'artist',
            expected_relationship_type: 'wikidata',
                    expected_clean_url: 'https://www.wikidata.org/wiki/Q42',
        },
        {
                             input_url: 'https://www.wikidata.org/wiki/Q42',
                     input_entity_type: 'label',
            expected_relationship_type: 'wikidata',
        },
        {
                             input_url: 'https://www.wikidata.org/wiki/Q42',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'wikidata',
        },
        {
                             input_url: 'https://www.wikidata.org/wiki/Q42',
                     input_entity_type: 'work',
            expected_relationship_type: 'wikidata',
        },
        {
                             input_url: 'http://www.wikidata.org/wiki/Q14005#sitelinks-wikipedia',
                    expected_clean_url: 'https://www.wikidata.org/wiki/Q14005',
        },
        // Wikimedia Commons
        {
                             input_url: 'https://commons.wikimedia.org/wiki/File:NIN2008.jpg',
                     input_entity_type: 'artist',
            expected_relationship_type: 'image',
        },
        {
                             input_url: 'https://commons.wikimedia.org/wiki/File:EMI_Records.svg',
                     input_entity_type: 'label',
            expected_relationship_type: 'image',
        },
        {
                             input_url: 'http://commons.wikimedia.org/wiki/File:Kimigayo.score.png?uselang=de',
                     input_entity_type: 'work',
            expected_relationship_type: 'score',
                    expected_clean_url: 'https://commons.wikimedia.org/wiki/File:Kimigayo.score.png',
        },
        {
                             input_url: 'http://commons.wikimedia.org/wiki/Main_Page#mediaviewer/File:Origanum_vulgare_-_harilik_pune.jpg',
                    expected_clean_url: 'https://commons.wikimedia.org/wiki/File:Origanum_vulgare_-_harilik_pune.jpg',
        },
        // Wikipedia
        {
                             input_url: 'http://en.wikipedia.org/wiki/Source_Direct_%28band%29',
                     input_entity_type: 'artist',
            expected_relationship_type: 'wikipedia',
        },
        {
                             input_url: 'http://en.wikipedia.org/wiki/Astralwerks',
                     input_entity_type: 'label',
            expected_relationship_type: 'wikipedia',
        },
        {
                             input_url: 'https://en.wikipedia.org/wiki/$&+,/:;=@[]%20%23%24%25%2B%2C%2F%3A%3B%3F%40',
                     input_entity_type: 'label',
            expected_relationship_type: 'wikipedia',
                    expected_clean_url: 'https://en.wikipedia.org/wiki/$%26%2B,/:;%3D@%5B%5D_%23$%25%2B,/:;%3F@',
        },
        {
                             input_url: 'https://en.wikipedia.org/wiki/Exorcise_the_Demons',
                     input_entity_type: 'release_group',
            expected_relationship_type: 'wikipedia',
        },
        {
                             input_url: 'http://en.wikipedia.org/wiki/Ramesh_Vinayakam?oldformat=true',
                    expected_clean_url: 'https://en.wikipedia.org/wiki/Ramesh_Vinayakam',
        },
        {
                             input_url: 'http://wikipedia.org/wiki/Oberhofer',
                    expected_clean_url: 'https://en.wikipedia.org/wiki/Oberhofer',
        },
        {
                             input_url: 'https://sv.m.wikipedia.org/wiki/Bullet',
                    expected_clean_url: 'https://sv.wikipedia.org/wiki/Bullet',
        },
        {
                             input_url: 'it.wikipedia.org/wiki/Foo',
                    expected_clean_url: 'https://it.wikipedia.org/wiki/Foo',
        },
        // Wikisource
        {
                             input_url: 'https://pt.wikisource.org/wiki/A_Portuguesa',
                     input_entity_type: 'work',
            expected_relationship_type: 'lyrics',
                    expected_clean_url: 'http://pt.wikisource.org/wiki/A_Portuguesa',
        },
        // Warner Music
        {
                             input_url: 'http://wmg.jp/artist/ayaka/WPCL000010415.html',
                     input_entity_type: 'release',
            expected_relationship_type: 'discographyentry',
        },
        // YouTube
        {
                             input_url: 'http://youtube.com/user/officialpsy/videos',
                     input_entity_type: 'artist',
            expected_relationship_type: 'youtube',
                    expected_clean_url: 'http://www.youtube.com/user/officialpsy',
        },
        {
                             input_url: 'http://m.youtube.com/#/user/JessVincentMusic',
                     input_entity_type: 'artist',
            expected_relationship_type: 'youtube',
                    expected_clean_url: 'http://www.youtube.com/user/JessVincentMusic',
        },
        {
                             input_url: 'https://www.youtube.com/user/JessVincentMusic?feature=watch',
                     input_entity_type: 'artist',
            expected_relationship_type: 'youtube',
                    expected_clean_url: 'http://www.youtube.com/user/JessVincentMusic',
        },
        {
                             input_url: 'http://www.youtube.com/embed/UmHdefsaL6I',
                     input_entity_type: 'recording',
            expected_relationship_type: 'streamingmusic',
                    expected_clean_url: 'http://www.youtube.com/watch?v=UmHdefsaL6I',
        },
        {
                             input_url: 'http://youtube.com/user/officialpsy/videos',
                     input_entity_type: 'label',
            expected_relationship_type: 'youtube',
        },
        {
                             input_url: 'http://youtu.be/UmHdefsaL6I',
                     input_entity_type: 'recording',
            expected_relationship_type: 'streamingmusic',
                    expected_clean_url: 'http://www.youtube.com/watch?v=UmHdefsaL6I',
        },
    ];

    const relationship_types_by_uuid = _.reduce(LINK_TYPES, function(results, rel_uuid_by_entity_type, relationship_type) {
        _.each(rel_uuid_by_entity_type, function(rel_uuid) {
            (results[rel_uuid] || (results[rel_uuid] = [])).push(relationship_type);
        });
        return results;
    }, {});

    var previous_match_tests = [];

    function doMatchSubtest(st, entity_type, url, label, expected_relationship_type) {
        var rel_uuid = guessType(entity_type, url);
        var actual_relationship_type = _.find(relationship_types_by_uuid[rel_uuid], function (s) {return s === expected_relationship_type;});
        st.equal(actual_relationship_type, expected_relationship_type, 'Match ' + label + ' URL relationship type for ' + entity_type + ' entities');
        previous_match_tests.push(entity_type + '+' + url);
    }

    _.each(test_data, function (subtest, i) {
        t.test('input URL [' + i + '] = ' + subtest.input_url, {}, function(st) {
            var tested = false;
            if (!subtest.input_url) {
                st.fail('Test is invalid: "input_url" is missing: ' + JSON.stringify(subtest));
                st.end();
                return;
            }
            if (subtest.input_entity_type) {
                if (subtest.hasOwnProperty('expected_relationship_type')) {
                    if (previous_match_tests.indexOf(subtest.input_entity_type + '+' + subtest.input_url) !== -1) {
                        st.fail('Match test is worthless: Duplication has been detected: ' + JSON.stringify(subtest));
                    }
                    doMatchSubtest(st, subtest.input_entity_type, subtest.input_url, 'input', subtest.expected_relationship_type);
                    tested = true;
                } else {
                    st.fail('Test is invalid: "input_entity_type" is specified without "expected_relationship_type".');
                    st.end();
                    return;
                }
            } else if (subtest.hasOwnProperty('expected_relationship_type')) {
                st.fail('Test is invalid: "expected_relationship_type" is specified without "input_entity_type".');
                st.end();
                return;
            }
            var actual_clean_url = cleanURL(subtest.input_url);
            if (subtest.expected_clean_url) {
                st.equal(actual_clean_url, subtest.expected_clean_url, 'Clean up');
                if (subtest.input_entity_type && subtest.hasOwnProperty('expected_relationship_type')
                        && previous_match_tests.indexOf(subtest.input_entity_type + '+' + subtest.expected_clean_url) === -1) {
                    doMatchSubtest(st, subtest.input_entity_type, subtest.expected_clean_url, 'clean', subtest.expected_relationship_type);
                }
                tested = true;
            }
            if (subtest.input_relationship_type && !subtest.only_valid_entity_types) {
                st.fail('Test is invalid: "input_relationship_type" is specified without "only_valid_entity_types" array.');
                st.end();
                return;
            }
            if (subtest.only_valid_entity_types) {
                var relationship_type = subtest.input_relationship_type || subtest.expected_relationship_type;
                var clean_url = subtest.expected_clean_url || actual_clean_url;
                if (!relationship_type) {
                    st.fail('Test is invalid: "only_valid_entity_types" are specified with neither "expected_relationship_type" nor "input_relationship_type".');
                    st.end();
                    return;
                }
                var nb_tested_rules = 0;
                var validation_results = _.reduce(LINK_TYPES[relationship_type], function(results, rel_uuid, entity_type) {
                    var rule = validationRules[rel_uuid];
                    var is_valid = rule ? rule(clean_url) || false : true;
                    results[is_valid].splice(_.sortedIndex(results[is_valid], entity_type), 0, entity_type);
                    nb_tested_rules += rule ? 1 : 0;
                    return results;
                }, {true: [], false: []});
                if (nb_tested_rules === 0) {
                    st.fail('Validation test is worthless: No validation rule has been actually tested.');
                } else {
                    st.deepEqual(validation_results.true, subtest.only_valid_entity_types.sort(),
                            'Validate clean URL by exactly ' + subtest.only_valid_entity_types.length
                            + ' among ' + nb_tested_rules + ' ' + relationship_type + '.* rules');
                    tested = true;
                }
            }
            if (!tested) {
                st.fail('Test is worthless: Nothing has been actually tested.');
            }
            st.end();
        });
    });

    t.end();
});
