/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {arraysEqual} from '../../common/utility/arrays.js';
import {
  Checker,
  cleanURL,
  LINK_TYPES,
} from '../../edit/URLCleanup.js';

/*
 * This file tests the cleanups and autoselect / restrictions defined in
 * root/static/scripts/edit/URLCleanup.js
 *
 * The main part of the file is the testData object, which contains
 * the expected results for all the tests. The following properties
 * are supported in testData:
 *
 * input_url:
 *      The raw URL "entered by the user" (a string).
 *
 *      This is always mandatory.
 *
 * input_entity_type:
 *      The entity type selected by the user (a string, such as 'release').
 *      This is important because the same URL can be assigned to different
 *      relationship types (or blocked altogether) depending on the selected
 *      entity type.
 *
 *      Required by 'expected_relationship_type', 'expected_error'
 *      and 'limited_link_type_combinations'. Forbidden if none are present.
 *
 * expected_relationship_type:
 *      The relationship type (or types) we expect the URL to get
 *      autoselected to. Either a string, such as 'downloadfree',
 *      or an array of strings, such as ['downloadfree', 'streamingfree'].
 *      Can also be set to undefined if autoselection is not supposed
 *      to happen. Keep in mind that the strings here are the keys from the
 *      LINK_TYPES constant in URLCLeanup, not the relationship type names.
 *
 *      Optional. If present, 'input_entity_type' is required.
 *
 * limited_link_type_combinations:
 *      An array of all the possible combinations of relationship types
 *      allowed for the entity type indicated by 'input_entity_type'. This is
 *      different from autoselection - some relationship types in this list
 *      might be autoselected, while others are just available for selection
 *      to the user. To test for autoselection, also use
 *      'expected_relationship_type' alongside this.
 *      Each of the allowed combinations can be just a string, meaning only
 *      one relationship is selected, or an array of strings, meaning that all
 *      the options in the array are selected at the same time. Keep in mind
 *      that having two different string options just means either one or the
 *      other can be used, and if you want both to be allowed together as well
 *      you will *also* need an array option. As above, the strings here are
 *      keys from the LINK_TYPES constant in URLCLeanup,
 *      not the relationship type names.
 *      For example, a possible value for this property would be
 *      the following, allowing 'downloadpurchase', 'streamingpaid' or both:
 *      [
 *        'downloadpurchase',
 *        'streamingpaid',
 *        ['downloadpurchase', 'streamingpaid'],
 *      ]
 *
 *      Optional. If present, 'input_entity_type' is required.
 *
 * input_relationship_type:
 *      The relationship type selected by the user (a string, such as
 *      'downloadfree'). This is useful when a URL does not get autoselected,
 *      but we want to run a test that requires a relationship type
 *      (at the moment that's exclusively testing for
 *      'only_valid_entity_types'). Consider also setting
 *      'expected_relationship_type' to undefined for clarity if
 *      autoselection is not supposed to happen.
 *
 *      Optional if 'only_valid_entity_types' is present, forbidden otherwise.
 *
 * expected_clean_url:
 *      The URL we expect to get back from the clean function (a string).
 *
 *      Optional, but strongly encouraged for all URLs with a clean function.
 *
 * only_valid_entity_types:
 *      An array of all the entity types the URL can be added to using the
 *      relationship type indicated by 'expected_relationship_type' or
 *      'input_relationship_type'. If you want to test that this URL is *not*
 *      allowed for the given relationship type, pass an empty array ([]).
 *
 *      Optional. If present, one of 'expected_relationship_type' or
 *      'input_relationship_type' is required.
 *
 * expected_error:
 *      An object {error, target}. 'target' is the target level for the error,
 *      one of 'entity', 'relationship' or 'url'. 'error' is a string to match
 *      against the returned error message (a substring is enough, the full
 *      error string is not needed). If the error is supposed to use the
 *      default message for its target, set 'error' as undefined.
 *
 *      Optional. If present, one of 'expected_relationship_type' or
 *      'input_relationship_type' is required, as well as 'input_entity_type'.
 *
 *
 * When adding a new test or set of tests, add them under the section for
 * the website in question. If no section exists yet, create one and add a
 * comment header to it indicating what website it is. Sections are generally
 * listed in alphabetical order (of the site names, not the domains).
 *
 *
 * The code running the tests is at the end of the file. The tests are ran
 * in the same general order as the properties listed above, if present:
 *      expected_relationship_type ->
 *      limited_link_type_combinations ->
 *      expected_clean_url ->
 *      only_valid_entity_types ->
 *      expected_error
 */

