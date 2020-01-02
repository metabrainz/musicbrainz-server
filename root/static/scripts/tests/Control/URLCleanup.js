/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';
import _ from 'lodash';

import {LINK_TYPES, cleanURL, guessType, validationRules} from '../../edit/URLCleanup';

/* eslint-disable indent, max-len, sort-keys */
const testData = [
  // 45cat
  {
                     input_url: 'https://www.45cat.com/artist/edwin-starr',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45cat.com/artist/edwin-starr',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.45cat.com/label/eastwest/all',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45cat.com/label/eastwest',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://45cat.com/record/vs1370&rc=365077#365077',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45cat.com/record/vs1370',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45cat.com/45_composer.php?tc=Floyd+Hunt',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  // 45worlds
  {
                     input_url: 'http://www.45worlds.com/78rpm/artist/yehudi-menuhin',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/78rpm/artist/yehudi-menuhin',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://45worlds.com/classical/artist/yehudi-menuhin',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/classical/artist/yehudi-menuhin',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.45worlds.com/classical/soloist/yehudi-menuhin',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/classical/soloist/yehudi-menuhin',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.45worlds.com/live/listing/rumer-fawcetts-field-2012&rc=186697#186697',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/live/listing/rumer-fawcetts-field-2012',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'http://www.45worlds.com/tape/label/parlophone/all',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/tape/label/parlophone',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://www.45worlds.com/live/venue/stadium-high-school-stadium',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/live/venue/stadium-high-school-stadium',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'http://www.45worlds.com/vinyl/album/mfsl1100',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/vinyl/album/mfsl1100',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45worlds.com/12single/record/fu2t',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/12single/record/fu2t',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45worlds.com/cdsingle/cd/pwcd227',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/cdsingle/cd/pwcd227',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45worlds.com/classical/music/asd264',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.45worlds.com/classical/music/asd264',
       only_valid_entity_types: ['release_group'],
  },
  // 7digital (zdigital)
  {
                     input_url: 'http://es.7digital.com/artist/the-impatient-sisters',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://es.7digital.com/artist/the-impatient-sisters',
  },
  {
                     input_url: 'http://www.7digital.com/artist/the-impatient-sisters',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.7digital.com/artist/the-impatient-sisters',
  },
  {
                     input_url: 'http://www.zdigital.com.au/artist/the-impatient-sisters',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.zdigital.com.au/artist/the-impatient-sisters',
  },
  {
                     input_url: 'http://fr-ca.7digital.com/artist/the-impatient-sisters',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://fr-ca.7digital.com/artist/the-impatient-sisters',

  },
  {
                     input_url: 'http://www.7digital.com/artist/el-p/release/cancer-4-cure-1',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.7digital.com/artist/el-p/release/cancer-4-cure-1',
  },
  {
                     input_url: 'https://us.7digital.com/yourmusic/artist/falco/release/vienna-greatest-hits-311837/311837',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://us.7digital.com/artist/falco/release/vienna-greatest-hits-311837',
  },
  // AllMusic
  {
                     input_url: 'https://www.allmusic.com/artist/the-beatles-mn0000754032/credits',
             input_entity_type: 'artist',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/artist/mn0000754032',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.allmusic.com/performance/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mq0000061129/credits',
             input_entity_type: 'recording',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/performance/mq0000061129',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://www.allmusic.com/album/here-comes-the-sun-mw0002303439/releases',
             input_entity_type: 'release_group',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/album/mw0002303439',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.allmusic.com/composition/le-nozze-di-figaro-the-marriage-of-figaro-opera-k-492-mc0002367338',
             input_entity_type: 'work',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/composition/mc0002367338',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'http://www.allmusic.com/song/help!-mt0043064796',
             input_entity_type: 'work',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/song/mt0043064796',
       only_valid_entity_types: ['work'],
  },
  // Amazon
  {
                     input_url: 'http://www.amazon.co.uk/gp/product/B00005JIWP',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.co.uk/gp/product/B00005JIWP',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://amazon.com.br/dp/B00T8E47G2',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.com.br/gp/product/B00T8E47G2',
  },
  {
                     input_url: 'http://www.amazon.in/dp/B006H1JVW4',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.in/gp/product/B006H1JVW4',
  },
  {
                     input_url: 'http://amzn.com/B000005SU4',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.com/gp/product/B000005SU4',
  },
  {
                     input_url: 'http://www.amazon.co.jp/dp/tracks/B000Y3JG8U#disc_1',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.co.jp/gp/product/B000Y3JG8U',
  },
  {
                     input_url: 'http://www.amazon.co.uk/IMPOSSIBLE/dp/B00008CQP2/ref=sr_1_1?ie=UTF8&qid=1344584322&sr=8-1',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.co.uk/gp/product/B00008CQP2',
  },
  {
                     input_url: 'http://www.amazon.co.uk/Out-Patients-Vol-3-Various-Artists/dp/B00009W0XE/ref=pd_sim_m_h__1',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.co.uk/gp/product/B00009W0XE',
  },
  {
                     input_url: 'http://www.amazon.com/Shine-We-Are-BoA/dp/B00015007W%3FSubscriptionId%3D14P3HXS0ZAYFZPH45TR2%26tag%3Dws%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3DB00015007W',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.com/gp/product/B00015007W',
  },
  {
                     input_url: 'https://www.amazon.co.jp/AMARANTHUS%E3%80%90%E9%80%9A%E5%B8%B8%E7%9B%A4%E3%80%91-%E3%82%82%E3%82%82%E3%81%84%E3%82%8D%E3%82%AF%E3%83%AD%E3%83%BC%E3%83%90%E3%83%BCZ/dp/B0136OCSS8/376-0245530-0562731?ie=UTF8&keywords=4988003477523&qid=1455928973&ref_=sr_1_1&sr=8-1',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.co.jp/gp/product/B0136OCSS8',
  },
  {
                     input_url: 'https://www.amazon.co.uk/Nigel-Kennedy-Polish-Emil-Mynarski/dp/B000VLR0II',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.co.uk/gp/product/B000VLR0II',
  },
  {
                     input_url: 'http://www.amazon.co.uk/Kosheen/e/B000APRTKE',
            expected_clean_url: 'https://www.amazon.co.uk/-/e/B000APRTKE',
  },
  {
                     input_url: 'http://www.amazon.com/gp/redirect.html/ref=amb_link_7764682_1?location=http://www.amazon.com/Carrie-Underwood/e/B0017PAU8Y/%20&token=3A0F170E7CEFE27BDC730D3D7344512BC1296B83&pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-4&pf_rd_r=0WX9S8HSE9M2WG1YZJE4&pf_rd_t=101&pf_rd_p=80631142&pf_rd_i=721517011',
            expected_clean_url: 'https://www.amazon.com/-/e/B0017PAU8Y',
  },
  // Ameba
  {
                     input_url: 'https://ameblo.jp/murataayumi',
             input_entity_type: 'artist',
    expected_relationship_type: 'blog',
            expected_clean_url: 'https://ameblo.jp/murataayumi/',
  },
  {
                     input_url: 'http://ameblo.jp/murataayumi/',
             input_entity_type: 'label',
    expected_relationship_type: 'blog',
            expected_clean_url: 'https://ameblo.jp/murataayumi/',
  },
  // Animationsong.com
  {
                     input_url: 'http://animationsong.com/archives/816073.html#post-13222',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://animationsong.com/archives/816073.html',
       only_valid_entity_types: ['work'],
  },
  // Anime News Network
  {
                     input_url: 'https://animenewsnetwork.com/encyclopedia/people.php?id=59062',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.animenewsnetwork.com/encyclopedia/people.php?id=59062',
  },
  {
                     input_url: 'http://www.animenewsnetwork.com/encyclopedia/company.php?id=10510#page_header',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.animenewsnetwork.com/encyclopedia/company.php?id=10510',
  },
  // Anison Generation
  {
                     input_url: 'http://anison.info/data/person/1878.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://anison.info/data/person/1878.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://anison.info/data/source/15524.html?test',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://anison.info/data/source/15524.html',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://anison.info/data/song/5227.html#test',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://anison.info/data/song/5227.html',
       only_valid_entity_types: ['recording'],
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
  // Baidu Baike
  {
                     input_url: 'baike.baidu.com/view/6458423.htm#1',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/view/6458423.htm',
       only_valid_entity_types: ['artist', 'release_group', 'work'],
  },
  {
                     input_url: 'http://baike.baidu.com/subview/738269/15973629.htm',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/subview/738269/15973629.htm',
       only_valid_entity_types: ['artist', 'release_group', 'work'],
  },
  {
                     input_url: 'https://baike.baidu.com/item/Summer%20Romance%2787/16598351?fromtitle=Summer+Romance&fromid=8735297&type=syn#2',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/item/Summer%20Romance%2787/16598351',
       only_valid_entity_types: ['artist', 'release_group', 'work'],
  },
  {
                     input_url: 'https://baike.baidu.com/item/王婷萱#1',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/item/王婷萱',
       only_valid_entity_types: ['artist', 'release_group', 'work'],
  },
  // Bandcamp
  {
                     input_url: 'https://davidrovics.bandcamp.com?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'bandcamp',
            expected_clean_url: 'https://davidrovics.bandcamp.com/',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'http://idiotsikker.bandcamp.com/tra#top',
             input_entity_type: 'label',
    expected_relationship_type: 'bandcamp',
            expected_clean_url: 'https://idiotsikker.bandcamp.com/',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://andrewhuang.bandcamp.com/track/boom-box/?test',
             input_entity_type: 'recording',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://andrewhuang.bandcamp.com/track/boom-box',
       input_relationship_type: 'bandcamp',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://fieldtriptothemoon.bandcamp.com/album/something-owed',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://fieldtriptothemoon.bandcamp.com/album/something-owed',
       input_relationship_type: 'downloadpurchase',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://non-serviam-records.bandcamp.com/merch/the-howling-void-megaliths-of-the-abyss-digipak',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://non-serviam-records.bandcamp.com/merch/the-howling-void-megaliths-of-the-abyss-digipak',
       input_relationship_type: 'mailorder',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'daily.bandcamp.com/2018/05/30/brownout-fear-of-a-brown-planet-album-review/#more-90177',
             input_entity_type: 'release_group',
    expected_relationship_type: 'review',
            expected_clean_url: 'https://daily.bandcamp.com/2018/05/30/brownout-fear-of-a-brown-planet-album-review/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://daily.bandcamp.com/2018/05/30/gnawa-bandcamp-list',
             input_entity_type: 'release_group',
    expected_relationship_type: 'review',
            expected_clean_url: 'https://daily.bandcamp.com/2018/05/30/gnawa-bandcamp-list/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://davidmandelberg.bandcamp.com/track/maybe-it-s#lyrics',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://davidmandelberg.bandcamp.com/track/maybe-it-s',
       only_valid_entity_types: ['work'],
  },
  // Bandsintown
  {
                     input_url: "https://m.bandsintown.com/MattDobberteen's50thBirthday?came_from=178",
             input_entity_type: 'artist',
    expected_relationship_type: 'bandsintown',
            expected_clean_url: "https://www.bandsintown.com/mattdobberteen's50thbirthday",
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.bandsintown.com/1%252F2Orchestra/past_events',
             input_entity_type: 'artist',
    expected_relationship_type: 'bandsintown',
            expected_clean_url: 'https://www.bandsintown.com/1%252f2orchestra',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.bandsintown.com/en/a/12625251-wormwitch',
             input_entity_type: 'artist',
    expected_relationship_type: 'bandsintown',
            expected_clean_url: 'https://www.bandsintown.com/a/12625251',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://bandsintown.com/a/159526#',
             input_entity_type: 'artist',
    expected_relationship_type: 'bandsintown',
            expected_clean_url: 'https://www.bandsintown.com/a/159526',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://bandsintown.com/event/13245613-the-accidentals-santa-barbara-soho-restaurant-and-music-club-2017?artist=The+Accidentals&came_from=174',
             input_entity_type: 'event',
    expected_relationship_type: 'bandsintown',
            expected_clean_url: 'https://www.bandsintown.com/e/13245613',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'bandsintown.com/venue/846942-soho-restaurant-and-music-club-santa-barbara-ca-tickets-and-schedule',
             input_entity_type: 'place',
    expected_relationship_type: 'bandsintown',
            expected_clean_url: 'https://www.bandsintown.com/v/846942',
       only_valid_entity_types: ['place'],
  },
  // BBC Music
  {
                     input_url: 'http://www.bbc.co.uk/music/artists/b52dd210-909c-461a-a75d-19e85a522042#tracks',
             input_entity_type: 'artist',
    expected_relationship_type: 'bbcmusic',
            expected_clean_url: 'https://www.bbc.co.uk/music/artists/b52dd210-909c-461a-a75d-19e85a522042',
  },
  // Beatport
  {                             // Closed in Dec. 2017, replaced with www.beatport.com/chart
                     input_url: 'http://dj.beatport.com/thegoldenboyuk',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
       only_valid_entity_types: [],
  },
  {                             // Closed in Dec. 2017, replaced with www.beatport.com/best-new-tracks
                     input_url: 'http://mixes.beatport.com/dj/lstunn/450603',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
       only_valid_entity_types: [],
  },
  {                             // Not supported by MusicBrainz: midi, patches, presets, and so on.
                     input_url: 'http://sounds.beatport.com/publisher/Danyella/34462',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'beatport.com/artist/pryda/10554',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/artist/pryda/10554',
       only_valid_entity_types: ['artist'],
  },
  {                             // Nowadays display the same content with another UI
                     input_url: 'http://classic.beatport.com/artist/pryda/10554/tracks',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/artist/pryda/10554',
       only_valid_entity_types: ['artist'],
  },
  {                             // Nowadays redirect to www.beatport.com
                     input_url: 'https://pro.beatport.com/artist/pryda/10554#',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/artist/pryda/10554',
       only_valid_entity_types: ['artist'],
  },
  {                             // Used to fool the detection of missing slug (MBS-9743)
                     input_url: 'https://www.beatport.com/artist/4orcedj/208047',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/artist/4orcedj/208047',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.beatport.com/release/pryda-10-vol-i/1563118',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/pryda-10-vol-i/1563118',
       only_valid_entity_types: ['release'],
  },
  {                             // Used to fool the detection of missing slug (MBS-9846)
                     input_url: 'http://classic.beatport.com/release/4/2361374',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/4/2361374',
       only_valid_entity_types: ['release'],
  },
  {                             // Legacy URL format (real example)
                     input_url: 'https://www.beatport.com/en-US/html/content/release/detail/161035/Back%20To%20The%20Future',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/back-to-the-future/161035',
       only_valid_entity_types: ['release'],
  },
  {                             // Legacy URL format (made up to test slug conversion)
                     input_url: 'https://www.beatport.com/en-US/html/content/release/detail/06130/%40@%26%25%24$%23%22%21!-&tracks#',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/at-at-and-percent-money-money-pound-!!/6130',
       only_valid_entity_types: ['release'],
  },
  {                             // Legacy URL format missing slug (real example)
                     input_url: 'https://www.beatport.com/en-US/html/content/release/detail/287442/',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/---/287442',
       only_valid_entity_types: ['release'],
  },
  {                             // Nowadays erroneous redirect for legacy URL format missing slug (same example)
                     input_url: 'https://www.beatport.com/release//287442',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/---/287442',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.beatport.com/chart/eric-prydz-february-chart/32623',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/chart/eric-prydz-february-chart/32623',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.beatport.com/stem-pack/my-colors-ep/3030',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/stem-pack/my-colors-ep/3030',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.beatport.com/stem/celestial/7380',
             input_entity_type: 'recording',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/stem/celestial/7380',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.beatport.com/track/full-stop-original-mix/1682783',
             input_entity_type: 'recording',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/track/full-stop-original-mix/1682783',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.beatport.com/label/mouseville/1421',
             input_entity_type: 'label',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/label/mouseville/1421',
       only_valid_entity_types: ['label'],
  },
  // Biblioteka Polskiej Piosenki
  {
                     input_url: 'http://www.bibliotekapiosenki.pl/Trzetrzelewska_Barbara',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
  },
  // Big Cartel
  {
                     input_url: 'www.musicofjunior.bigcartel.com/test',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.musicofjunior.bigcartel.com',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.musicofjunior.bigcartel.com?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.musicofjunior.bigcartel.com',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.musicofjunior.bigcartel.com/product/juniorland-ep#test',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.musicofjunior.bigcartel.com/product/juniorland-ep',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://images.bigcartel.com/product_images/186926366/juniorland_bigcartel.jpg?auto=format&fit=max&w=300',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'mailorder',
       only_valid_entity_types: [],
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
  // BnF (Bibliothèque nationale de France) Catalogue
  {
                     input_url: 'http://ark.bnf.fr/ark:/12148/cb11923342r',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb11923342r',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'catalogue.bnf.fr/ark:/12148/cb11923342r',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb11923342r',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://data.bnf.fr/ark:/12148/cb11923342r',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb11923342r',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'https://data.bnf.fr/11923342/antoine_de_saint-exupery/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb11923342r',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://data.bnf.fr/linked-authors/11923342/r/220',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb11923342r',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'catalogue.bnf.fr/ark:/12148/cb394875737.unimarc',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb394875737',
       only_valid_entity_types: ['event', 'release', 'series'],
  },
  {
                     input_url: 'http://data.bnf.fr/43854245/concerto_en_re_spectacle_2014/',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb43854245s',
       only_valid_entity_types: ['event', 'release', 'series'],
  },
  {
                     input_url: 'http://n2t.net/ark:/12148/cb119983474',
             input_entity_type: 'instrument',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb119983474',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://catalogue.bnf.fr/ark:/12148/cb13875048m/PUBLIC',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb13875048m',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://catalogue.bnf.fr/ark:/12148/cb16215568r#noticeNum',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb16215568r',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://catalogue.bnf.fr/ark:/12148/cb37879365r',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
  },
  {
                     input_url: 'http://gallica.bnf.fr/ark:/12148/bpt6k8815248w',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://ark.bnf.fr/ark:/12148/bpt6k8815248w',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://catalogue.bnf.fr/ark:/12148/cb442156144',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb442156144',
       only_valid_entity_types: ['event', 'release', 'series'],
  },
  {
                     input_url: 'http://catalogue.bnf.fr/ark:/12148/cb11962706k',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://catalogue.bnf.fr/ark:/12148/cb11962706k',
       only_valid_entity_types: ['artist', 'instrument', 'label', 'place', 'series', 'work'],
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
  // Brahms Ircam
  {
                     input_url: 'http://brahms.ircam.fr/gilbert-amy#parcours',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://brahms.ircam.fr/gilbert-amy',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://brahms.ircam.fr/works/work/6385/',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://brahms.ircam.fr/works/work/6385',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'http://brahms.ircam.fr/works/genre/328/?test/',
             input_entity_type: 'work',
    expected_relationship_type: undefined,
       input_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  // Cancioneros Musicales Españoles (CME)
  {
                     input_url: 'cancioneros.si/mediawiki/index.php?title=Cancionero_Musical_de_Palacio#RELACI.C3.93N_DE_OBRAS',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.cancioneros.si/mediawiki/index.php?title=Cancionero_Musical_de_Palacio',
       only_valid_entity_types: ['artist', 'series', 'work'],
  },
  {
                     input_url: 'http://www.cancioneros.si/index.php/actividades/pr%C3%B3ximas/conciertos/1553-mhm-2016-11-26-m%C3%BAsica-de-c%C3%A1mara-del-siglo-xix-al-xx.html',
             input_entity_type: 'event',
    expected_relationship_type: undefined,
  },
  // CastAlbums.org
  {
                     input_url: 'http://castalbums.org/recordings/The-Scottsboro-Boys-2014-Original-London-Cast/28967',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
  },
  // CD Baby
  {
                     input_url: 'www.cdbaby.name/artist/Johnn%c3%afDoe1#',
             input_entity_type: 'artist',
    expected_relationship_type: 'cdbaby',
            expected_clean_url: 'https://store.cdbaby.com/Artist/Johnn%c3%afDoe1',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://cdbaby.com/cd/Johnn%c3%af003',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://store.cdbaby.com/cd/johnn%c3%af003',
  },
  // CB (Cape Breton) Fiddle Recordings
  {
                     input_url: 'http://cbfiddle.com/rx/rec/r55.html',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.cbfiddle.com/rx/rec/r55.html',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'www.cbfiddle.com/rx/tune/t4003.html',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.cbfiddle.com/rx/tune/t4003.html',
       only_valid_entity_types: ['work'],
  },
  // ccmixter
  {
                     input_url: 'http://www.ccmixter.org/people/Snowflake',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://ccmixter.org/people/Snowflake',
       only_valid_entity_types: ['artist'],

  },
  {
                     input_url: 'http://ccmixter.org/files/Loveshadow/45199',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://ccmixter.org/files/Loveshadow/45199',
       only_valid_entity_types: ['recording'],

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
                     input_url: 'http://www.classicalarchives.com/artist/27956.html',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/artist/27956.html',
  },
  {
                     input_url: 'www.classicalarchives.com/composer/2806.html#tvf=tracks&tv=albums',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/composer/2806.html',
  },
  {
                     input_url: 'https://www.classicalarchives.com/ensemble/10.html',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/ensemble/10.html',
  },
  {
                     input_url: 'http://classicalarchives.com/album/menlo-201409.html?test',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/album/menlo-201409.html',
  },
  {
                     input_url: 'https://www.classicalarchives.com/work/1119282.html',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/work/1119282.html',
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
            expected_clean_url: 'https://creativecommons.org/licenses/by-nc-nd/2.5/es/',
  },
  {
                     input_url: 'http://creativecommons.org/licenses/by-nc-sa/2.0/de//',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/licenses/by-nc-sa/2.0/de/',
  },
  {
                     input_url: 'http://creativecommons.org/licenses/by/2.0/scotland',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/licenses/by/2.0/scotland/',
  },
  {
                     input_url: 'http://creativecommons.org/licenses/publicdomain',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/licenses/publicdomain/',
  },
  {
                     input_url: 'http://creativecommons.org/licenses/publicdomain//',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/licenses/publicdomain/',
  },
  {
                     input_url: 'http://creativecommons.org/publicdomain/zero/1.0',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/publicdomain/zero/1.0/',
  },
  {
                     input_url: 'http://creativecommons.org/publicdomain/zero/1.0//',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/publicdomain/zero/1.0/',
  },
  {
                     input_url: 'http://creativecommons.org/publicdomain/zero/1.0/legalcode',
             input_entity_type: 'release',
    expected_relationship_type: 'license',
            expected_clean_url: 'https://creativecommons.org/publicdomain/zero/1.0/',
  },
  // Dailymotion
  {
                     input_url: 'https://dailymotion.com/who-knows#uploads',
             input_entity_type: 'artist',
    expected_relationship_type: 'videochannel',
            expected_clean_url: 'https://www.dailymotion.com/who-knows',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'http://www.dailymotion.com/video/xyztuvw_useless-slug?start=42',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.dailymotion.com/video/xyztuvw',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'http://www.dailymotion.com/playlist/xwvuts_who-knows_top/1#video=xyztuvw',
            expected_clean_url: 'https://www.dailymotion.com/video/xyztuvw',
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
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.deezer.com/artist/6509511?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.deezer.com/artist/6509511',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://deezer.com/album/8935347',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.deezer.com/album/8935347',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.deezer.com/track/3437226',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.deezer.com/en/episode/3495945',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.deezer.com/episode/3495945',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://www.deezer.com/en/album/497382',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.deezer.com/album/497382',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.deezer.com/profile/18671676',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'streamingmusic',
       only_valid_entity_types: [],
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
            expected_clean_url: 'https://www.discogs.com/artist/301',
  },
  {                             // old-style URL without numerical ID
                     input_url: 'http://www.discogs.com/artist/Source+Direct',
             input_entity_type: 'artist',
    expected_relationship_type: 'discogs',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://www.discogs.com/artist/1944002-',
             input_entity_type: 'artist',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/artist/1944002',
  },
  {
                     input_url: 'http://www.discogs.com/artist/3080207-Maybebop',
             input_entity_type: 'artist',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/artist/3080207',
  },
  {
                     input_url: 'https://www.discogs.com/artist/997299-Guy-Balbaert?filter_anv=0&subtype=Writing-Arrangement&type=Credits',
             input_entity_type: 'artist',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/artist/997299',
  },
  {
                     input_url: 'https://www.discogs.com/artist/535943-Teresa-Teng?filter_anv=1&anv=%E9%84%A7%E9%BA%97%E5%90%9B',
             input_entity_type: 'artist',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/artist/535943',
       only_valid_entity_types: ['artist', 'place'],
  },
  {
                     input_url: 'http://www.discogs.com/label/2262-Demonic',
             input_entity_type: 'label',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/label/2262',
  },
  {                             // old-style URL without numerical ID
                     input_url: 'http://www.discogs.com/label/Demonic',
             input_entity_type: 'label',
    expected_relationship_type: 'discogs',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://www.discogs.com/release/12130',
             input_entity_type: 'release',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/release/12130',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.discogs.com/release/7086846-Rocks/images',
             input_entity_type: 'release',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/release/7086846',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.discogs.com/Source-Direct-Exorcise-The-Demons/master/126685',
             input_entity_type: 'release_group',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/master/126685',
  },
  {
                     input_url: 'http://www.discogs.com/master/view/267989',
             input_entity_type: 'release_group',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/master/267989',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.discogs.com/master/681937-80s-Mixtape/history',
             input_entity_type: 'release_group',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/master/681937',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.discogs.com/Various-Out-Patients-2/release/5578',
             input_entity_type: 'release',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/release/5578',
  },
  {
                     input_url: 'http://www.discogs.com/composition/27b17569-3e40-40b5-9819-409794c2d5d9-In-The-Hospital',
             input_entity_type: 'work',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/composition/27b17569-3e40-40b5-9819-409794c2d5d9',
  },
  // DRAM
  {
                     input_url: 'http://www.dramonline.org/composers/buren-john-van',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/composers/buren-john-van',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'dramonline.org/ensembles/portland-youth-philharmonic?t=work&o=title&d=0',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/ensembles/portland-youth-philharmonic',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.dramonline.org/performers/avshalomov-jacob#',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/performers/avshalomov-jacob',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://dramonline.org/albums/oregon-composers',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/albums/oregon-composers',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.dramonline.org/albums/oregon-composers?track/delphic-suite-lament-from-troy',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/albums/oregon-composers',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.dramonline.org/albums/oregon-composers?work/delphic-suite',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/albums/oregon-composers',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.dramonline.org/labels/albany-records',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/labels/albany-records',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://www.dramonline.org/instruments/brass/natural-horn',
             input_entity_type: 'instrument',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.dramonline.org/instruments/brass/natural-horn',
       only_valid_entity_types: ['instrument'],
  },
  // Drip
  {
                     input_url: 'https://d.rip/ehaidle/posts/RHJvcFBvc3QtMzQ4',
             input_entity_type: 'artist',
    expected_relationship_type: 'patronage',
            expected_clean_url: 'https://d.rip/ehaidle',
  },
  {
                     input_url: 'https://d.rip/ehaidle/',
             input_entity_type: 'artist',
    expected_relationship_type: 'patronage',
            expected_clean_url: 'https://d.rip/ehaidle',
  },
  // Drip (old)
  {
                     input_url: 'https://drip.kickstarter.com/willits',
             input_entity_type: 'artist',
    expected_relationship_type: 'patronage',
            expected_clean_url: 'https://d.rip/willits',
  },
  // Dynamic Range DB
  {
                     input_url: 'https://dr.loudness-war.info/album/view/168230',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://dr.loudness-war.info/album/view/168230',
       only_valid_entity_types: ['release'],
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
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'http://www.facebook.com/sininemusic',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/sininemusic',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.facebook.com/RomanzMusic?fref=ts',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/RomanzMusic',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.facebook.com/event.php?eid=129606980393356',
             input_entity_type: 'event',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/events/129606980393356',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.facebook.com/events/779218695457920/?ref=2&ref_dashboard_filter=past&sid_reminder=1385056373762424832',
             input_entity_type: 'event',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/events/779218695457920',
  },
  {
                     input_url: 'https://www.facebook.com/events/145813152724695/?ref_page_id=431240490226949&acontext=%7B%22ref%22%3A51%2C%22source%22%3A5%2C%22action_history%22%3A[%7B%22surface%22%3A%22page%22%2C%22mechanism%22%3A%22main_list%22%2C%22extra_data%22%3A%22%5C%22[]%5C%22%22%7D]%2C%22has_source%22%3Atrue%7D',
             input_entity_type: 'event',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/events/145813152724695',
  },
  {
                     input_url: 'https://www.facebook.com/muse/photos_stream',
             input_entity_type: 'event',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/muse',
  },
  {
                     input_url: 'https://www.facebook.com/events/314549615570029/?acontext=%7B%22action_history%22%3A%22[%7B%5C%22surface%5C%22%3A%5C%22page%5C%22%2C%5C%22mechanism%5C%22%3A%5C%22main_list%5C%22%2C%5C%22extra_data%5C%22%3A%5C%22%7B%7D%5C%22%7D]%22%7D',
             input_entity_type: 'event',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/events/314549615570029',
  },
  {
                     input_url: 'http://www.fb.com/bradpot187',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/bradpot187',
  },
  {
                     input_url: 'https://www.facebook.com/pg/TheSullivanSees/',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/TheSullivanSees',
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
            expected_clean_url: 'https://www.generasia.com/wiki/Wink',
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
  },
  {
                     input_url: 'http://www.generasia.com/wiki/Nippon_Crown',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
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
            expected_clean_url: 'https://www.generasia.com/wiki/Ding_Ding_~Koi_Kara_Hajimaru_Futari_no_Train~',
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
       only_valid_entity_types: ['area', 'place'],
  },
  {
                     input_url: 'http://www.geonames.org/6698548/jaani-kirik.html',
             input_entity_type: 'area',
    expected_relationship_type: 'geonames',
            expected_clean_url: 'http://sws.geonames.org/6698548/',
       only_valid_entity_types: ['area', 'place'],
  },
  // Google
  {
                     input_url: 'https://play.google.com/store/music/artist/Daylight?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://play.google.com/store/music/artist?id=Ab34l5k2zbtfv2uwitbfwrwyufy',
  },
  {
                     input_url: 'http://play.google.com/store/music/artist?id=Aathd3z2apf2hbln4wgkrthmhqu',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
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
    expected_relationship_type: undefined,
            expected_clean_url: 'https://play.google.com/store/music/artist?id=Avnwgjjbdf6la5zvdjf62k4jylq',
  },
  {
                     input_url: 'https://play.google.com/store/music/album/Disasterpeace_The_Floor_is_Jelly_Original_Soundtra?id=Bxpxunylzxqoqiiostyvocjtuu4',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://play.google.com/store/music/album?id=Bxpxunylzxqoqiiostyvocjtuu4',
  },
  // HMiku (Miku Hatsune) Wiki
  {
                     input_url: 'atwiki.jp/hmiku/pages/178.html#id_077d534d',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www5.atwiki.jp/hmiku/pages/178.html',
       only_valid_entity_types: ['artist', 'release_group', 'work'],
  },
  {
                     input_url: 'https://www5.atwiki.jp/hmiku/tag/96crow',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  // Hoick Music Search
  {
                     input_url: 'http://hoick.jp/mdb/author/%E4%BD%90%E7%80%AC%E5%AF%BF%E4%B8%80',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://hoick.jp/mdb/author/%E4%BD%90%E7%80%AC%E5%AF%BF%E4%B8%80',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'hoick.jp/mdb/detail/3467/%E3%81%8A%E3%82%88%E3%81%92!%E3%81%9F%E3%81%84%E3%82%84%E3%81%8D%E3%81%8F%E3%82%93#rev_conte',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://hoick.jp/mdb/detail/3467/%E3%81%8A%E3%82%88%E3%81%92!%E3%81%9F%E3%81%84%E3%82%84%E3%81%8D%E3%81%8F%E3%82%93',
       only_valid_entity_types: ['work'],
  },
  // Hoick Online Shop
  {
                     input_url: 'http://hoick.jp/products/detail/18578/%E3%81%9F%E3%81%A3%E3%81%B7%E3%82%8A!%E3%81%95%E3%81%84%E3%81%97%E3%82%93%E3%82%AD%E3%83%83%E3%82%BA%E3%82%BD%E3%83%B3%E3%82%B0%20%E3%82%B6%E3%83%BB%E3%83%99%E3%82%B9%E3%83%8851#review_contents',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://hoick.jp/products/detail/18578/%E3%81%9F%E3%81%A3%E3%81%B7%E3%82%8A!%E3%81%95%E3%81%84%E3%81%97%E3%82%93%E3%82%AD%E3%83%83%E3%82%BA%E3%82%BD%E3%83%B3%E3%82%B0%20%E3%82%B6%E3%83%BB%E3%83%99%E3%82%B9%E3%83%8851',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://hoick.jp/products/detail/18578/%E3%81%9F%E3%81%A3%E3%81%B7%E3%82%8A!%E3%81%95%E3%81%84%E3%81%97%E3%82%93%E3%82%AD%E3%83%83%E3%82%BA%E3%82%BD%E3%83%B3%E3%82%B0%20%E3%82%B6%E3%83%BB%E3%83%99%E3%82%B9%E3%83%8851',
             input_entity_type: 'release_group',
    expected_relationship_type: undefined,
       input_relationship_type: 'lyrics',
       only_valid_entity_types: [],
  },
  // (VICTOR STUDIO) HD-Music.
  {
                     input_url: 'http://hd-music.info/album.cgi/913',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
  },
  // IBDB (Internet Broadway Database)
  {
                     input_url: 'http://www.ibdb.com/broadway-cast-staff/antonin-leopold-dvorak-447817',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.ibdb.com/broadway-cast-staff/antonin-leopold-dvorak-447817',
  },
  // IMDb (Internet Movie Database)
  {
                     input_url: 'http://www.imdb.com/name/nm1539156/',
             input_entity_type: 'artist',
    expected_relationship_type: 'imdb',
            expected_clean_url: 'https://www.imdb.com/name/nm1539156/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.imdb.com/name/nm10024808/',
             input_entity_type: 'artist',
    expected_relationship_type: 'imdb',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.imdb.com/character/ch0003553/',
             input_entity_type: 'artist',
    expected_relationship_type: 'imdb',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.imdb.com/company/co0109498/',
             input_entity_type: 'label',
    expected_relationship_type: 'imdb',
       only_valid_entity_types: ['artist', 'label', 'place'],
  },
  {
                     input_url: 'https://www.imdb.com/title/tt0421082/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'imdb',
       only_valid_entity_types: ['recording', 'release', 'release_group', 'work'],
  },
  // IMSLP (International Music Score Library Project)
  {
                     input_url: 'http://imslp.org/wiki/Category:Buxtehude%2C_Dietrich',
             input_entity_type: 'artist',
    expected_relationship_type: 'imslp',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://imslp.org/wiki/Die_Zauberfl%C3%B6te,_K.620_(Mozart,_Wolfgang_Amadeus)',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
       only_valid_entity_types: ['work'],
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
            expected_clean_url: 'https://www.instagram.com/deadmau5/',
  },
  {
                     input_url: 'https://i.instagram.com/yorickvannorden/?ref=badge',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.instagram.com/yorickvannorden/',
  },
  // Irish Traditional Music Tune Index (Alan Ng's Tunography)
  {
                     input_url: 'https://www.irishtune.info/album/MCnnly/#',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.irishtune.info/album/MCnnly/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://irishtune.info/album/SRyan+C/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.irishtune.info/album/SRyan+C/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'www.irishtune.info/album/KClns+1/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.irishtune.info/album/KClns+1/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.irishtune.info/tune/1499',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.irishtune.info/tune/1499/',
       only_valid_entity_types: ['work'],
  },
  // (Apple) iTunes
  {
                     input_url: 'http://itunes.apple.com/artist/hangry-angry-f/id444923726',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/artist/id444923726',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://itunes.apple.com/us/author/paige-lewis/id348965238#',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/us/artist/paige-lewis/id348965238#',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://itunes.apple.com/music-video/gangnam-style/id564322420?v0=WWW-NAUS-ITSTOP100-MUSICVIDEOS&ign-mpt=uo%3D2',
             input_entity_type: 'recording',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/music-video/id564322420',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://itunes.apple.com/au/preorder/the-last-of-the-tourists/id499465357',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/au/preorder/id499465357',
       only_valid_entity_types: ['release'],
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
  {
                     input_url: 'https://geo.itunes.apple.com/us/album/lonerism/id547068224?app=itunes',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/us/album/id547068224',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://linkmaker.itunes.apple.com/en-us/details/547068224?q=lonerism&country=us&media=music&genre=all',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'downloadpurchase',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://itunes.apple.com/de/audiobook/der-marsianer/id923371856?mt=3&ign-mpt=uo%3D4',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/de/audiobook/id923371856',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://itunes.apple.com/ir/podcast/bia2.com-masouds-podcast/id469326376',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/ir/podcast/id469326376',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://itunes.apple.com/jp/album/uchiagehanabi-single/1263790414',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/jp/album/id1263790414',
       only_valid_entity_types: ['release'],
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
  // JOYSOUND
  {
                     input_url: 'https://www.joysound.com/web/search/artist/5169?startIndex=20#songlist',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.joysound.com/web/search/artist/5169',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.joysound.com/web/search/song/155526#lyrics',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.joysound.com/web/search/song/155526',
       only_valid_entity_types: ['work'],
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
  // Kashinavi.com
  {
                     input_url: 'http://kashinavi.com/kashu.php?artist=103530&kashu=%8A%99%93c%8F%CD%8C%E1&start=1',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://kashinavi.com/kashu.php?artist=103530',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.kashinavi.com/song_view.html?68574',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://kashinavi.com/song_view.html?68574',
       only_valid_entity_types: ['work'],
  },
  // Kget.jp
  {
                     input_url: 'http://www.kget.jp/search/index.php?c=0&r=%E3%83%A4%E3%83%B3%E3%82%B0%E3%83%BB%E3%83%95%E3%83%AC%E3%83%83%E3%82%B7%E3%83%A5&t=&v=&f=',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://www.kget.jp/search/index.php?r=%E3%83%A4%E3%83%B3%E3%82%B0%E3%83%BB%E3%83%95%E3%83%AC%E3%83%83%E3%82%B7%E3%83%A5',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.kget.jp/lyric/173795/VAMOLA%21%E3%82%AD%E3%83%A7%E3%82%A6%E3%83%AA%E3%83%A5%E3%82%A6%E3%82%B8%E3%83%A3%E3%83%BC_%E9%8E%8C%E7%94%B0%E7%AB%A0%E5%90%BE',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://www.kget.jp/lyric/173795/',
       only_valid_entity_types: ['work'],
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
  // Ko-fi
  {
                     input_url: 'http://www.ko-fi.com/35MJZ8OL4IO',
             input_entity_type: 'artist',
    expected_relationship_type: 'patronage',
            expected_clean_url: 'https://ko-fi.com/35MJZ8OL4IO',
  },
  // Lantis
  {
                     input_url: 'http://www.lantis.jp/release-item2.php?id=326c88aa1cd230f96ef350e380a23078',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
  },
  // Last.fm
  {
                     input_url: 'https://www.last.fm/music/Bj%C3%B6rk',
             input_entity_type: 'artist',
    expected_relationship_type: 'lastfm',
  },
  {
                     input_url: 'https://www.last.fm/event/3291943+Pori+jazz',
             input_entity_type: 'event',
    expected_relationship_type: 'lastfm',
  },
  {
                     input_url: 'https://www.lastfm.de/event/671822+Ruhrpott+rodeo+at+Flugplatz+Schwarze+Heide+on+27+June+2008',
             input_entity_type: 'event',
    expected_relationship_type: 'lastfm',
            expected_clean_url: 'https://www.last.fm/event/671822+Ruhrpott+rodeo+at+Flugplatz+Schwarze+Heide+on+27+June+2008',
  },
  {
                     input_url: 'https://www.lastfm.de/festival/297838+Death+Feast+2008',
             input_entity_type: 'event',
    expected_relationship_type: 'lastfm',
            expected_clean_url: 'https://www.last.fm/festival/297838+Death+Feast+2008',
  },
  {
                     input_url: 'https://userserve-ak.last.fm/serve/_/13629495/Lab+Beat+Lab_Beat_Logo_500.gif',
            expected_clean_url: 'https://userserve-ak.last.fm/serve/_/13629495/Lab+Beat+Lab_Beat_Logo_500.gif',
  },
  {
                     input_url: 'https://www.lastfm.com.br/venue/8803923+Gigantinho',
            expected_clean_url: 'https://www.last.fm/venue/8803923+Gigantinho',
  },
  {
                     input_url: 'https://www.lastfm.com/music/Carving+Colours',
            expected_clean_url: 'https://www.last.fm/music/Carving+Colours',
  },
  {
                     input_url: 'http://www.last.fm/it/label/Shyrec#shoutbox',
            expected_clean_url: 'https://www.last.fm/label/Shyrec',
  },
  // Library of Congress Linked Data Service
  {
                     input_url: 'http://id.loc.gov/authorities/names/n79018119.html#tab1',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://id.loc.gov/authorities/names/n79018119',
       only_valid_entity_types: ['artist', 'label', 'place', 'work'],
  },
  {
                     input_url: 'https://id.loc.gov/authorities/names/no2016104748.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://id.loc.gov/authorities/names/no2016104748',
       only_valid_entity_types: ['artist', 'label', 'place', 'work'],
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
  // LiveFans
  {
                     input_url: 'http://www.livefans.jp/artists/4486/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.livefans.jp/artists/4486',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://livefans.jp/events/760678?ref=headline',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.livefans.jp/events/760678',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'https://www.livefans.jp/groups/102241#reviewPost',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.livefans.jp/groups/102241',
       only_valid_entity_types: ['series'],
  },
  {
                     input_url: 'www.livefans.jp/venues/past/4853',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.livefans.jp/venues/4853',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'http://www.livefans.jp/venues/facility?latitude=35.670302&longitude=139.718274&target=1&v_id=4853',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.livefans.jp/venues/4853',
       only_valid_entity_types: ['place'],
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
  // lyric.evesta.jp
  {
                     input_url: 'http://lyric.evesta.jp/a7d0991.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://lyric.evesta.jp/a7d0991.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.lyric.evesta.jp/l7a75fa.html#lyrictitle',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://lyric.evesta.jp/l7a75fa.html',
       only_valid_entity_types: ['work'],
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
  // Mixcloud
  {
                     input_url: 'https://www.mixcloud.com/andrea_mi/',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.mixcloud.com/andrea_mi/',
  },
  // mora
  {
                     input_url: 'https://mora.jp/package/43000001/4534530058010/',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
  },
  {
                     input_url: 'https://mora.jp/package/43000014/KIZC-211/',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
  },
  {
                     input_url: 'http://mora.jp/package/43000021/SQEX-20016_F/#',
            expected_clean_url: 'https://mora.jp/package/43000021/SQEX-20016_F/',
  },
  {
                     input_url: 'https://www.mora.jp/package/43000002/ANTCD-3106?test',
            expected_clean_url: 'https://mora.jp/package/43000002/ANTCD-3106/',
  },
  {
                     input_url: 'mora.jp/package/43000002/ANTCD-3106/',
            expected_clean_url: 'https://mora.jp/package/43000002/ANTCD-3106/',
  },
  // Musa24
  {
                     input_url: 'https://www.musa24.fi/albumi/Matti-ja-Teppo/Nostalgiaa/a1481d06-ee36-844b-bf7f-e8c4f714591b/',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
  },
  // MusicaPopular.cl
  {
                     input_url: 'musicapopular.cl/artista/sensorama-19-81/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.musicapopular.cl/artista/sensorama-19-81/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.musicapopular.cl/grupo/super_collider/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.musicapopular.cl/grupo/super_collider/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.musicapopular.cl/artista/sensorama-19-81/?p=1668',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.musicapopular.cl/artista/sensorama-19-81/?p=1668',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://www.musicapopular.cl/disco/raw-digits',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.musicapopular.cl/disco/raw-digits/',
       only_valid_entity_types: ['release_group'],
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
                     input_url: 'http://musik-sammler.de/artist/strafe-f%C3%BCr-rebellion/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/artist/strafe-f%C3%BCr-rebellion/',
  },
  {
                     input_url: 'https://www.musik-sammler.de/artist/210311/?view=compact#disco-header',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/artist/210311/',
  },
  {
                     input_url: 'http://www.musik-sammler.de/media/594158',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/release/594158/',
  },
  {
                     input_url: 'https://www.musik-sammler.de/album/terrorgruppe-melodien-f%C3%BCr-milliarden-56725/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/album/56725/',
  },
  {
                     input_url: 'https://www.musik-sammler.de/album/804508/review/rain/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/album/804508/',
  },
  {
                     input_url: 'musik-sammler.de/release/594158',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/release/594158/',
  },
  // Musixmatch
  {
                     input_url: 'https://www.musixmatch.com/artist/Bruno-Mars/community/2',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.musixmatch.com/artist/Bruno-Mars',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.musixmatch.com/album/Bruno-Mars/This-Is-My-Love-Remixes-3',
             input_entity_type: 'album',
    expected_relationship_type: undefined,
       input_relationship_type: 'lyrics',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.musixmatch.com/lyrics/Mark-Ronson-feat-Bruno-Mars/Uptown-Funk/translation/spanish',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.musixmatch.com/lyrics/Mark-Ronson-feat-Bruno-Mars/Uptown-Funk',
       only_valid_entity_types: ['work'],
  },
  // Musopen
  {
                     input_url: 'https://musopen.org/music/7887-elegie-op-24/#recordings',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
            expected_clean_url: 'https://musopen.org/music/7887/',
       only_valid_entity_types: ['work'],
  },
  // muziekweb.eu (National Dutch music library)
  {
                     input_url: 'https://www.muziekweb.eu/en/Link/M00000052618/POPULAR/Eminem',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.eu/Link/M00000052618/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/Link/M00000052618/POPULAR/Eminem',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.eu/Link/M00000052618/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.muziekweb.eu/en/Link/JK95205/The-slim-shady-LP',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.eu/Link/JK95205/',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/Link/JK95205/The-slim-shady-LP',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.eu/Link/JK95205/',
       only_valid_entity_types: ['release'],
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
  // NDL (National Diet Library) Authorities
  {
                     input_url: 'id.ndl.go.jp/auth/ndlna/00151866#authdesc',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://id.ndl.go.jp/auth/ndlna/00151866',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://id.ndl.go.jp/auth/ndlna/00151866.rdf',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://id.ndl.go.jp/auth/ndlna/00151866',
       only_valid_entity_types: ['artist'],
  },
  // Ney Nota Arşivi
  {
                     input_url: 'http://www.neyzen.com/nota_arsivi/02_klasik_eserler/054_mahur_buselik/mahur_buselik_ss_aydin_oran.pdf',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
  },
  // Niconico Video
  {
                     input_url: 'https://www.nicovideo.jp/watch/sm2916956?',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.nicovideo.jp/watch/sm2916956',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.nicovideo.jp/user/1050860/top',
             input_entity_type: 'artist',
    expected_relationship_type: 'videochannel',
            expected_clean_url: 'https://www.nicovideo.jp/user/1050860',
       only_valid_entity_types: ['artist'],
  },
  // NLA (National Library of Australia)
  {
                     input_url: 'http://nla.gov.au/nla.party-548358/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://nla.gov.au/nla.party-548358',
  },
  {
                     input_url: 'https://trove.nla.gov.au/people/1448035?c=people',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://nla.gov.au/nla.party-1448035',
  },
  {
                     input_url: 'https://nla.gov.au/anbd.bib-an11701020#',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://nla.gov.au/anbd.bib-an11701020',
  },
  {
                     input_url: 'trove.nla.gov.au/work/9438679',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://trove.nla.gov.au/work/9438679',
  },
  // Online-Bijbel.nl
  {
                     input_url: 'http://www.online-bijbel.nl/12gezang/12/',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://www.online-bijbel.nl/12gezang/12/',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'http://online-bijbel.nl/gezang/231',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://www.online-bijbel.nl/gezang/231/',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'www.online-bijbel.nl/psalm/136/8',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://www.online-bijbel.nl/psalm/136/',
       only_valid_entity_types: ['work'],
  },
  // Open Library
  {
                     input_url: 'https://openlibrary.org/authors/OL23919A/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
  },
  {
                     input_url: 'http://openlibrary.org/books/OL8993487M/Harry_Potter_and_the_Philosopher\'s_Stone',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://openlibrary.org/books/OL8993487M/',
  },
  {
                     input_url: 'https://openlibrary.org/works/OL82592W/',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
  },
  // Operabase
  {
                     input_url: 'www.operabase.com/a/Risto_Joost/21715/future',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://operabase.com/a/Risto_Joost/21715',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://operabase.com/listart.cgi?name=Risto+Joost&acts=+Schedule+',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
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
  {
                     input_url: 'https://www.patreon.com/user/posts?u=4212671&month=2017-4',
             input_entity_type: 'artist',
    expected_relationship_type: 'patronage',
            expected_clean_url: 'https://www.patreon.com/user?u=4212671',
  },
  {
                     input_url: 'https://www.patreon.com/posts/gamers-natural-1823606',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://www.patreon.com/posts/gamers-natural-1823606',
       input_relationship_type: 'patronage',
       only_valid_entity_types: [],
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
  // Petit Lyrics
  {
                     input_url: 'https://petitlyrics.com/lyrics/artist/24786/2-1.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://petitlyrics.com/lyrics/artist/24786',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'petitlyrics.com/lyrics/1039367',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://petitlyrics.com/lyrics/1039367',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'https://petitlyrics.com/lyrics/album/4e484be3818ae3818be38182e38195e38293e381a8e38184e381a3e38197e3828720e69c80e696b0e38399e382b9e38388e3808ce381bfe38293e381aae381aee383aae382bae383a0e3808d?artist=%E6%A8%AA%E5%B1%B1%E3%81%A0%E3%81%84%E3%81%99%E3%81%91%2C%E4%B8%89%E8%B0%B7%E3%81%9F%E3%81%8F%E3%81%BF',
             input_entity_type: 'release_group',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://petitlyrics.com/lyrics/album/4e484be3818ae3818be38182e38195e38293e381a8e38184e381a3e38197e3828720e69c80e696b0e38399e382b9e38388e3808ce381bfe38293e381aae381aee383aae382bae383a0e3808d',
       only_valid_entity_types: ['release_group'],
  },
  // Pinterest
  {
                     input_url: 'uk.pinterest.com/tucenter/pins/#',
             input_entity_type: 'place',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.pinterest.com/tucenter/',
  },
  {
                     input_url: 'http://pinterest.com/tucenter/',
            expected_clean_url: 'https://www.pinterest.com/tucenter/',
  },
  // PureVolume
  {
                     input_url: 'http://www.purevolume.com/withbloodcomescleansing',
             input_entity_type: 'artist',
    expected_relationship_type: 'purevolume',
  },
  // QIM (Québec Info Musique)
  {
                     input_url: 'http://QIM.com/artistes/biographie.asp?artistid=47',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.qim.com/artistes/biographie.asp?artistid=47',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://QuebecInfoMusique.com/artistes/albums.asp?artistid=47',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.qim.com/artistes/biographie.asp?artistid=47',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.quebecinfomusique.com/artistes/oeuvres.asp?artistid=47#',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.qim.com/artistes/biographie.asp?artistid=47',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.qim.com/artistes/nawak.asp?artistid=47',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
            expected_clean_url: 'http://www.qim.com/artistes/nawak.asp?artistid=47',
       input_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://www.qim.com/albums/description.asp?albumid=16',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.qim.com/albums/description.asp?albumid=16',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.qim.com/oeuvres/oeuvre.asp?oeuvreid=716&albumid=16',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.qim.com/oeuvres/oeuvre.asp?oeuvreid=716&albumid=16',
       only_valid_entity_types: ['work'],
  },
  // RecoChoku
  {
                     input_url: 'http://recochoku.jp/artist/2000166063/?affiliate=4350010210',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'http://recochoku.jp/artist/2000166063/',
  },
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
       only_valid_entity_types: [],
  },
  // ReverbNation
  {
                     input_url: 'https://reverbnation.com/negator',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/negator',
  },
  {
                     input_url: 'https://www.reverbnation.com/#!/benwebbmusic',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/benwebbmusic',
  },
  {
                     input_url: 'http://www.reverbnation.com/littlesparrow',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/littlesparrow',
  },
  {
                     input_url: 'http://m.reverbnation.com/venue/602562',
             input_entity_type: 'place',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/venue/602562',
  },
  {
                     input_url: 'https://www.reverbnation.com/sidneybowen?profile_view_source=profile_box',
             input_entity_type: 'place',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/sidneybowen',
  },
  {
                     input_url: 'https://www.reverbnation.com/sidneybowen?profile_tour=true&profile_view_source=profile_box&kick=179811',
             input_entity_type: 'place',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/sidneybowen',
  },
  {
                     input_url: 'https://www.reverbnation.com/tomorrowsyesterdayband?fb_og_action=reverbnation_fb:unknown&fb_og_object=reverbnation_fb:artist&player_client_id=j29dsi7kl&utm_campaign=a_profile_page&utm_content=reverbnation_fb:artist&utm_medium=facebook_og&utm_source=reverbnation_fb:unknown',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.reverbnation.com/tomorrowsyesterdayband',
  },
  // Prog Archives
  {
                     input_url: 'http://www.progarchives.com/artist.asp?id=105#discography',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.progarchives.com/artist.asp?id=105',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'progarchives.com/album.asp?id=00001823',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.progarchives.com/album.asp?id=1823',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.progarchives.com/Collaborators.asp?id=9702',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.progarchives.com/Collaborators.asp?id=9702',
       only_valid_entity_types: [],
  },
  // Rock.com.ar
  {
                     input_url: 'http://rock.com.ar/artistas/200',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/200',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://rock.com.ar/artistas/168/biografia',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/168',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://rock.com.ar/artistas/239/fotos/13',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/239',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'rock.com.ar/artistas/11752/discos/10703',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/11752/discos/10703',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'rock.com.ar/artistas/11752/discos',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/11752',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.rock.com.ar/artistas/11752/letras/19898',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/11752/letras/19898',
       only_valid_entity_types: ['work'],
  },
  // Rock.com.ar (from before its 2017 relaunch)
  {
                     input_url: 'http://www.rock.com.ar/artistas/soda-stereo#contenedor',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/artistas/soda-stereo',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.rock.com.ar/bios/0/168.shtml',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/bios/0/168.shtml',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.rock.com.ar/fotos/0/12.shtml',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'www.rock.com.ar/discos/10/10703.shtml',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/discos/10/10703.shtml',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'rock.com.ar/letras/19/19898.shtml',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://rock.com.ar/letras/19/19898.shtml',
       only_valid_entity_types: ['work'],
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
                     input_url: 'http://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.rockipedia.no/artister/knutsen_og_ludvigsen-31599/',
  },
  {
                     input_url: 'https://www.rockipedia.no/plateselskap/universal_music-1719/',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
  },
  {
                     input_url: 'https://www.rockipedia.no/utgivelser/hunting_high_and_low_-_remastered_and_ex-7991/',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
  },
  // Runeberg
  {
                     input_url: 'http://runeberg.org/f3gd/31/0194.html',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://runeberg.org/f3gd/31/0194.html',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'www.runeberg.org/kacpoet/0023.html',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://runeberg.org/kacpoet/0023.html',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'https://runeberg.org/saol/9-5/0593.html',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'http://runeberg.org/saol/9-5/0593.html',
       only_valid_entity_types: ['work'],
  },
  // SecondHandSongs
  {
                     input_url: 'http://www.secondhandsongs.com/artist/48874+56478+64931',
             input_entity_type: 'artist',
    expected_relationship_type: 'secondhandsongs',
            expected_clean_url: 'https://secondhandsongs.com/artist/48874+56478+64931',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://secondhandsongs.com/label/7752',
             input_entity_type: 'label',
    expected_relationship_type: 'secondhandsongs',
            expected_clean_url: 'https://secondhandsongs.com/label/7752',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://secondhandsongs.com/performance/235077',
             input_entity_type: 'recording',
    expected_relationship_type: 'secondhandsongs',
            expected_clean_url: 'https://secondhandsongs.com/performance/235077',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://secondhandsongs.com/release/888',
             input_entity_type: 'release',
    expected_relationship_type: 'secondhandsongs',
            expected_clean_url: 'https://secondhandsongs.com/release/888',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.secondhandsongs.com/work/140348/adaptations#nav-entity',
             input_entity_type: 'work',
    expected_relationship_type: 'secondhandsongs',
            expected_clean_url: 'https://secondhandsongs.com/work/140348',
       only_valid_entity_types: ['work'],
  },
  // setlist.fm
  {
                     input_url: 'https://www.setlist.fm/setlists/foo-fighters-bd6893a.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'setlistfm',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.setlist.fm/setlist/foo-fighters/2014/house-of-blues-new-orleans-la-13cda5b1.html',
             input_entity_type: 'event',
    expected_relationship_type: 'setlistfm',
            expected_clean_url: 'https://www.setlist.fm/setlist/foo-fighters/2014/house-of-blues-new-orleans-la-13cda5b1.html',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'https://www.setlist.fm/venue/house-of-blues-new-orleans-la-usa-23d61c9f.html',
             input_entity_type: 'place',
    expected_relationship_type: 'setlistfm',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'https://www.setlist.fm/festivals/house-of-blues-new-orleans-la-usa-23d61c9f.html',
             input_entity_type: 'series',
    expected_relationship_type: 'setlistfm',
       only_valid_entity_types: ['series'],
  },
  // (SMDB) Svensk mediedatabas
  {
                     input_url: 'http://smdb.kb.se/catalog/id/001508972',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
  },
  // (SNAC) Social Networks and Archival Context
  {
                     input_url: 'http://snaccooperative.org/ark:/99166/w6mq170x#',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://snaccooperative.org/ark:/99166/w6mq170x',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://n2t.net/ark:/99166/w6mq170x',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://snaccooperative.org/ark:/99166/w6mq170x',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'http://snaccooperative.org/view/14820000',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://snaccooperative.org/view/14820000',
       only_valid_entity_types: [],
  },
  // Songkick
  {
                     input_url: 'https://www.songkick.com/artists/3909026-courtney-barnett/calendar',
             input_entity_type: 'artist',
    expected_relationship_type: 'songkick',
            expected_clean_url: 'https://www.songkick.com/artists/3909026',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.songkick.com/festivals/74586-ruhrpott-rodeo/id/19803209-ruhrpott-rodeo-festival-2014',
             input_entity_type: 'event',
    expected_relationship_type: 'songkick',
            expected_clean_url: 'https://www.songkick.com/festivals/74586/id/19803209',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'http://www.songkick.com/venues/1141041-flugplatz-schwarze-heide#calendar-summary',
             input_entity_type: 'place',
    expected_relationship_type: 'songkick',
            expected_clean_url: 'https://www.songkick.com/venues/1141041',
       only_valid_entity_types: ['place'],
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
                     input_url: 'https://soundcloud.com/red-bull-studios-tyo',
             input_entity_type: 'place',
    expected_relationship_type: 'soundcloud',
  },
  {
                     input_url: 'https://soundcloud.com/glastonburyofficial',
             input_entity_type: 'series',
    expected_relationship_type: 'soundcloud',
       only_valid_entity_types: ['artist', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://soundcloud.com/tags/bug',
       input_relationship_type: 'soundcloud',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://soundcloud.com/search?q=some%20bug',
       input_relationship_type: 'soundcloud',
       only_valid_entity_types: [],
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
       only_valid_entity_types: ['artist'],
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
       only_valid_entity_types: ['release_group'],
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
            expected_clean_url: 'https://open.spotify.com/track/7gwRSZ0EmGWa697ZrE58GA',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://open.spotify.com/track/1SI5O5cu8AM19cninxf9RZ',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://open.spotify.com/track/1SI5O5cu8AM19cninxf9RZ',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://open.spotify.com/episode/5yyMb4t3PWlikJNucu9A6Z',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://embed.spotify.com/?uri=spotify:episode:5yyMb4t3PWlikJNucu9A6Z',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://open.spotify.com/episode/5yyMb4t3PWlikJNucu9A6Z',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://play.spotify.com/album/3rFPzWNUrtoqMd9yNGaFMr?play=true&utm_source=open.spotify.com&utm_medium=open',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://open.spotify.com/album/3rFPzWNUrtoqMd9yNGaFMr',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.spotify.com/artist/5zS2OG2kKeGYFqX6lcuVOt?play=true&utm_source=google&utm_medium=growth_paid&utm_campaign=pla_US&gclid=CN-m_fOj3cMCFUJk7AodTBsA8g',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://open.spotify.com/artist/5zS2OG2kKeGYFqX6lcuVOt',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'open.spotify.com/album/0tabKG66W34Ms0SsovkP6Q/6yVKnHVFGkg4OQ8IrgQVpZ',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://open.spotify.com/album/0tabKG66W34Ms0SsovkP6Q',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://open.spotify.com/local/Electrolyze/Single/Belief/265',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingmusic',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://play.spotify.com/search/The%20Most%20Essential%20Bossa%20Nova',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingmusic',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'http://play.spotify.com/user/scotchbonnetrecords',
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://open.spotify.com/user/scotchbonnetrecords',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://play.spotify.com/user/1254688529/playlist/0MRy5cv9ZktSjysDEIP72H',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'play.spotify.com/user/1254688529/',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://open.spotify.com/user/1254688529',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
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
                     input_url: 'https://thesession.org/recordings/artists/793?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://thesession.org/recordings/artists/793',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://thesession.org/members/01234',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'thesession.org/events/3811#comment748363',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://thesession.org/events/3811',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'http://www.thesession.org/recordings/display/1488',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://thesession.org/recordings/1488',
  },
  {
                     input_url: 'https://thesession.org/recordings/4740/edit',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://thesession.org/recordings/4740',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.thesession.org/tunes/display/2305',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://thesession.org/tunes/2305',
       only_valid_entity_types: ['work'],
  },
  // Tipeee
  {
                     input_url: 'https://www.tipeee.com/example/news',
             input_entity_type: 'artist',
    expected_relationship_type: 'patronage',
            expected_clean_url: 'https://www.tipeee.com/example',
  },
  {
                     input_url: 'http://fr.tipeee.com/example/news',
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
  // Twitch
  {
                     input_url: 'http://twitch.tv/who_knows/videos/all',
             input_entity_type: 'artist',
    expected_relationship_type: 'videochannel',
            expected_clean_url: 'https://www.twitch.tv/who_knows',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.twitch.tv/videos/1234567890?collection=Key_w',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.twitch.tv/videos/1234567890',
       only_valid_entity_types: ['recording', 'release'],
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
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://twitter.com/UNIVERSAL_D',
  },
  {
                     input_url: 'https://twitter.com/@UNIVERSAL_D#content-main-heading',
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://twitter.com/UNIVERSAL_D',
  },
  {
                     input_url: 'https://twitter.com/mountain_goats/status/1062342708470132738',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://twitter.com/mountain_goats/status/1062342708470132738',
       only_valid_entity_types: ['recording'],
  },
  // Universal Music
  {
                     input_url: 'http://www.universal-music.co.jp/sweety/products/umca-59007/',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
  },
  // UtaiteDB/VocaDB/TouhouDB
  {
                     input_url: 'http://utaitedb.net/Ar/1#',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://utaitedb.net/Ar/1',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://vocadb.net/Ar/26957#picturesTab',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://vocadb.net/Ar/26957',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'touhoudb.com/Al/4644',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://touhoudb.com/Al/4644',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://vocadb.net/E/10/comiket-80',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://vocadb.net/E/10',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'https://utaitedb.net/Event/SeriesDetails/30',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://utaitedb.net/Event/SeriesDetails/30',
       only_valid_entity_types: ['series'],
  },
  {
                     input_url: 'https://vocadb.net/Song/Details/141014',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://vocadb.net/S/141014',
       only_valid_entity_types: ['recording', 'work'],
  },
  {
                     input_url: 'https://vocadb.net/S/143473?albumId=21156',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://vocadb.net/S/143473',
       only_valid_entity_types: ['recording', 'work'],
  },
  // Utamap
  {
                     input_url: 'http://www.utamap.com/showkasi.php?surl=34985',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
  },
  // Uta-Net
  {
                     input_url: 'http://uta-net.com/artist/9208/4/',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.uta-net.com/artist/9208/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.uta-net.com/song/188300/',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.uta-net.com/song/188300/',
       only_valid_entity_types: ['work'],
  },
  // Utaten
  {
                     input_url: 'utaten.com/artist/fripSide?sort=popular_sort_asc',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://utaten.com/artist/fripSide',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://utaten.com/lyric/fripSide/prominence#sort=popular_sort_asc',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://utaten.com/lyric/fripSide/prominence',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'https://utaten.com/news/index/14365',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://utaten.com/news/index/14365',
       input_relationship_type: 'lyrics',
       only_valid_entity_types: [],
  },
  // VGMdb (Video Game Music and Anime Soundtrack Database)
  {
                     input_url: 'https://vgmdb.net/artist/431',
             input_entity_type: 'artist',
    expected_relationship_type: 'vgmdb',
            expected_clean_url: 'https://vgmdb.net/artist/431',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://vgmdb.com/event/197',
             input_entity_type: 'event',
    expected_relationship_type: 'vgmdb',
            expected_clean_url: 'https://vgmdb.net/event/197',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'https://vgmdb.com/org/284',
             input_entity_type: 'label',
    expected_relationship_type: 'vgmdb',
            expected_clean_url: 'https://vgmdb.net/org/284',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'vgmdb.net/album/29727',
             input_entity_type: 'release',
    expected_relationship_type: 'vgmdb',
            expected_clean_url: 'https://vgmdb.net/album/29727',
       only_valid_entity_types: ['release'],
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
            expected_clean_url: 'https://vimeo.com/1109226',
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
            expected_clean_url: 'https://www.weibo.com/mchotdog2010',
  },
  {
                     input_url: 'https://weibo.com/mchotdog2010?test',
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.weibo.com/mchotdog2010',
  },
  {
                     input_url: 'http://www.weibo.com/u/5887871694?is_hot=1',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.weibo.com/u/5887871694',
  },
  // WhoSampled
  {
                     input_url: 'http://www.whosampled.com/Just-to-Get-a-Rep/Gang-Starr/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
  },
  // Fandom (old Wikia)
  {
                     input_url: 'http://lyrics.wikia.com/Van_Canto:Hero_(2008)',
             input_entity_type: 'release_group',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://lyrics.fandom.com/Van_Canto:Hero_(2008)',
  },
  {
                     input_url: 'http://lyrics.fandom.com/wiki/S%C3%B5pruse_Puiestee:Miks_Ma_Ei_V%C3%B5iks_Olla_Maailmas_%C3%9Cksi',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://lyrics.fandom.com/wiki/S%C3%B5pruse_Puiestee:Miks_Ma_Ei_V%C3%B5iks_Olla_Maailmas_%C3%9Cksi',
  },
  {
                     input_url: 'http://fr.lyrics.wikia.com/wiki/Christiane_Legrand/Les_parapluies_de_Cherbourg',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://lyrics.fandom.com/fr/wiki/Christiane_Legrand/Les_parapluies_de_Cherbourg',
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
  {
                     input_url: 'https://www.wikidata.org/wiki/Special:EntityPage/Q339359',
             input_entity_type: 'instrument',
            expected_clean_url: 'https://www.wikidata.org/wiki/Q339359',
    expected_relationship_type: 'wikidata',
  },
  {
                     input_url: 'http://www.wikidata.org/entity/Q4655955',
             input_entity_type: 'artist',
            expected_clean_url: 'https://www.wikidata.org/wiki/Q4655955',
    expected_relationship_type: 'wikidata',
  },
  {
                     input_url: 'http://www.example.org/not/wikidata.org',
       input_relationship_type: 'wikidata',
       only_valid_entity_types: [],
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
  {
                     input_url: 'https://commons.m.wikimedia.org/wiki/File:Karel-R%C5%AF%C5%BEi%C4%8Dka-star%C5%A1%C3%AD.jpg#mw-jump-to-license',
            expected_clean_url: 'https://commons.wikimedia.org/wiki/File:Karel-R%C5%AF%C5%BEi%C4%8Dka-star%C5%A1%C3%AD.jpg',
  },
  {
                     input_url: 'https://commons.wikimedia.org/wiki/Category:Opeth#/media/File:Opeth_-_Kavarna_Rock_Fest_2011.jpg',
             input_entity_type: 'artist',
    expected_relationship_type: 'image',
            expected_clean_url: 'https://commons.wikimedia.org/wiki/File:Opeth_-_Kavarna_Rock_Fest_2011.jpg',
  },
  {
                     input_url: 'http://commons.wikimedia.org/wiki/Category:Michl_M%C3%BCller?uselang=de#/media/File:Michl_M%C3%BCller_Garitz_2013.JPG',
             input_entity_type: 'artist',
    expected_relationship_type: 'image',
            expected_clean_url: 'https://commons.wikimedia.org/wiki/File:Michl_M%C3%BCller_Garitz_2013.JPG',
  },
  {
                     input_url: 'https://commons.wikimedia.org/wiki/File%3APolygram_Gold_Disc_Award_Wet_Wet_Wet_Ralph_Ruppert_1987.jpg',
            expected_clean_url: 'https://commons.wikimedia.org/wiki/File:Polygram_Gold_Disc_Award_Wet_Wet_Wet_Ralph_Ruppert_1987.jpg',
  },
  {
                     input_url: 'https://commons.wikimedia.org/wiki/File%3A$&+,/:;=@[]%20%23%24%25%2B%2C%2F%3A%3B%3F%40',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
            expected_clean_url: 'https://commons.wikimedia.org/wiki/File:$%26%2B,/:;%3D@%5B%5D_%23$%25%2B,/:;%3F@',
  },
  {                             // gallery page
                     input_url: 'https://commons.wikimedia.org/wiki/Within_Temptation',
             input_entity_type: 'artist',
    expected_relationship_type: 'image',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://commons.wikimedia.org/wiki/Category:Ewa_Demarczyk',
             input_entity_type: 'artist',
    expected_relationship_type: 'image',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://commons.wikimedia.org/w/index.php?search=umberto+alongi&title=Special%3ASearch&go=Go',
             input_entity_type: 'label',
    expected_relationship_type: 'image',
       only_valid_entity_types: [],
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
  {
                     input_url: 'https://en.wikipedia.org/wiki/Some_Album',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'discographyentry',
       only_valid_entity_types: [],
  },
  // Wikisource
  {
                     input_url: 'https://pt.wikisource.org/wiki/A_Portuguesa',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://pt.wikisource.org/wiki/A_Portuguesa',
  },
  {                             // rare languages are on wikisource.org directly
                     input_url: 'http://wikisource.org/wiki/Reise,_Reise',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://wikisource.org/wiki/Reise,_Reise',
       only_valid_entity_types: ['artist', 'release_group', 'work'],
  },
  // Warner Music
  {
                     input_url: 'http://wmg.jp/artist/ayaka/WPCL000010415.html',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
  },
  // Worldcat
  {
                     input_url: 'http://www.worldcat.org/title/sometimes-i-sit-and-think-and-sometimes-i-just-sit/oclc/903606316',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.worldcat.org/oclc/903606316',
  },
  {
                     input_url: 'http://www.worldcat.org/identities/lccn-no2015052484/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.worldcat.org/identities/lccn-no2015052484/',
  },
  // YouTube
  {
                     input_url: 'http://youtube.com/user/officialpsy/videos',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/officialpsy',
  },
  {
                     input_url: 'http://m.youtube.com/#/user/JessVincentMusic',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/JessVincentMusic',
  },
  {
                     input_url: 'https://www.youtube.com/user/JessVincentMusic?feature=watch',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/JessVincentMusic',
  },
  {
                     input_url: 'http://www.youtube.com/embed/UmHdefsaL6I',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.youtube.com/watch?v=UmHdefsaL6I',
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
            expected_clean_url: 'https://www.youtube.com/watch?v=UmHdefsaL6I',
  },
  {
                     input_url: 'https://www.youtube.com/watch?v=4eUqsUZBluA&list=PLkHWBeudCLJCjB41Yt1iiain82Lp1zQOB',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingmusic',
            expected_clean_url: 'https://www.youtube.com/watch?v=4eUqsUZBluA',
  },
  {
                     input_url: 'https://www.youtube.com/c/MetaBrainz',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/MetaBrainz',
  },
];
/* eslint-enable indent, max-len, sort-keys */

const relationshipTypesByUuid = _.reduce(LINK_TYPES, function (
  results,
  relUuidByEntityType,
  relationshipType,
) {
  _.each(relUuidByEntityType, function (relUuid) {
    (results[relUuid] || (results[relUuid] = [])).push(relationshipType);
  });
  return results;
}, {});

const previousMatchTests = [];

function doMatchSubtest(
  st,
  entityType,
  url,
  label,
  expectedRelationshipType,
) {
  const relUuid = guessType(entityType, url);
  const actualRelationshipType = _.find(relationshipTypesByUuid[relUuid],
    function (s) {
      return s === expectedRelationshipType;
    });
  st.equal(actualRelationshipType, expectedRelationshipType, 'Match ' + label + ' URL relationship type for ' + entityType + ' entities');
  previousMatchTests.push(entityType + '+' + url);
}

_.each(testData, function (subtest, i) {
  test('input URL [' + i + '] = ' + subtest.input_url, {}, function (st) {
    let tested = false;
    if (!subtest.input_url) {
      st.fail('Test is invalid: "input_url" is missing: ' + JSON.stringify(subtest));
      st.end();
      return;
    }
    if (subtest.input_entity_type) {
      if ('expected_relationship_type' in subtest) {
        if (previousMatchTests.indexOf(subtest.input_entity_type + '+' + subtest.input_url) !== -1) {
          st.fail('Match test is worthless: Duplication has been detected: ' + JSON.stringify(subtest));
        }
        doMatchSubtest(st, subtest.input_entity_type, subtest.input_url, 'input', subtest.expected_relationship_type);
        tested = true;
      } else {
        st.fail('Test is invalid: "input_entity_type" is specified without "expected_relationship_type".');
        st.end();
        return;
      }
    } else if ('expected_relationship_type' in subtest) {
      st.fail('Test is invalid: "expected_relationship_type" is specified without "input_entity_type".');
      st.end();
      return;
    }
    const actualCleanUrl = cleanURL(subtest.input_url);
    if (subtest.expected_clean_url) {
      st.equal(actualCleanUrl, subtest.expected_clean_url, 'Clean up');
      if (subtest.input_entity_type && 'expected_relationship_type' in subtest &&
                        previousMatchTests.indexOf(subtest.input_entity_type + '+' + subtest.expected_clean_url) === -1) {
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
      const relationshipType = subtest.input_relationship_type ||
        subtest.expected_relationship_type;
      const cleanUrl = subtest.expected_clean_url || actualCleanUrl;
      if (!relationshipType) {
        st.fail('Test is invalid: "only_valid_entity_types" are specified with neither "expected_relationship_type" nor "input_relationship_type".');
        st.end();
        return;
      }
      let nbTestedRules = 0;
      const validationResults = _.reduce(LINK_TYPES[relationshipType],
        function (results, relUuid, entityType) {
          const rule = validationRules[relUuid];
          const isValid = rule ? rule(cleanUrl) || false : true;
          results[isValid].splice(
            _.sortedIndex(results[isValid], entityType),
            0,
            entityType,
          );
          nbTestedRules += rule ? 1 : 0;
          return results;
        }, {false: [], true: []});
      if (nbTestedRules === 0) {
        st.fail('Validation test is worthless: No validation rule has been actually tested.');
      } else {
        st.deepEqual(validationResults.true,
          subtest.only_valid_entity_types.sort(),
          'Validate clean URL by exactly ' + subtest.only_valid_entity_types.length +
                            ' among ' + nbTestedRules + ' ' + relationshipType + '.* rules');
        tested = true;
      }
    }
    if (!tested) {
      st.fail('Test is worthless: Nothing has been actually tested.');
    }
    st.end();
  });
});