/* eslint-disable indent, max-len, sort-keys */
const testData = [
  // 45cat
  {
                     input_url: 'https://www.45cat.com/artist/edwin-starr',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45cat.com/artist/edwin-starr',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.45cat.com/label/eastwest/all',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45cat.com/label/eastwest',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://45cat.com/record/vs1370&rc=365077#365077',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45cat.com/record/vs1370',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.45cat.com/45_composer.php?tc=Floyd+Hunt',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
       only_valid_entity_types: [],
                expected_error: {
                                  error: undefined,
                                  target: 'url',
                                },
  },
  // 45worlds
  {
                     input_url: 'http://www.45worlds.com/78rpm/artist/yehudi-menuhin',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/78rpm/artist/yehudi-menuhin',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://45worlds.com/classical/artist/yehudi-menuhin',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/classical/artist/yehudi-menuhin',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.45worlds.com/classical/soloist/yehudi-menuhin',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/classical/soloist/yehudi-menuhin',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.45worlds.com/live/listing/rumer-fawcetts-field-2012&rc=186697#186697',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/live/listing/rumer-fawcetts-field-2012',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'http://www.45worlds.com/tape/label/parlophone/all',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/tape/label/parlophone',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://www.45worlds.com/live/venue/stadium-high-school-stadium',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/live/venue/stadium-high-school-stadium',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'http://www.45worlds.com/vinyl/album/mfsl1100',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/vinyl/album/mfsl1100',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45worlds.com/12single/record/fu2t',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/12single/record/fu2t',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45worlds.com/cdsingle/cd/pwcd227',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/cdsingle/cd/pwcd227',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.45worlds.com/classical/music/asd264',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.45worlds.com/classical/music/asd264',
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
                     input_url: 'https://us.7digital.com/artist/el-p/release/cancer-4-cure-explicit-6120477#skip-back-to-top',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://us.7digital.com/artist/el-p/release/cancer-4-cure-explicit-6120477',
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
  {
                     input_url: 'https://fr-ca.7digital.com/artist/83-1/release/récidivistes-12888712?f=20%2C19%2C12%2C16%2C17%2C9%2C2&partner=8380',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://fr-ca.7digital.com/artist/83-1/release/récidivistes-12888712',
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
                     input_url: 'https://www.allmusic.com/genre/electronic-ma0000002572/albums',
             input_entity_type: 'genre',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/genre/ma0000002572',
       only_valid_entity_types: ['genre'],
  },
  {
                     input_url: 'https://www.allmusic.com/style/dark-ambient-ma0000011972',
             input_entity_type: 'genre',
    expected_relationship_type: 'allmusic',
            expected_clean_url: 'https://www.allmusic.com/style/ma0000011972',
       only_valid_entity_types: ['genre'],
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
                     input_url: 'https://www.amazon.nl/Various-Artists-100X-Winter-2014/dp/B00NX6I0UA/ref=pd_rhf_se_p_img_1?_encoding=UTF8&psc=1&refRID=A6BMGX43CX4PV9HTFZZX',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.nl/gp/product/B00NX6I0UA',
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
                     input_url: 'http://www.amazon.com.tr/Out-Patients-Vol-3-Various-Artists/dp/B00009W0XE/ref=pd_sim_m_h__1',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.com.tr/gp/product/B00009W0XE',
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
                     input_url: 'https://www.amazon.se/dp/B08HG3BKQK/ref=s9_acsd_al_bw_c2_x_2_i?pf_rd_m=ANU9KP01APNAG&pf_rd_s=merchandised-search-3&pf_rd_r=10ZQ8Y1M20980ADPD73G&pf_rd_t=101&pf_rd_p=e37adbab-6466-4fa2-a8f9-10945bebd663&pf_rd_i=20513251031',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.se/gp/product/B08HG3BKQK',
  },
  {
                     input_url: 'https://www.amazon.eg/dp/B091CW2QM2/',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.eg/gp/product/B091CW2QM2',
  },
  {
                     input_url: 'https://www.amazon.sa/dp/B0914VB72Y/',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.sa/gp/product/B0914VB72Y',
  },
  {
                     input_url: 'https://www.amazon.pl/gp/product/B07TJKC2DG/#customerReviews',
             input_entity_type: 'release',
    expected_relationship_type: 'amazon',
            expected_clean_url: 'https://www.amazon.pl/gp/product/B07TJKC2DG',
  },
  {
                     input_url: 'http://www.amazon.co.uk/Kosheen/e/B000APRTKE',
            expected_clean_url: 'https://www.amazon.co.uk/-/e/B000APRTKE',
  },
  {
                     input_url: 'http://www.amazon.com/gp/redirect.html/ref=amb_link_7764682_1?location=http://www.amazon.com/Carrie-Underwood/e/B0017PAU8Y/%20&token=3A0F170E7CEFE27BDC730D3D7344512BC1296B83&pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-4&pf_rd_r=0WX9S8HSE9M2WG1YZJE4&pf_rd_t=101&pf_rd_p=80631142&pf_rd_i=721517011',
            expected_clean_url: 'https://www.amazon.com/-/e/B0017PAU8Y',
  },
  // Amazon Music
  {
                     input_url: 'http://music.amazon.com/artists/B000QKDMIG',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://music.amazon.com/artists/B000QKDMIG',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://music.amazon.co.uk/albums/B07VPBW7S9#',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://music.amazon.co.uk/albums/B07VPBW7S9',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://music.amazon.co.uk/albums/B07VQTD55C?trackAsin=B07VMLW9PK&ref=dm_sh_cf2b-aa2f-dmcp-def3-f0a59&musicTerritory=GB&marketplaceId=A1F83G8C2ARO7P',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://music.amazon.co.uk/albums/B07VQTD55C',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://somefancymusic.amazon.com/artists/B000QKDMIG',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'amazon',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.amazon.com/vdp/08c6c18fc7bb4822a166db4834e123f1?ref=dp_vse_rvc_0',
             input_entity_type: 'release',
       input_relationship_type: 'amazon',
    expected_relationship_type: undefined,
       only_valid_entity_types: [],
            expected_clean_url: 'https://www.amazon.com/vdp/08c6c18fc7bb4822a166db4834e123f1?ref=dp_vse_rvc_0',
                expected_error: {
                                  error: 'link to a user video',
                                  target: 'url',
                                },
  },
  // amzn.to
  {
                     input_url: 'http://amzn.to/2n4b5k4',
             input_entity_type: 'release',
       input_relationship_type: 'amazon',
    expected_relationship_type: undefined,
       only_valid_entity_types: [],
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
  // Apple Books
  {
                     input_url: 'https://books.apple.com/us/author/richard-adams/id30997554',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://books.apple.com/us/author/id30997554',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://books.apple.com/us/book/watership-down/id381935940',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://books.apple.com/us/book/id381935940',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://books.apple.com/us/audiobook/watership-down/id1462355665?mt=3&ign-mpt=uo%3D4',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://books.apple.com/us/audiobook/id1462355665',
       only_valid_entity_types: ['release'],
  },
  // apple.co
  {
                     input_url: 'http://apple.co/2mXDtEs',
             input_entity_type: 'release',
       input_relationship_type: 'downloadpurchase',
    expected_relationship_type: undefined,
       only_valid_entity_types: [],
  },
  // Apple Music
  {
                     input_url: 'http://music.apple.com/artist/hangry-angry-f/id444923726',
             input_entity_type: 'artist',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
            expected_clean_url: 'https://music.apple.com/us/artist/444923726',
  },
  {
                     input_url: 'https://beta.music.apple.com/ca/artist/imposs/205021452',
             input_entity_type: 'artist',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
            expected_clean_url: 'https://music.apple.com/ca/artist/205021452',
  },
  {
                     input_url: 'https://music.apple.com/us/label/ghostly-international/1543968172',
             input_entity_type: 'label',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
            expected_clean_url: 'https://music.apple.com/us/label/1543968172',
  },
  {
                     input_url: 'https://music.apple.com/ee/music-video/black-and-yellow/539886832?uo=4&mt=5&app=music',
             input_entity_type: 'recording',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
            expected_clean_url: 'https://music.apple.com/ee/music-video/539886832',
  },
  {
                     input_url: 'https://music.apple.com/jp/album/uchiagehanabi-single/1263790414',
             input_entity_type: 'release',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
            expected_clean_url: 'https://music.apple.com/jp/album/1263790414',
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
  // Audiomack
  {
                     input_url: 'http://www.audiomack.com/dablixx-osha',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://audiomack.com/dablixx-osha',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://audiomack.com/dablixx-osha/song/they-cant-understand/',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://audiomack.com/dablixx-osha/song/they-cant-understand',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://audiomack.com/dablixx-osha/album/country-boy#testy',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://audiomack.com/dablixx-osha/album/country-boy',
       only_valid_entity_types: ['release'],
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
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
  },
  {
                     input_url: 'http://baike.baidu.com/subview/738269/15973629.htm',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/subview/738269/15973629.htm',
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
  },
  {
                     input_url: 'https://baike.baidu.com/item/啊呀啦嗦',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/item/啊呀啦嗦',
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
  },
  {
                     input_url: 'https://baike.baidu.com/item/Summer%20Romance%2787/16598351?fromtitle=Summer+Romance&fromid=8735297&type=syn#2',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/item/Summer%20Romance%2787/16598351',
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
  },
  {
                     input_url: 'https://baike.baidu.com/item/王婷萱#1',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://baike.baidu.com/item/王婷萱',
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
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
                     input_url: 'https://bandcamp.com/tag/ambient-noise-wall?tab=highlights',
             input_entity_type: 'genre',
    expected_relationship_type: 'bandcamp',
            expected_clean_url: 'https://bandcamp.com/tag/ambient-noise-wall',
       only_valid_entity_types: ['genre'],
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
  {
                     input_url: 'https://thepenitentman.bandcamp.com/',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'mailorder',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://davidmandelberg.bandcamp.com/',
             input_entity_type: 'release_group',
    expected_relationship_type: undefined,
       input_relationship_type: 'review',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://idiotsikker.bandcamp.com/',
             input_entity_type: 'recording',
    expected_relationship_type: undefined,
       input_relationship_type: 'mailorder',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://gamechops.bandcamp.com/campaign/samus-chill/',
             input_entity_type: 'release',
    expected_relationship_type: 'crowdfunding',
            expected_clean_url: 'https://gamechops.bandcamp.com/campaign/samus-chill',
       only_valid_entity_types: ['release'],
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
  // BBC Events
  {
                     input_url: 'http://bbc.co.uk/events/edhcd4',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.bbc.co.uk/events/edhcd4',
       only_valid_entity_types: ['event'],
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
  {                             // Used to be rejected by validation (MBS-11263)
                     input_url: 'https://www.beatport.com/release/riva-starr-presents-square-pegs-round-holes-5-years-of-snatch%21-sampler/1520186',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.beatport.com/release/riva-starr-presents-square-pegs-round-holes-5-years-of-snatch%21-sampler/1520186',
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
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'http://www.musicofjunior.bigcartel.com?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.musicofjunior.bigcartel.com',
       only_valid_entity_types: ['artist', 'label'],
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
  // Boomplay
  {
                     input_url: 'https://boomplay.com/artists/4334757?srModel=COPYLINK&srList=WEB',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.boomplay.com/artists/4334757',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.boomplay.com/songs/99760140?from=home',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.boomplay.com/songs/99760140',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.boomplay.com/albums/53557880#albumsDetails',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.boomplay.com/albums/53557880',
       only_valid_entity_types: ['release'],
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
                     input_url: 'https://brahms.ircam.fr/fr/anders-hillborg',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://brahms.ircam.fr/anders-hillborg',
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
  // Bugs
  {
                     input_url: 'https://music.bugs.co.kr/album/20488834?wl_ref=M_contents_01_07',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://music.bugs.co.kr/album/20488834',
  },
  {
                     input_url: 'https://m.bugs.co.kr/album/20488834?wl_ref=M_contents_01_07',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://music.bugs.co.kr/album/20488834',
  },
  {
                     input_url: 'https://music.bugs.co.kr/artist/80276288?wl_ref=M_Search_01_01',
             input_entity_type: 'artist',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://music.bugs.co.kr/artist/80276288',
  },
  {
                     input_url: 'https://m.bugs.co.kr/artist/80276288',
             input_entity_type: 'artist',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://music.bugs.co.kr/artist/80276288',
  },
  {
                     input_url: 'https://music.bugs.co.kr/search/integrated?q=dreamcatcher',
             input_entity_type: 'artist',
       input_relationship_type: 'streamingpaid',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://music.bugs.co.kr/search/integrated?q=dreamcatcher',
                expected_error: {
                                  error: 'a link to a search result',
                                  target: 'url',
                                },
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://music.bugs.co.kr/search/album?q=dreamcatcher',
             input_entity_type: 'artist',
       input_relationship_type: 'streamingpaid',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://music.bugs.co.kr/search/album?q=dreamcatcher',
                expected_error: {
                                  error: 'a link to a search result',
                                  target: 'url',
                                },
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://m.bugs.co.kr/search/track?q=dreamcatcher',
             input_entity_type: 'recording',
       input_relationship_type: 'streamingpaid',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://music.bugs.co.kr/search/track?q=dreamcatcher',
                expected_error: {
                                  error: 'a link to a search result',
                                  target: 'url',
                                },
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
            expected_clean_url: 'https://www.cdjapan.co.jp/person/76324',
  },
  {
                     input_url: 'http://cdjapan.co.jp/product/COCC-72267?test',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.cdjapan.co.jp/product/COCC-72267',
  },
  {
                     input_url: 'http://www.cdjapan.co.jp/detailview.html?KEY=LACA-15238',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.cdjapan.co.jp/product/LACA-15238',
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
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/artist/27956.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.classicalarchives.com/newca/#!/Performer/p28471',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/artist/28471.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.classicalarchives.com/composer/2806.html#tvf=tracks&tv=albums',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/composer/2806.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.classicalarchives.com/newca/#!/Composer/3411',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/composer/3411.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.classicalarchives.com/ensemble/10.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/ensemble/10.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'www.classicalarchives.com/newca/#!/Performer/e5425',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/ensemble/5425.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://classicalarchives.com/album/menlo-201409.html?test',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/album/menlo-201409.html',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.classicalarchives.com/newca/#!/Album/21779#',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/newca/#!/Album/21779',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.classicalarchives.com/work/1119282.html',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/work/1119282.html',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'https://www.classicalarchives.com/newca/#!/Work/296312',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.classicalarchives.com/work/296312.html',
       only_valid_entity_types: ['work'],
  },
  // CPDL (Choral Public Domain Library)
  {
                     input_url: 'http://www3.cpdl.org/wiki/index.php/Juan_de_Anchieta',
             input_entity_type: 'artist',
    expected_relationship_type: 'cpdl',
            expected_clean_url: 'http://cpdl.org/wiki/index.php/Juan_de_Anchieta',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://cpdl.org/wiki/index.php/Amor_sei_bei_rubini_(Peter_Philips)',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'www2.cpdl.org/wiki/index.php/Weave_Me_A_Poem_(Tim_Blickhan)',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
            expected_clean_url: 'http://cpdl.org/wiki/index.php/Weave_Me_A_Poem_(Tim_Blickhan)',
       only_valid_entity_types: ['work'],
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
  // DAHR
  {
                     input_url: 'https://adp.library.ucsb.edu/index.php/talent/detail/800/Louis_Armstrong_All-Stars_Musical_group',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://adp.library.ucsb.edu/index.php/talent/detail/800',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://adp.library.ucsb.edu/index.php/mastertalent/detail/113214/Tapley_Daisy',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://adp.library.ucsb.edu/names/113214',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://adp.library.ucsb.edu/names/109217',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://adp.library.ucsb.edu/names/109217',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://adp.library.ucsb.edu/index.php/matrix/refer/2000308570#',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://adp.library.ucsb.edu/index.php/matrix/detail/2000308570',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://adp.library.ucsb.edu/index.php/objects/detail/361259/Ace_of_Hearts_England_AH-73_LP',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://adp.library.ucsb.edu/index.php/objects/detail/361259',
       only_valid_entity_types: ['release'],
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
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.dailymotion.com/video/xyztuvw',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'http://www.dailymotion.com/playlist/xwvuts_who-knows_top/1#video=xyztuvw',
            expected_clean_url: 'https://www.dailymotion.com/video/xyztuvw',
  },
  // Deezer
  {
                     input_url: 'http://www.deezer.com/artist/243332',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.deezer.com/artist/6509511?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.deezer.com/artist/6509511',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://deezer.com/album/8935347',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.deezer.com/album/8935347',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.deezer.com/track/3437226',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.deezer.com/en/episode/3495945',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.deezer.com/episode/3495945',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://www.deezer.com/en/album/497382',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.deezer.com/album/497382',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.deezer.com/profile/18671676',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'streamingfree',
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
  {
                     input_url: 'https://www.discogs.com/genre/funk+%252F+soul',
             input_entity_type: 'genre',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/genre/funk+%252F+soul',
       only_valid_entity_types: ['genre'],
  },
  {
                     input_url: 'https://www.discogs.com/style/hardcore+hip-hop',
             input_entity_type: 'genre',
    expected_relationship_type: 'discogs',
            expected_clean_url: 'https://www.discogs.com/style/hardcore+hip-hop',
       only_valid_entity_types: ['genre'],
  },
  // DNB
  {
                     input_url: 'https://portal.dnb.de/opac.htm?method=simpleSearch&cqlMode=true&query=nid%3D129802433',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/gnd/129802433',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'https://portal.dnb.de/opac.htm?method=simpleSearch&cqlMode=true&query=nid%3D119194901X',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/gnd/119194901X',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'https://portal.dnb.de/opac.htm?method=simpleSearch&cqlMode=true&query=nid%3D4507637-6',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/gnd/4507637-6',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'https://portal.dnb.de/opac/opacPresentation?cqlMode=true&reset=true&referrerPosition=0&referrerResultId=coriolan%26any&query=idn%3D30001502X',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/30001502X',
       only_valid_entity_types: ['artist', 'label', 'place', 'release', 'series', 'work'],
  },
  {
                     input_url: 'https://portal.dnb.de/opac.htm?method=simpleSearch&cqlMode=true&query=idn%3D1227621485',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/1227621485',
       only_valid_entity_types: ['artist', 'label', 'place', 'release', 'series', 'work'],
  },
  {
                     input_url: 'https://d-nb.info/gnd/2026867-1',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/gnd/2026867-1',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://d-nb.info/gnd/1133522467',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/gnd/1133522467',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://d-nb.info/gnd/1100718354',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/gnd/1100718354',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'http://d-nb.info/dnbn/390205699',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/dnbn/390205699',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://d-nb.info/1181136512',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/1181136512',
       only_valid_entity_types: ['artist', 'label', 'place', 'release', 'series', 'work'],
  },
  {
                     input_url: 'http://d-nb.info/97248485X',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://d-nb.info/97248485X',
       only_valid_entity_types: ['artist', 'label', 'place', 'release', 'series', 'work'],
  },
  // Dogmazic
  {
                     input_url: 'https://play.dogmazic.net/artists.php?action=show_all_songs&artist=2283',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://play.dogmazic.net/rss.php?type=podcast&object_type=artist&object_id=2283',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://play.dogmazic.net/batch.php?action=artist&id=2283',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283#labels',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://play.dogmazic.net/song.php?action=show_song&song_id=16660#artists.php?action=show&artist=2283',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://play.dogmazic.net/artists.php?action=show&artist=2283#albums.php?action=show&album=3072',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.dogmazic.net/rss.php?type=podcast&object_type=album&object_id=3072',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.dogmazic.net/shout.php?action=show_add_shout&type=album&id=3072',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.dogmazic.net/batch.php?action=album&id%5B0%5D=3072',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072#',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.dogmazic.net/shout.php?action=show_add_shout&type=label&id=443',
             input_entity_type: 'label',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/labels.php?action=show&label=443',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://play.dogmazic.net/labels.php?action=show&label=443#songs',
             input_entity_type: 'label',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/labels.php?action=show&label=443',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://play.dogmazic.net/song.php?action=show_song&song_id=16660#labels.php?action=show&name=Gauche%20d\'auteur%20(LibQ)',
             input_entity_type: 'label',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/labels.php?action=show&name=Gauche%20d\'auteur%20(LibQ)',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://play.dogmazic.net/albums.php?action=show&album=3072#song.php?action=show_song&song_id=16660',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/song.php?action=show&song_id=16660',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://play.dogmazic.net/shout.php?action=show_add_shout&type=song&id=16660',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/song.php?action=show&song_id=16660',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://play.dogmazic.net/play/index.php?type=song&oid=16660&uid=-1&name=Sophie%20jeukens%20-%20Casse-t-te.mp3',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/song.php?action=show&song_id=16660',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://play.dogmazic.net/stream.php?action=download&song_id=16660',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/song.php?action=show&song_id=16660',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://play.dogmazic.net/song.php?action=show_song&song_id=16660#',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://play.dogmazic.net/song.php?action=show&song_id=16660',
       only_valid_entity_types: ['recording'],
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
  {
                     input_url: 'https://www.facebook.com/searchingforabby',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.facebook.com/searchingforabby',
  },
  {
                     input_url: 'https://www.facebook.com/search/top?q=oxxxymiron',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://www.facebook.com/search/top?q=oxxxymiron',
       input_relationship_type: 'socialnetwork',
       only_valid_entity_types: [],
                expected_error: {
                                  error: 'a link to a search result',
                                  target: 'url',
                                },
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
  // IROMBOOK 私家版楽器事典 (gakki)
  {
                     input_url: 'http://saisaibatake.ame-zaiku.com/gakki/gakki_jiten_accordion.html',
             input_entity_type: 'instrument',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://saisaibatake.ame-zaiku.com/gakki/gakki_jiten_accordion.html',
       only_valid_entity_types: ['instrument'],
  },
  {
                     input_url: 'https://saisaibatake.ame-zaiku.com/gakki_illustration/bass-string-instruments.html',
             input_entity_type: 'instrument',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://saisaibatake.ame-zaiku.com/gakki_illustration/bass-string-instruments.html',
       only_valid_entity_types: ['instrument'],
  },
  {
                     input_url: 'https://saisaibatake.ame-zaiku.com/musical_instrument/gakki_jiten_shrutibox.html',
             input_entity_type: 'instrument',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://saisaibatake.ame-zaiku.com/musical_instrument/gakki_jiten_shrutibox.html',
       only_valid_entity_types: ['instrument'],
  },
  {
                     input_url: 'https://saisaibatake.ame-zaiku.com/musical/instruments_concertina.html',
             input_entity_type: 'instrument',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://saisaibatake.ame-zaiku.com/musical/instruments_concertina.html',
       only_valid_entity_types: ['instrument'],
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
            expected_clean_url: 'https://genius.com/artists/Dramatik',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://genius.com/artists/Universal-music-group',
             input_entity_type: 'label',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://genius.com/artists/Universal-music-group',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://genius.com/artists/Fantasy-studios',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://genius.com/artists/Fantasy-studios',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'http://genius.com/albums/The-dream/Terius-nash-1977',
             input_entity_type: 'release_group',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://genius.com/albums/The-dream/Terius-nash-1977',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://rock.genius.com/The-beatles-she-loves-you-lyrics',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://genius.com/The-beatles-she-loves-you-lyrics',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'http://genius.com/albums/The-dream/Terius-nash-1977',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'discographyentry',
       only_valid_entity_types: [],
                expected_error: {
                                  error: 'at the release group level',
                                  target: 'entity',
                                },
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
  // IdRef
  {
                     input_url: 'http://idref.fr/172248248',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.idref.fr/172248248',
       only_valid_entity_types: ['artist', 'genre', 'instrument', 'label', 'place', 'series', 'work'],
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
            expected_clean_url: 'https://imslp.org/wiki/Category:Buxtehude%2C_Dietrich',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://imslp.org/wiki/Die_Zauberfl%C3%B6te,_K.620_(Mozart,_Wolfgang_Amadeus)',
             input_entity_type: 'work',
    expected_relationship_type: 'score',
            expected_clean_url: 'https://imslp.org/wiki/Die_Zauberfl%C3%B6te,_K.620_(Mozart,_Wolfgang_Amadeus)',
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
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://i.instagram.com/yorickvannorden/?ref=badge',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.instagram.com/yorickvannorden/',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.instagram.com/stories/nathanwpylestrangeplanet/',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.instagram.com/nathanwpylestrangeplanet/',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.instagram.com/stories/nathanwpylestrangeplanet/',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.instagram.com/nathanwpylestrangeplanet/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.instagram.com/p/B3Mew-Cl2Z9/',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.instagram.com/p/B3Mew-Cl2Z9/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.instagram.com/tv/B3Mew-Cl2Z9/?igshid=ekrqbty1ix6c',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.instagram.com/p/B3Mew-Cl2Z9/',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.instagram.com/p/B_7IG9gonk0/',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.instagram.com/p/B_7IG9gonk0/',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.instagram.com/explore/locations/277133756/pacha-club-ibiza/',
             input_entity_type: 'place',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.instagram.com/explore/locations/277133756/pacha-club-ibiza/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.instagram.com/accounts/edit',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.instagram.com/accounts/',
       only_valid_entity_types: [],
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
  // IROMBOOK images (StaticBrainz)
  {
                     input_url: 'https://staticbrainz.org/irombook/sitar/sitar.png',
             input_entity_type: 'instrument',
    expected_relationship_type: 'image',
       only_valid_entity_types: ['instrument'],
  },
  // (Apple) iTunes
  {
                     input_url: 'http://itunes.apple.com/artist/hangry-angry-f/id444923726',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://itunes.apple.com/us/artist/id444923726',
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
            expected_clean_url: 'https://itunes.apple.com/us/music-video/id564322420',
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
            expected_clean_url: 'https://itunes.apple.com/us/album/id589456329',
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
    expected_relationship_type: ['downloadfree', 'streamingfree'],
            expected_clean_url: 'http://www.jamendo.com/track/725574',
  },
  {
                     input_url: 'http://www.jamendo.com/en/list/a84763/crossing-state-lines',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadfree', 'streamingfree'],
            expected_clean_url: 'http://www.jamendo.com/list/a84763',
  },
  {
                     input_url: 'http://www.jamendo.com/en/album/56372',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadfree', 'streamingfree'],
            expected_clean_url: 'http://www.jamendo.com/album/56372',
  },
  // Jazz Music Archives
  {
                     input_url: 'http://www.jazzmusicarchives.com/artist/ron-carter#discography',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.jazzmusicarchives.com/artist/ron-carter',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.jazzmusicarchives.com/artist/peppino-d%E2%80%99agostino',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.jazzmusicarchives.com/artist/peppino-d%E2%80%99agostino',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.jazzmusicarchives.com/album/ron-carter/ron-carter-jack-dejohnette-and-gonzalo-rubalcaba-skyline#specialists-reviews',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.jazzmusicarchives.com/album/ron-carter/ron-carter-jack-dejohnette-and-gonzalo-rubalcaba-skyline',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.jazzmusicarchives.com/album/rita-marcotulli(italy)/summer',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.jazzmusicarchives.com/album/rita-marcotulli(italy)/summer',
       only_valid_entity_types: ['release_group'],
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
  // KBR
  {
                     input_url: 'http://opac.kbr.be/LIBRARY/doc/AUTHORITY/14160974',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://opac.kbr.be/LIBRARY/doc/AUTHORITY/14160974',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://opac.kbr.be/LIBRARY/doc/AUTHORITY/13974166',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://opac.kbr.be/LIBRARY/doc/AUTHORITY/13974166',
       only_valid_entity_types: ['artist', 'label'],
  },
  {
                     input_url: 'https://opac.kbr.be/LIBRARY/doc/SYRACUSE/17060572',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://opac.kbr.be/LIBRARY/doc/SYRACUSE/17060572',
       only_valid_entity_types: ['release'],
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
  // Ko-fi shop (not to autoselect because they could be different purchase options)
  {
                     input_url: 'https://ko-fi.com/s/e953259fd9',
             input_entity_type: 'artist',
            expected_clean_url: 'https://ko-fi.com/s/e953259fd9', // uncleaned
    expected_relationship_type: undefined,
  },
  // laboiteauxparoles
  {
                     input_url: 'https://laboiteauxparoles.com/interprete/269/loco-locass',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://laboiteauxparoles.com/interprete/269',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://laboiteauxparoles.com/titre/55857/wi',
             input_entity_type: 'work',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://laboiteauxparoles.com/titre/55857',
       only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'http://www.laboiteauxparoles.com/auteur/1682',
             input_entity_type: 'artist',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://laboiteauxparoles.com/auteur/1682',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://laboiteauxparoles.com/editeur/140?page=2',
             input_entity_type: 'label',
    expected_relationship_type: 'lyrics',
            expected_clean_url: 'https://laboiteauxparoles.com/editeur/140',
       only_valid_entity_types: ['label'],
  },
  // Lantis
  {
                     input_url: 'http://www.lantis.jp/release-item2.php?id=326c88aa1cd230f96ef350e380a23078',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
            expected_clean_url: 'https://www.lantis.jp/release-item2.php?id=326c88aa1cd230f96ef350e380a23078',
  },
  {
                     input_url: 'http://lantis.jp/release-item/LACM-14937',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
            expected_clean_url: 'https://www.lantis.jp/release-item/LACM-14937.html',
  },
  {
                     input_url: 'https://www.lantis.jp/release-item/LACA-15193.html',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
            expected_clean_url: 'https://www.lantis.jp/release-item/LACA-15193.html',
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
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'https://id.loc.gov/authorities/names/no2016104748.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://id.loc.gov/authorities/names/no2016104748',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
  },
  {
                     input_url: 'https://id.loc.gov/authorities/names/n86864540.html',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://id.loc.gov/authorities/names/n86864540',
       only_valid_entity_types: ['artist', 'label', 'place', 'series', 'work'],
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
            expected_clean_url: 'https://www.linkedin.com/pub/trevor-muzzy/5/282/538',
  },
  {
                     input_url: 'http://ca.linkedin.com/in/didier-charette-0630b1b6?original_referer=https%3A%2F%2Fduckduckgo.com%2F',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.linkedin.com/in/didier-charette-0630b1b6',
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
  // Mainly Norfolk
  {
                     input_url: 'https://www.mainlynorfolk.info/watersons/index.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
limited_link_type_combinations: ['otherdatabases'],
            expected_clean_url: 'https://mainlynorfolk.info/watersons/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.mainlynorfolk.info/martin.carthy/records/themoraloftheelephant.html',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
limited_link_type_combinations: ['otherdatabases'],
            expected_clean_url: 'https://mainlynorfolk.info/martin.carthy/records/themoraloftheelephant.html',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.mainlynorfolk.info/watersons/songs/countrylife.html',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
limited_link_type_combinations: [
                                  'otherdatabases',
                                  ['lyrics', 'otherdatabases'],
                                ],
            expected_clean_url: 'https://mainlynorfolk.info/watersons/songs/countrylife.html',
       only_valid_entity_types: ['work'],
  },
  // maniadb
  {
                     input_url: 'http://www.maniadb.com/artist.asp?p=114569',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.maniadb.com/artist/114569',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.maniadb.com/album.asp?a=736792',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.maniadb.com/album/736792',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.maniadb.com/index.php/album/736792',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.maniadb.com/album/736792',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'http://www.maniadb.com/album/736792/?a=736792',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://www.maniadb.com/album/736792',
       only_valid_entity_types: ['release_group'],
  },
  // Melon
  {
                     input_url: 'https://www.melon.com/album/detail.htm?albumId=11074452#d_cmtpgn',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://www.melon.com/album/detail.htm?albumId=11074452',
  },
  {
                     input_url: 'melon.com/album/detail.htm?albumId=11074452',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://www.melon.com/album/detail.htm?albumId=11074452',
  },
  {
                     input_url: 'https://m2.melon.com/album/music.htm?albumId=11074452',
             input_entity_type: 'release',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://www.melon.com/album/detail.htm?albumId=11074452',
  },
  {
                     input_url: 'https://www.melon.com/artist/timeline.htm?artistId=1284664#params[listType]=C',
             input_entity_type: 'artist',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://www.melon.com/artist/detail.htm?artistId=1284664',
  },
  {
                     input_url: 'https://www.melon.com/artist/album.htm?artistId=1284664',
             input_entity_type: 'artist',
    expected_relationship_type: ['downloadpurchase', 'streamingpaid'],
limited_link_type_combinations: [
                                  ['downloadpurchase', 'streamingpaid'],
                                  'streamingpaid',
                                ],
            expected_clean_url: 'https://www.melon.com/artist/detail.htm?artistId=1284664',
  },
  {
                     input_url: 'https://www.melon.com/search/total/index.htm?q=dreamcatcher',
             input_entity_type: 'artist',
       input_relationship_type: 'streamingpaid',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://www.melon.com/search/total/index.htm?q=dreamcatcher',
                expected_error: {
                                  error: 'a link to a search result',
                                  target: 'url',
                                },
       only_valid_entity_types: [],
  },
  // (The) Metal Archives
  {
                     input_url: 'http://metal-archives.com/artists/Phillip_Gallagher/591782',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.metal-archives.com/artists/Phillip_Gallagher/591782',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://metal-archives.com/artist/view/id/591782',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.metal-archives.com/artist/view/id/591782',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.metal-archives.com/bands/Karna/26483',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.metal-archives.com/bands/Karna/26483',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.metal-archives.com/band/view/id/26483',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.metal-archives.com/band/view/id/26483',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.metal-archives.com/labels/%D0%98%D0%B7%D0%BB%D1%83%D1%87%D0%B5%D0%BD%D0%B8%D1%8F/51751#label_tabs_albums',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.metal-archives.com/labels/%D0%98%D0%B7%D0%BB%D1%83%D1%87%D0%B5%D0%BD%D0%B8%D1%8F/51751',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://www.metal-archives.com/albums/Corubo/Ypykuera/193860',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.metal-archives.com/albums/Corubo/Ypykuera/193860',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.metal-archives.com/reviews/Myrkwid/Part_I/36375/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'review',
            expected_clean_url: 'https://www.metal-archives.com/reviews/Myrkwid/Part_I/36375',
       only_valid_entity_types: ['release_group'],
  },
  // Migu Music
  {
                     input_url: 'https://music.migu.cn/v3/music/artist/5576#J_IntroMore',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://music.migu.cn/v3/music/artist/5576',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://music.migu.cn/v3/music/song/6005752CRFQ',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://music.migu.cn/v3/music/song/6005752CRFQ',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://music.migu.cn/v3/video/mv/600575Y9N2Z?prev=600575Y9FS5',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://music.migu.cn/v3/video/mv/600575Y9N2Z',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://music.migu.cn/v3/live/10338',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://music.migu.cn/v3/live/10338',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://cdnmusic.migu.cn/v3/music/album/1115719717',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://music.migu.cn/v3/music/album/1115719717',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://cdnmusic.migu.cn/v3/music/digital_album/1108035685',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://music.migu.cn/v3/music/album/1108035685',
       only_valid_entity_types: ['release'],
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
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.musik-sammler.de/artist/210311/?view=compact#disco-header',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/artist/210311/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.musik-sammler.de/media/594158',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/release/594158/',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.musik-sammler.de/album/terrorgruppe-melodien-f%C3%BCr-milliarden-56725/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/album/56725/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.musik-sammler.de/album/804508/review/rain/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/album/804508/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'musik-sammler.de/release/594158',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.musik-sammler.de/release/594158/',
       only_valid_entity_types: ['release'],
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
                     input_url: 'http://www.musixmatch.com/album/Bruno-Mars/This-Is-My-Love-Remixes-3#',
             input_entity_type: 'album',
    expected_relationship_type: undefined,
       input_relationship_type: 'lyrics',
            expected_clean_url: 'https://www.musixmatch.com/album/Bruno-Mars/This-Is-My-Love-Remixes-3',
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
  // muziekweb (National Dutch music library)
  {
                     input_url: 'https://www.muziekweb.eu/en/Link/M00000052618/POPULAR/Eminem',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/M00000052618/POPULAR/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/en/Link/M00000238805/CLASSICAL/Michael-Nyman',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/M00000238805/CLASSICAL/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/en/Link/M00000238805/CLASSICAL/COMPOSER/Michael-Nyman',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/M00000238805/CLASSICAL/COMPOSER/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/Link/M00000052618/POPULAR/Eminem',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/M00000052618/POPULAR/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.muziekweb.com/en/Link/L00000003780/CBS-Records',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/L00000003780/',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://www.muziekweb.eu/en/Link/JK95205/The-slim-shady-LP',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/JK95205/',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/Link/JK95205/The-slim-shady-LP',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/JK95205/',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.muziekweb.nl/en/Link/U00001780527/CLASSICAL/Manto-1957',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.muziekweb.nl/Link/U00001780527/CLASSICAL/',
       only_valid_entity_types: ['work'],
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
  // Napster
  {
                     input_url: 'https://es.napster.com/artist/bread#',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://es.napster.com/artist/bread',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://napster.com/artist/bread?ref=spammer',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://us.napster.com/artist/bread',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.napster.com/artist/anuka/album/incomplete-single/track/incomplete-muzzy-remix',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://us.napster.com/artist/anuka/album/incomplete-single/track/incomplete-muzzy-remix',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://fr.napster.com/artist/various-artists/album/70-hits-of-the-70s/track/guitar-man',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://fr.napster.com/artist/various-artists/album/70-hits-of-the-70s/track/guitar-man',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://app.napster.com/artist/banjoory/album/ireggaeular',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://us.napster.com/artist/banjoory/album/ireggaeular',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://us.napster.com/artist/bread/album/the-elektra-years-complete-albums-box',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://us.napster.com/artist/bread/album/the-elektra-years-complete-albums-box',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://napster.com/artist/art.326711648/album/alb.326714896',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://us.napster.com/artist/art.326711648/album/alb.326714896',
       only_valid_entity_types: [],
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
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.nicovideo.jp/watch/sm2916956',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.nicovideo.jp/watch/so26654381?',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.nicovideo.jp/watch/so26654381',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.nicovideo.jp/watch/nm6049209?',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.nicovideo.jp/watch/nm6049209',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.nicovideo.jp/user/1050860/top',
             input_entity_type: 'artist',
    expected_relationship_type: 'videochannel',
            expected_clean_url: 'https://www.nicovideo.jp/user/1050860',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://ch.nicovideo.jp/maverickdci/video?sort=r&order=d',
             input_entity_type: 'label',
    expected_relationship_type: 'videochannel',
            expected_clean_url: 'https://ch.nicovideo.jp/maverickdci',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  // Niconi Commons (excluded from Niconico autoselect)
  {
                     input_url: 'https://commons.nicovideo.jp/material/nc216831',
             input_entity_type: 'recording',
    expected_relationship_type: undefined,
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
  // OC ReMix
  {
                     input_url: 'http://www.ocremix.org/artist/4792/oneup',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ocremix.org/artist/4792',
  },
  {
                     input_url: 'https://ocremix.org/org/2/nintendo',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ocremix.org/org/2',
  },
  {
                     input_url: 'https://ocremix.org/album/46/final-fantasy-vi-balance-and-ruin',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ocremix.org/album/46',
  },
  {
                     input_url: 'https://ocremix.org/remix/OCR00002#tab-details',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ocremix.org/remix/OCR00002',
  },
  {
                     input_url: 'http://ocremix.org/game/512/jade-cocoon-story-of-the-tamamayu-ps1',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ocremix.org/game/512',
  },
  {
                     input_url: 'http://ocremix.org/song/1033',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ocremix.org/song/1033',
  },
  // Offizielle Deutsche Charts
  {
                     input_url: 'http://offiziellecharts.de/album-details-392697/?ref=foo',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.offiziellecharts.de/album-details-392697',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.offiziellecharts.de/titel-details-1917278#collapseOne',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.offiziellecharts.de/titel-details-1917278',
       only_valid_entity_types: ['recording'],
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
                     input_url: 'https://www.operabase.com/artists/megan-esther-grey-101303/en',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://operabase.com/artists/101303',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'operabase.com/venues/united-states/abravanel-hall-5916/en',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://operabase.com/venues/united-states/5916',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'https://www.operabase.com/works/porgupohja-uus-vanapagan-7623/en',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://operabase.com/works/7623',
       only_valid_entity_types: ['work'],
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
  // Overture by Doremus
  {
                     input_url: 'http://overture.doremus.org/artist/dc9b7eb2-7727-3d97-9ea5-7861ac99ea6a',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://overture.doremus.org/artist/dc9b7eb2-7727-3d97-9ea5-7861ac99ea6a',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://overture.doremus.org/performance/aff5ec26-2ba6-3ba5-a535-3eb3e9214987',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://overture.doremus.org/performance/aff5ec26-2ba6-3ba5-a535-3eb3e9214987',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'https://overture.doremus.org/performance?place=Westminster%20Cathedral',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://overture.doremus.org/performance?place=Westminster%20Cathedral',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://overture.doremus.org/expression/3913d018-4c9d-3372-89db-b6dcf1285fa3',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://overture.doremus.org/expression/3913d018-4c9d-3372-89db-b6dcf1285fa3',
       only_valid_entity_types: ['work'],
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
  // RateYourMusic
  {
                     input_url: 'http://www.rateyourmusic.com/artist/johanna_beyer',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/artist/johanna_beyer',
        only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://rateyourmusic.com/concert/riverside_theatre_f1/merzbow_f3',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/concert/riverside_theatre_f1/merzbow_f3',
        only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'https://rateyourmusic.com/genre/avant-prog/',
             input_entity_type: 'genre',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/genre/avant-prog/',
        only_valid_entity_types: ['genre'],
  },
  {
                     input_url: 'https://rateyourmusic.com/label/tzadik/',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/label/tzadik/',
        only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://rateyourmusic.com/venue/auditorium_parco_della_musica/',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/venue/auditorium_parco_della_musica/',
        only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'https://rateyourmusic.com/release/musicvideo/metallica/one/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/release/musicvideo/metallica/one/',
        only_valid_entity_types: ['recording', 'release', 'release_group'],
  },
  {
                     input_url: 'https://rateyourmusic.com/release/single/tori_amos/a_sorta_fairytale/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/release/single/tori_amos/a_sorta_fairytale/',
        only_valid_entity_types: ['release', 'release_group'],
  },
  {
                     input_url: 'https://rateyourmusic.com/release/single/tori_amos/a_sorta_fairytale.p/',
             input_entity_type: 'release',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/release/single/tori_amos/a_sorta_fairytale.p/',
        only_valid_entity_types: ['release', 'release_group'],
  },
  {
                     input_url: 'https://rateyourmusic.com/classifiers/Nonesuch+Explorer+Series/',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/classifiers/Nonesuch+Explorer+Series/',
        only_valid_entity_types: ['series'],
  },
  {
                     input_url: 'https://rateyourmusic.com/work/funktion_violett/',
             input_entity_type: 'work',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/work/funktion_violett/',
        only_valid_entity_types: ['work'],
  },
  {
                     input_url: 'http://rateyourmusic.com/list/hardboiledbabe/women_in_electroacoustic__minimalism__tape_music__musique_concrete__free_improvisation__and_related_genres/',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/list/hardboiledbabe/women_in_electroacoustic__minimalism__tape_music__musique_concrete__free_improvisation__and_related_genres/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://rateyourmusic.com/~IlanFritzler/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/~IlanFritzler/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://rateyourmusic.com/films/ben-collins/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/films/ben-collins/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://rateyourmusic.com/wiki/Music:Columbia+Records/',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://rateyourmusic.com/wiki/Music:Columbia+Records/',
       only_valid_entity_types: [],
  },
  // RecoChoku
  {
                     input_url: 'http://recochoku.jp/artist/2000166063/?affiliate=4350010210',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://recochoku.jp/artist/2000166063/',
  },
  {
                     input_url: 'recochoku.jp/song/S21893898/',
             input_entity_type: 'recording',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://recochoku.jp/song/S21893898/',
  },
  {
                     input_url: 'https://www.recochoku.jp/album/30282664?test',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://recochoku.jp/album/30282664/',
  },
  // Resident Advisor (RA)
  {
                     input_url: 'https://www.ra.co/dj/adamx',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ra.co/dj/adamx',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://ra.co/events/860109#',
             input_entity_type: 'event',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ra.co/events/860109',
       only_valid_entity_types: ['event'],
  },
  {
                     input_url: 'http://ra.co/labels/2795',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ra.co/labels/2795',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://ra.co/clubs/5031/events',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ra.co/clubs/5031',
       only_valid_entity_types: ['place'],
  },
  {
                     input_url: 'https://ra.co/tracks/544258',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ra.co/tracks/544258',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://www.ra.co/reviews/7636',
             input_entity_type: 'release_group',
    expected_relationship_type: 'review',
       input_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://ra.co/reviews/7636',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://ra.co/podcast/491',
             input_entity_type: 'release',
    expected_relationship_type: 'discographyentry',
            expected_clean_url: 'https://ra.co/podcast/491',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.ra.co/exchange/552',
             input_entity_type: 'release',
    expected_relationship_type: 'shownotes',
            expected_clean_url: 'https://ra.co/exchange/552',
       only_valid_entity_types: ['release'],
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
       only_valid_entity_types: ['artist', 'label', 'place'],
  },
  {
                     input_url: 'https://n2t.net/ark:/99166/w6mq170x',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://snaccooperative.org/ark:/99166/w6mq170x',
       only_valid_entity_types: ['artist', 'label', 'place'],
  },
  {
                     input_url: 'https://snaccooperative.org/ark:/99166/w6jh8gmv',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'http://snaccooperative.org/ark:/99166/w6jh8gmv',
       only_valid_entity_types: ['artist', 'label', 'place'],
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
                     input_url: 'https://soundcloud.com/erin-thomson-776648435?utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing',
             input_entity_type: 'artist',
    expected_relationship_type: 'soundcloud',
            expected_clean_url: 'https://soundcloud.com/erin-thomson-776648435',
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
                     input_url: 'https://soundcloud.com/psuhhoteek/lahemaa-lindude-haali-bird-voices-of-lahemaa',
             input_entity_type: 'recording',
limited_link_type_combinations: [
                                  'downloadfree',
                                  'downloadpurchase',
                                  'streamingfree',
                                  'streamingpaid',
                                  ['downloadfree', 'streamingfree'],
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
  },
  {
                     input_url: 'https://soundcloud.com/bei-ping/sets/bei-ping-mafia-cd-2009',
             input_entity_type: 'release',
limited_link_type_combinations: [
                                  'downloadfree',
                                  'downloadpurchase',
                                  'streamingfree',
                                  'streamingpaid',
                                  ['downloadfree', 'streamingfree'],
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
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
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://open.spotify.com/track/7gwRSZ0EmGWa697ZrE58GA',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://open.spotify.com/track/1SI5O5cu8AM19cninxf9RZ',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://open.spotify.com/track/1SI5O5cu8AM19cninxf9RZ',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://open.spotify.com/episode/5yyMb4t3PWlikJNucu9A6Z',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://embed.spotify.com/?uri=spotify:episode:5yyMb4t3PWlikJNucu9A6Z',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://open.spotify.com/episode/5yyMb4t3PWlikJNucu9A6Z',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://play.spotify.com/album/3rFPzWNUrtoqMd9yNGaFMr?play=true&utm_source=open.spotify.com&utm_medium=open',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://open.spotify.com/album/3rFPzWNUrtoqMd9yNGaFMr',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://play.spotify.com/artist/5zS2OG2kKeGYFqX6lcuVOt?play=true&utm_source=google&utm_medium=growth_paid&utm_campaign=pla_US&gclid=CN-m_fOj3cMCFUJk7AodTBsA8g',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://open.spotify.com/artist/5zS2OG2kKeGYFqX6lcuVOt',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'open.spotify.com/album/0tabKG66W34Ms0SsovkP6Q/6yVKnHVFGkg4OQ8IrgQVpZ',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://open.spotify.com/album/0tabKG66W34Ms0SsovkP6Q',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://open.spotify.com/local/Electrolyze/Single/Belief/265',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://play.spotify.com/search/The%20Most%20Essential%20Bossa%20Nova',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
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
                     input_url: 'https://open.spotify.com/user/hitradio%C3%B63',
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://open.spotify.com/user/hitradio%C3%B63',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://open.spotify.com/user/%21k7',
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://open.spotify.com/user/%21k7',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://open.spotify.com/user/testspiel.de',
             input_entity_type: 'label',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://open.spotify.com/user/testspiel.de',
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
  // Target
  {
                     input_url: 'https://www.target.com/b/universal-music-group/-/N-l4bvw',
             input_entity_type: 'label',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.target.com/b/N-l4bvw',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://target.com/p/olivia-rodrigo-sour-target-exclusive-vinyl/-/A-82813217#lnk=sametab',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.target.com/p/A-82813217',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://intl.target.com/p/-/A-79228621',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.target.com/p/A-79228621',
       only_valid_entity_types: ['release'],
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
                     input_url: 'https://thesession.org/sessions/display/432',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://thesession.org/sessions/432',
       only_valid_entity_types: ['place'],
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
  // Tidal
  {
                     input_url: 'http://desktop.tidal.com/artist/8140105',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/artist/8140105',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://desktop.stage.tidal.com/artist/7554203',
             input_entity_type: 'artist',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/artist/7554203',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://tidal.com/#!/track/73579059',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/track/73579059',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://tidal.com/browse/track/87265743?play=true',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/track/87265743',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://listen.tidal.com/album/92616871/track/92616872',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/track/92616872',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'http://listen.tidal.com/video/74314756',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/video/74314756',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'tidal.com/#!/gb/store/album/80921386',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/album/80921386',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.tidal.com/album/191185943',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/album/191185943',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://stage.tidal.com/browse/album/77120747',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingpaid',
            expected_clean_url: 'https://tidal.com/album/77120747',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://store.tidal.com/us/album/58294001',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://store.tidal.com/album/58294001',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://store.tidal.com/ee/artist/160',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://store.tidal.com/artist/160',
       only_valid_entity_types: ['artist'],
  },
  // TikTok
  {
                     input_url: 'http://tiktok.com/@otterchaosuk?is_copy_url=1&is_from_webapp=v1&q=sherzod%20ergashev%20cat&t=1640552004120',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.tiktok.com/@otterchaosuk',
       only_valid_entity_types: ['artist', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.tiktok.com/@officialrandl',
             input_entity_type: 'series',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://www.tiktok.com/@officialrandl',
       only_valid_entity_types: ['artist', 'label', 'place', 'series'],
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
  // Tobar an Dualchais
  {
                     input_url: 'http://tobarandualchais.co.uk/person/5305',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.tobarandualchais.co.uk/person/5305',
  },
  {
                     input_url: 'https://www.tobarandualchais.co.uk/track/39438?l=en',
             input_entity_type: 'recording',
    expected_relationship_type: ['otherdatabases', 'streamingfree'],
            expected_clean_url: 'https://www.tobarandualchais.co.uk/track/39438',
  },
  // Tower
  {
                     input_url: 'http://tower.jp/artist/1372640/%E9%87%8E%E4%B8%AD-%E3%81%BE%E3%81%95-%E9%9B%84%E4%B8%80',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://tower.jp/artist/1372640',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://tower.jp/artist/discography/280635',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://tower.jp/artist/280635',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://tower.jp/item/4458536/%E8%B6%85%E3%83%BB%E5%B0%91%E5%B9%B4%E6%8E%A2%E5%81%B5%E5%9B%A3NEO',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://tower.jp/item/4458536',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://tower.jp/ec/collection/item/summary/4839524',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://tower.jp/item/4839524',
      only_valid_entity_types: ['release'],
  },
  // Traxsource
  {
                     input_url: 'https://www.traxsource.com/artist/584/joey-negro',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.traxsource.com/artist/584',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.traxsource.com/artist/89788/?test',
             input_entity_type: 'artist',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.traxsource.com/artist/89788',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.traxsource.com/title/1141014/tonic-edits-vol-6-the-japan-reworks',
             input_entity_type: 'release',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.traxsource.com/title/1141014',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'http://www.traxsource.com/track/6286240/japanese-woman',
             input_entity_type: 'recording',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.traxsource.com/track/6286240',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.traxsource.com/label/10701?testing',
             input_entity_type: 'label',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.traxsource.com/label/10701',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'http://traxsource.com/label/10701/toy-tonics',
             input_entity_type: 'label',
    expected_relationship_type: 'downloadpurchase',
            expected_clean_url: 'https://www.traxsource.com/label/10701',
       only_valid_entity_types: ['label'],
  },
  {
                     input_url: 'https://www.traxsource.com/spotlight/5/yam-who-s-causing-a-riot',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'downloadpurchase',
       only_valid_entity_types: [],
  },
  // triple j Unearthed
  {
                     input_url: 'http://www.triplejunearthed.com/artist/sampa-great',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.abc.net.au/triplejunearthed/artist/sampa-great',
  },
  {
                     input_url: 'http://abc.net.au/triplejunearthed/artist/sophisticated-dingo/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.abc.net.au/triplejunearthed/artist/sophisticated-dingo/',
  },
  // Tsutaya
  {
                     input_url: 'https://shop.tsutaya.co.jp/cd/product/4562494355418/',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://shop.tsutaya.co.jp/cd/product/4562494355418/',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://shop.tsutaya.co.jp/dir_result.html?searchType=3&artistCd=00133519&artistName=%E7%B1%B3%E6%B4%A5%E7%8E%84%E5%B8%AB',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://shop.tsutaya.co.jp/dir_result.html?searchType=3&artistCd=00133519',
       only_valid_entity_types: ['artist'],
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
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.twitch.tv/videos/1234567890',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'http://twitch.com/pisceze',
             input_entity_type: 'artist',
    expected_relationship_type: 'videochannel',
            expected_clean_url: 'https://www.twitch.tv/pisceze',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
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
                     input_url: 'https://mobile.twitter.com/intent/user?screen_name=emily_doolittle',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://twitter.com/emily_doolittle',
  },
  {
                     input_url: 'https://mobile.twitter.com/intent/user/?screen_name=emily_doolittle',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://twitter.com/emily_doolittle',
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
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://twitter.com/mountain_goats/status/1062342708470132738',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://twitter.com/privacy',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'socialnetwork',
       only_valid_entity_types: [],
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
                     input_url: 'https://vocadb.net/Event/SeriesDetails/16',
             input_entity_type: 'series',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://vocadb.net/Es/16',
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
       only_valid_entity_types: ['artist', 'place'],
  },
  {
                     input_url: 'http://vgmdb.net/artist/39968',
             input_entity_type: 'place',
    expected_relationship_type: 'vgmdb',
            expected_clean_url: 'https://vgmdb.net/artist/39968',
       only_valid_entity_types: ['artist', 'place'],
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
  {
                     input_url: 'https://vgmdb.net/product/8301',
             input_entity_type: 'work',
    expected_relationship_type: 'vgmdb',
            expected_clean_url: 'https://vgmdb.net/product/8301',
       only_valid_entity_types: ['work'],
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
                     input_url: 'http://viaf.org/viaf/154643080',
             input_entity_type: 'series',
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
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://vimeo.com/1109226',
  },
  {
                     input_url: 'https://vimeo.com/ondemand/inconcert/193518106?autoplay=1',
            expected_clean_url: 'https://vimeo.com/ondemand/inconcert',
             input_entity_type: 'recording',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
       input_relationship_type: 'downloadpurchase',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://vimeo.com/ondemand/inconcert#comments',
            expected_clean_url: 'https://vimeo.com/ondemand/inconcert',
             input_entity_type: 'recording',
limited_link_type_combinations: [
                                  'downloadpurchase',
                                  'streamingpaid',
                                  ['downloadpurchase', 'streamingpaid'],
                                ],
       input_relationship_type: 'streamingpaid',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://vimeo.com/store/ondemand/buy/91410',
             input_entity_type: 'recording',
    expected_relationship_type: undefined,
       input_relationship_type: 'downloadpurchase',
       only_valid_entity_types: [],
  },
  // Vine
  {
                     input_url: 'https://vine.co/destorm',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
  },
  // VK
  {
                     input_url: 'http://vk.com/tin_sontsya',
             input_entity_type: 'artist',
    expected_relationship_type: 'socialnetwork',
            expected_clean_url: 'https://vk.com/tin_sontsya',
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
                     input_url: 'https://www.whosampled.com/Death-Grips/',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/Death-Grips/',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'http://www.whosampled.com/Just-to-Get-a-Rep/Gang-Starr/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/Just-to-Get-a-Rep/Gang-Starr/',
       only_valid_entity_types: ['recording'],
  },
  {
                     input_url: 'https://www.whosampled.com/album/Pet-Shop-Boys/Very/',
             input_entity_type: 'release_group',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/album/Pet-Shop-Boys/Very/',
       only_valid_entity_types: ['release_group'],
  },
  {
                     input_url: 'https://www.whosampled.com/Pet-Shop-Boys/Can-You-Forgive-Her?/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/Pet-Shop-Boys/Can-You-Forgive-Her?/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.whosampled.com/cover/575868/Ghost-It%27s-a-Sin-Pet-Shop-Boys-It%27s-a-Sin/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/cover/575868/Ghost-It%27s-a-Sin-Pet-Shop-Boys-It%27s-a-Sin/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.whosampled.com/remix/43901/Pet-Shop-Boys-Can-You-Forgive-Her%3F-(Rollo-Dub)-Pet-Shop-Boys-Can-You-Forgive-Her%3F/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/remix/43901/Pet-Shop-Boys-Can-You-Forgive-Her%3F-(Rollo-Dub)-Pet-Shop-Boys-Can-You-Forgive-Her%3F/',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.whosampled.com/sample/127347/Death-Grips-5D-Pet-Shop-Boys-West-End-Girls/',
             input_entity_type: 'recording',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.whosampled.com/sample/127347/Death-Grips-5D-Pet-Shop-Boys-West-End-Girls/',
       only_valid_entity_types: [],
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
                     input_url: 'https://www.wikidata.org/wiki/Q11366',
             input_entity_type: 'genre',
            expected_clean_url: 'https://www.wikidata.org/wiki/Q11366',
    expected_relationship_type: 'wikidata',
  },
  {
                     input_url: 'http://www.example.org/not/wikidata.org',
       input_relationship_type: 'wikidata',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.wikidata.org/wiki/Q42',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
       input_relationship_type: 'discographyentry',
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
                expected_error: {
                                  error: 'no entries for specific releases',
                                  target: 'entity',
                                },
  },
  {
                     input_url: 'https://en.wikipedia.org/wiki/User:JackDormantPress/By_The_Rivers_(band)',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'wikipedia',
       only_valid_entity_types: [],
                expected_error: {
                                  error: 'Wikipedia user pages are not allowed',
                                  target: 'url',
                                },
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
       only_valid_entity_types: ['artist', 'label', 'release_group', 'work'],
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
  {
                     input_url: 'http://www.worldcat.org/identities/lccn-n50005018',
             input_entity_type: 'label',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.worldcat.org/identities/lccn-n50005018/',
  },
  {
                     input_url: 'http://worldcat.org/identities/lccn-n79081635/',
             input_entity_type: 'place',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.worldcat.org/identities/lccn-n79081635/',
  },
  {
                     input_url: 'https://www.worldcat.org/wcidentities/lccn-n94-9040',
             input_entity_type: 'artist',
    expected_relationship_type: 'otherdatabases',
            expected_clean_url: 'https://www.worldcat.org/identities/lccn-n94-9040/',
  },
  // YesAsia
  {
                     input_url: 'https://www.yesasia.com/global/twice-korea/0-aid3437787-0-bpt.47-zh_TW/list.html',
             input_entity_type: 'artist',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.yesasia.com/0-aid3437787-0-bpt.47-en/list.html',
       only_valid_entity_types: ['artist'],
  },
  {
                     input_url: 'https://www.yesasia.com/global/twice-vol-3-formula-of-love-o-t-3-random-version-random-photo-card/1107024843-0-0-0-ja/info.html#zh_CN',
             input_entity_type: 'release',
    expected_relationship_type: 'mailorder',
            expected_clean_url: 'https://www.yesasia.com/1107024843-0-0-0-en/info.html',
       only_valid_entity_types: ['release'],
  },
  // YouTube
  {
                     input_url: 'http://youtube.com/user/officialpsy/videos',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/officialpsy',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'http://m.youtube.com/#/user/JessVincentMusic',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/JessVincentMusic',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.youtube.com/user/JessVincentMusic?feature=watch',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/JessVincentMusic',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'http://www.youtube.com/embed/UmHdefsaL6I',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.youtube.com/watch?v=UmHdefsaL6I',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'http://youtube.com/user/officialpsy/videos',
             input_entity_type: 'label',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/user/officialpsy',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.youtube.com/c/communitymusiclearning/about?view_as=subscriber',
             input_entity_type: 'label',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/communitymusiclearning',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.youtube.com/channel/UCKG8UEfkMG_86SaCkapjTMQ/featured?view_as=subscriber',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/channel/UCKG8UEfkMG_86SaCkapjTMQ',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'http://youtu.be/UmHdefsaL6I',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.youtube.com/watch?v=UmHdefsaL6I',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.youtube.com/watch?v=4eUqsUZBluA&list=PLkHWBeudCLJCjB41Yt1iiain82Lp1zQOB',
             input_entity_type: 'recording',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.youtube.com/watch?v=4eUqsUZBluA',
       only_valid_entity_types: ['recording', 'release'],
  },
  {
                     input_url: 'https://www.youtube.com/playlist?list=PLnbecBgjL4QQtjDRyHD99b6xWjLD3i9r5',
             input_entity_type: 'release',
    expected_relationship_type: 'streamingfree',
            expected_clean_url: 'https://www.youtube.com/playlist?list=PLnbecBgjL4QQtjDRyHD99b6xWjLD3i9r5',
       only_valid_entity_types: ['release'],
  },
  {
                     input_url: 'https://www.youtube.com/c/MetaBrainz',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/MetaBrainz',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.youtube.com/@MetaBrainz#soon',
             input_entity_type: 'label',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/@MetaBrainz',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.youtube.com/playlist?list=PL43OynbWaTMKSxLVnUF0HbHHiXEgAVm3Q',
             input_entity_type: 'series',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/playlist?list=PL43OynbWaTMKSxLVnUF0HbHHiXEgAVm3Q',
       only_valid_entity_types: ['series'],
  },
  {
                     input_url: 'https://www.youtube.com/playlist?playnext=1&list=PLlmo--SLJW2SstbkGcxEOPsmFdm3u49xJ&feature=gws_kp_artist',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://www.youtube.com/playlist?list=PLlmo--SLJW2SstbkGcxEOPsmFdm3u49xJ',
       input_relationship_type: 'youtube',
       only_valid_entity_types: ['series'],
                expected_error: {
                                  error: 'is a playlist link',
                                  target: 'url',
                                },
  },
  {
                     input_url: 'https://music.youtube.com/browse/MPREb_0bOFkwXrX2x',
             input_entity_type: 'release',
    expected_relationship_type: undefined,
            expected_clean_url: 'https://music.youtube.com/browse/MPREb_0bOFkwXrX2x',
       input_relationship_type: 'youtube',
       only_valid_entity_types: [],
  },
  {
                     input_url: 'https://www.youtube.com/resultsarein',
             input_entity_type: 'artist',
    expected_relationship_type: 'youtube',
            expected_clean_url: 'https://www.youtube.com/resultsarein',
       only_valid_entity_types: ['artist', 'event', 'label', 'place', 'series'],
  },
  {
                     input_url: 'https://www.youtube.com/results?search_query=oxxxymiron',
             input_entity_type: 'artist',
    expected_relationship_type: undefined,
       input_relationship_type: 'youtube',
       only_valid_entity_types: [],
                expected_error: {
                                  error: 'a link to a search result',
                                  target: 'url',
                                },
  },
];
/* eslint-enable indent, max-len, sort-keys */

const relationshipTypesByUuid = Object.entries(LINK_TYPES).reduce(function (
  results,
  [relationshipType, relUuidByEntityType],
) {
  for (const relUuid of Object.values(relUuidByEntityType)) {
    results[relUuid] = relationshipType;
  }
  return results;
}, {});

const previousMatchTests = [];
const previousTypeCombinationTests = [];

function doMatchSubtest(
  st,
  entityType,
  url,
  label,
  expectedRelationshipType,
) {
  const checker = new Checker(cleanURL(url), entityType);
  const relUuid = checker.guessType();
  const expectSingleType = typeof expectedRelationshipType !== 'object'; // string or undefined
  let actualRelationshipType = relUuid || undefined;
  if (relUuid) {
    if (typeof relUuid === 'string') { // Single type
      if (relationshipTypesByUuid[relUuid]) {
        actualRelationshipType = relationshipTypesByUuid[relUuid];
      }
    } else { // Type combination
      const relationshipTypes = relUuid.reduce(function (accum, uuid) {
        if (relationshipTypesByUuid[uuid]) {
          accum.push(relationshipTypesByUuid[uuid]);
        }
        return accum;
      }, []);
      if (relationshipTypes.length > 0) {
        actualRelationshipType = relationshipTypes;
      }
    }
  }
  if (expectedRelationshipType === undefined) {
    actualRelationshipType = undefined;
  }

  const msg = 'Match ' + label + ' URL relationship type for ' +
  entityType + ' entities';
  if (expectSingleType) {
    st.equal(
      actualRelationshipType,
      expectedRelationshipType,
      msg,
    );
  } else {
    st.ok(
      arraysEqual(
        actualRelationshipType.sort(),
        expectedRelationshipType.sort(),
      ),
      msg,
    );
  }
  previousMatchTests.push(entityType + '+' + url);
}

function doRestrictSubtest(
  st,
  entityType,
  url,
  label,
  expectedTypeCombinations,
) {
  const checker = new Checker(cleanURL(url), entityType);
  const possibleTypeCombinations = checker.getPossibleTypes();
  let actualTypeCombinations = possibleTypeCombinations || undefined;
  if (expectedTypeCombinations === undefined) {
    actualTypeCombinations = undefined;
  }

  // Each combination can be just 1 relationship type, or an array of 2+ types
  const typeCombinations = possibleTypeCombinations.map(typeSet => {
    let typeNames;
    if (Array.isArray(typeSet)) {
      typeNames = typeSet.map(uuid => relationshipTypesByUuid[uuid]).sort();
    } else {
      typeNames = relationshipTypesByUuid[typeSet];
    }
    return typeNames;
  });

  if (typeCombinations.length > 0) {
    actualTypeCombinations = typeCombinations;
  }

  const msg = 'Match ' + label + ' URL relationship type combinations for ' +
    entityType + ' entities';
  st.ok(
    arraysEqual(
      actualTypeCombinations.sort(),
      expectedTypeCombinations.sort(),
      (a, b) => {
        if (Array.isArray(a) && Array.isArray(b)) {
          return arraysEqual(a, b);
        } else if (typeof a === typeof b) {
          return a === b;
        }
        return false;
      },
    ),
    msg,
  );
  previousTypeCombinationTests.push(entityType + '+' + url);
}

// Test the url with given relationship type combined with every entity.
function testEntitiesOfType(relationshipType, checker) {
  let testedRules = 0;
  const results = Object.entries(LINK_TYPES[relationshipType])
    .reduce(
      function (results, [entityType, relUuid]) {
        const isValid = checker.checkRelationship(relUuid, entityType).result;
        results[isValid].push(entityType);
        ++testedRules;
        return results;
      },
      {false: [], true: []},
    );
  return {results, testedRules};
}

// Test whether the error message end target matches what is expected
function testErrorObject(subtest, relationshipType, st) {
  const actualCleanUrl = cleanURL(subtest.input_url);
  const cleanUrl = subtest.expected_clean_url || actualCleanUrl;
  const checker = new Checker(cleanUrl, subtest.input_entity_type);
  const validationResult = checker.checkRelationship(
    LINK_TYPES[relationshipType][subtest.input_entity_type],
    subtest.input_entity_type,
  );
  if (subtest.expected_error.error === undefined) {
    st.ok(
      validationResult.error === undefined,
      'Default error message will be used as expected',
    );
  } else {
    st.ok(
      validationResult.error &&
        validationResult.error.includes(subtest.expected_error.error),
      'Error message contains expected string',
    );
  }
  st.equal(
    validationResult.target,
    subtest.expected_error.target,
    'Error target matches expected target',
  );
}

testData.forEach(function (subtest, i) {
  test('input URL [' + i + '] = ' + subtest.input_url, {}, function (st) {
    let tested = false;
    if (!subtest.input_url) {
      st.fail(
        'Test is invalid: "input_url" is missing: ' + JSON.stringify(subtest),
      );
      st.end();
      return;
    }
    if (subtest.input_entity_type) {
      if ('expected_relationship_type' in subtest) {
        if (previousMatchTests.indexOf(
          subtest.input_entity_type + '+' + subtest.input_url,
        ) !== -1) {
          st.fail(
            'Match test is worthless: Duplication has been detected: ' +
            JSON.stringify(subtest),
          );
        }
        doMatchSubtest(
          st,
          subtest.input_entity_type,
          subtest.input_url,
          'input',
          subtest.expected_relationship_type,
        );
        tested = true;
      }
      if ('limited_link_type_combinations' in subtest) {
        if (previousTypeCombinationTests.indexOf(
          subtest.input_entity_type + '+' + subtest.input_url,
        ) !== -1) {
          st.fail(
            'Match test is worthless: Duplication has been detected: ' +
            JSON.stringify(subtest),
          );
        }
        doRestrictSubtest(
          st,
          subtest.input_entity_type,
          subtest.input_url,
          'input',
          subtest.limited_link_type_combinations,
        );
        tested = true;
      }
      if (!('expected_relationship_type' in subtest) &&
          !('limited_link_type_combinations' in subtest) &&
          !('expected_error' in subtest)) {
        st.fail(
          `Test is invalid: "input_entity_type" is specified without
           "expected_relationship_type", "expected_error"
           nor "limited_link_type_combinations".`,
        );
        st.end();
        return;
      }
    } else if ('expected_relationship_type' in subtest) {
      st.fail(
        'Test is invalid: "expected_relationship_type" is specified without "input_entity_type".',
      );
      st.end();
      return;
    } else if ('limited_link_type_combinations' in subtest) {
      st.fail(
        `Test is invalid: "limited_link_type_combinations"
         is specified without "input_entity_type".`,
      );
      st.end();
      return;
    }
    const actualCleanUrl = cleanURL(subtest.input_url);
    if (subtest.expected_clean_url) {
      st.equal(actualCleanUrl, subtest.expected_clean_url, 'Clean up');
      if (subtest.input_entity_type &&
          'expected_relationship_type' in subtest &&
          previousMatchTests.indexOf(
            subtest.input_entity_type + '+' + subtest.expected_clean_url,
          ) === -1) {
        doMatchSubtest(
          st,
          subtest.input_entity_type,
          subtest.expected_clean_url,
          'clean',
          subtest.expected_relationship_type,
        );
      }
      tested = true;
    }
    if (subtest.input_relationship_type && !subtest.only_valid_entity_types) {
      st.fail(
        'Test is invalid: "input_relationship_type" is specified without "only_valid_entity_types" array.',
      );
      st.end();
      return;
    }
    if (subtest.only_valid_entity_types) {
      const relationshipType = subtest.input_relationship_type ||
        subtest.expected_relationship_type;
      const cleanUrl = subtest.expected_clean_url || actualCleanUrl;
      if (!relationshipType) {
        st.fail(
          'Test is invalid: "only_valid_entity_types" are specified with neither "expected_relationship_type" nor "input_relationship_type".',
        );
        st.end();
        return;
      }
      let validationResults = {false: [], true: []};
      let nbTestedRules = 0;
      const checker = new Checker(cleanUrl, subtest.input_entity_type);
      if (typeof relationshipType === 'object') { // Type combination
        relationshipType.forEach(function (type) {
          const {results, testedRules} = testEntitiesOfType(type, checker);
          validationResults.true =
            validationResults.true.concat(results.true);
          validationResults.false =
            validationResults.false.concat(results.false);
          nbTestedRules += testedRules;
        });
      } else { // Single type
        const {results, testedRules} =
          testEntitiesOfType(relationshipType, checker);
        validationResults = results;
        nbTestedRules = testedRules;
      }
      if (nbTestedRules === 0) {
        st.fail(
          'Validation test is worthless: No validation rule has been actually tested.',
        );
      } else {
        // Use Set to remove duplicates when there're multiple types
        const acceptedEntityTypes = Array.from(
          new Set(validationResults.true),
        ).sort();
        st.deepEqual(
          acceptedEntityTypes,
          subtest.only_valid_entity_types.sort(),
          'Validate clean URL by exactly ' +
            subtest.only_valid_entity_types.length +
            ' among ' + nbTestedRules + ' ' + relationshipType + '.* rules',
        );
        tested = true;
      }
    }
    if (subtest.expected_error) {
      const relationshipType = subtest.input_relationship_type ||
        subtest.expected_relationship_type;
      if (!relationshipType) {
        st.fail(
          'Test is invalid: "expected_error" is specified with neither "expected_relationship_type" nor "input_relationship_type".',
        );
        st.end();
        return;
      }
      if (!subtest.input_entity_type) {
        st.fail(
          'Test is invalid: "expected error" is specified without "input_entity_type".',
        );
        st.end();
        return;
      }
      testErrorObject(subtest, relationshipType, st);
      tested = true;
    }
    if (!tested) {
      st.fail('Test is worthless: Nothing has been actually tested.');
    }
    st.end();
  });
});
