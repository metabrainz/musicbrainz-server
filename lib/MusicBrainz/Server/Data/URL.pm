package MusicBrainz::Server::Data::URL;
use Moose;
use namespace::autoclean;

use Carp;
use List::AllUtils qw( pairs reduce );
use MusicBrainz::Server::Data::Utils qw( generate_gid hash_to_row );
use MusicBrainz::Server::Entity::URL;
use URI;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Relatable',
     'MusicBrainz::Server::Data::Role::GIDRedirect',
     'MusicBrainz::Server::Data::Role::PendingEdits' => { table => 'url' },
     'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'url' },
     'MusicBrainz::Server::Data::Role::Merge';

sub _type { 'url' }

my $URL_SPECIALIZATIONS = reduce {
    my $result = $a;
    my ($class, $entry) = @$b;

    my $hostname = delete $entry->{hostname};
    $entry->{class} = $class;

    if (ref $hostname eq 'ARRAY') {
        push @{ $result->{$_} }, $entry for @$hostname;
    } else {
        push @{ $result->{$hostname} }, $entry;
    }

    $result;
} {}, pairs (

    # A mapping of specialized `Entity::URL::*` Perl class names to their
    # hostnames, plus other optional patterns that the URL must match to
    # be assigned that class.
    #
    # The `reduce` above inverts this mapping to allow for lookups
    # by hostname. (A hostname may map to multiple classes, so the first
    # one that matches is used; see `_find_url_specialization` for the
    # exact logic used.)
    #
    # Full description of the data structure below:
    #
    # Key:   The name of the Perl class under
    #        `MusicBrainz::Server::Entity::URL::*`.
    #
    # Value: A hash ref containing:
    #          - `hostname`
    #            A string, or an array ref of hostname strings. These must
    #            match the hostname in the URL exactly, with the following
    #            exceptions: `www` is always stripped from the URL before
    #            a hostname lookup, so it shouldn't be included; and the
    #            `subdomains` option below more generally allows for the
    #            first subdomain of the URL to be ignored.
    #
    #          - `subdomains`
    #            A boolean indicating that the hostname(s) should allow
    #            matching against various unspecified subdomains.
    #            Examples of where this is used include Wikipedia
    #            (language codes) and Bandcamp (artist subdomains).
    #
    #          - `path`
    #            A regular expression that that URL's path part (beginning
    #            with `/`) must match.
    #
    #          - `url`
    #            A regular expression that the entire URL must match.

    # External links section
    '7digital'              => { hostname   => ['7digital.com', 'zdigital.com.au'],
                                 subdomains => 1 },
    '45cat'                 => { hostname   => '45cat.com' },
    'ACUM'                  => { hostname   => 'nocs.acum.org.il' },
    'Allmusic'              => { hostname   => 'allmusic.com' },
    'AlloCine'              => { hostname   => 'allocine.fr' },
    'AmazonMusic'           => { hostname   => [ map { "music.amazon.$_" } qw( ca co.jp co.uk com com.au com.br com.mx de es fr in it ) ] },
    'Anghami'               => { hostname   => [ qw( anghami.com open.anghami.com play.anghami.com) ] },
    'AniDB'                 => { hostname   => 'anidb.net' },
    'AniList'               => { hostname   => 'anilist.co' },
    'AnimeNewsNetwork'      => { hostname   => 'animenewsnetwork.com' },
    'AnisonGeneration'      => { hostname   => 'anison.info' },
    'AppleBooks'            => { hostname   => 'books.apple.com' },
    'AppleClassical'        => { hostname   => 'classical.music.apple.com' },
    'AppleMusic'            => { hostname   => 'music.apple.com' },
    'ArchivesDuSpectacle'   => { hostname   => 'lesarchivesduspectacle.net' },
    'ASIN'                  => { hostname   => [ map { "amazon.$_" } qw( ae ca cn co.jp co.uk com com.au com.be com.br com.mx com.tr de eg es fr ie in it nl pl sa se sg ) ],
                                 url        => qr{^https?://(?:www\.)?amazon(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i },
    'Audiomack'             => { hostname   => 'audiomack.com' },
    'AWA'                   => { hostname   => 's.awa.fm' },
    'BaiduBaike'            => { hostname   => 'baike.baidu.com' },
    'Bandcamp'              => { hostname   => 'bandcamp.com',
                                 subdomains => 1 },
    'Bandsintown'           => { hostname   => 'bandsintown.com' },
    'Beatport'              => { hostname   => 'beatport.com' },
    'BigCartel'             => { hostname   => 'bigcartel.com',
                                 subdomains => 1 },
    'Bluesky'               => { hostname   => 'bsky.app' },
    'BnFCatalogue'          => { hostname   => 'catalogue.bnf.fr' },
    'BookBrainz'            => { hostname   => 'bookbrainz.org' },
    'Boomkat'               => { hostname   => 'boomkat.com' },
    'Boomplay'              => { hostname   => 'boomplay.com' },
    'BrahmsIrcam'           => { hostname   => 'brahms.ircam.fr' },
    'Bugs'                  => { hostname   => 'music.bugs.co.kr' },
    'Canzone'               => { hostname   => 'discografia.dds.it' },
    'Cancioneros'           => { hostname   => 'cancioneros.si' },
    'Castalbums'            => { hostname   => 'castalbums.org' },
    'CBFiddleRx'            => { hostname   => 'cbfiddle.com',
                                 path       => qr{^/rx} },
    'CcMixter'              => { hostname   => 'ccmixter.org' },
    'CDJapan'               => { hostname   => 'cdjapan.co.jp' },
    'ChangeTip'             => { hostname   => 'changetip.com',
                                 path       => qr{^/tipme}i },
    'CiNii'                 => { hostname   => 'ci.nii.ac.jp' },
    'ClassicalArchives'     => { hostname   => 'classicalarchives.com' },
    'Commons'               => { hostname   => 'commons.wikimedia.org',
                                 path       => qr{^/wiki/File:}i },
    'CPDL'                  => { hostname   => 'cpdl.org',
                                 path       => qr{^/wiki}i },
    'DAHR'                  => { hostname   => 'adp.library.ucsb.edu' },
    'Dailymotion'           => { hostname   => 'dailymotion.com' },
    'DanceDB'               => { hostname   => 'tedcrane.com',
                                 path       => qr{^/DanceDB}i },
    'Deezer'                => { hostname   => 'deezer.com' },
    'DeviantArt'            => { hostname   => 'deviantart.com' },
    'DHHU'                  => { hostname   => 'dhhu.dk' },
    'Discogs'               => { hostname   => 'discogs.com' },
    'DiscosDoBrasil'        => { hostname   => ['discografia.discosdobrasil.com.br', 'discosdobrasil.com.br'] },
    'Dogmazic'              => { hostname   => 'play.dogmazic.net' },
    'DNB'                   => { hostname   => 'd-nb.info' },
    'DRAM'                  => { hostname   => 'dramonline.org' },
    'DynamicRangeDB'        => { hostname   => 'dr.loudness-war.info' },
    'Encyclopedisque'       => { hostname   => 'encyclopedisque.fr' },
    'EOnkyo'                => { hostname   => 'e-onkyo.com' },
    'ESTER'                 => { hostname   => 'ester.ee' },
    'Facebook'              => { hostname   => 'facebook.com' },
    'Finna'                 => { hostname   => 'finna.fi' },
    'Finnmusic'             => { hostname   => 'finnmusic.net' },
    'FolkWiki'              => { hostname   => 'folkwiki.se' },
    'FonoFi'                => { hostname   => 'fono.fi' },
    'Gakki'                 => { hostname   => 'saisaibatake.ame-zaiku.com',
                                 path       => qr{^/(?:gakki|musical|musical_instrument)}i },
    'Generasia'             => { hostname   => 'generasia.com',
                                 path       => qr{^/wiki}i },
    'Genie'                 => { hostname   => 'genie.co.kr' },
    'Genius'                => { hostname   => 'genius.com' },
    'GeoNames'              => { hostname   => 'sws.geonames.org' },
    'Goodreads'             => { hostname   => 'goodreads.com' },
    'Gutenberg'             => { hostname   => 'gutenberg.org' },
    'HMikuWiki'             => { hostname   => ['w.atwiki.jp', 'www5.atwiki.jp'],
                                 path       => qr{^/hmiku}i },
    'HMVBooks'              => { hostname   => 'hmv.co.jp' },
    'Hoerspielforscher'     => { hostname   => 'hoerspielforscher.de' },
    'Hoick'                 => { hostname   => 'hoick.jp' },
    'IBDb'                  => { hostname   => 'ibdb.com' },
    'IdRef'                 => { hostname   => 'idref.fr' },
    'IMDb'                  => { hostname   => 'imdb.com' },
    'IMSLP'                 => { hostname   => 'imslp.org',
                                 path       => qr{^/wiki}i },
    'IMVDb'                 => { hostname   => 'imvdb.com' },
    'IOBDb'                 => { hostname   => 'lortel.org' },
    'Indiegogo'             => { hostname   => 'indiegogo.com' },
    'Instagram'             => { hostname   => 'instagram.com' },
    'InternetArchive'       => { hostname   => 'archive.org',
                                 path       => qr{^/details}i },
    'IrishTune'             => { hostname   => 'irishtune.info' },
    'ISRCTW'                => { hostname   => 'isrc.ncl.edu.tw' },
    'iTunes'                => { hostname   => 'itunes.apple.com' },
    'Jamendo'               => { hostname   => 'jamendo.com' },
    'Japameta'              => { hostname   => 'japanesemetal.gooside.com' },
    'JazzMusicArchives'     => { hostname   => 'jazzmusicarchives.com' },
    'JLyric'                => { hostname   => 'j-lyric.net' },
    'Joysound'              => { hostname   => 'joysound.com' },
    'Kashinavi'             => { hostname   => 'kashinavi.com' },
    'KBR'                   => { hostname   => 'opac.kbr.be' },
    'Kickstarter'           => { hostname   => 'kickstarter.com' },
    'KKBOX'                 => { hostname   => 'kkbox.com' },
    'Kofi'                  => { hostname   => 'ko-fi.com' },
    'Lantis'                => { hostname   => 'lantis.jp' },
    'LastFM'                => { hostname   => 'last.fm' },
    'LibraryThing'          => { hostname   => 'librarything.com' },
    'LibriVox'              => { hostname   => 'librivox.org' },
    'Lieder'                => { hostname   => 'lieder.net' },
    'LineMusic'             => { hostname   => 'music.line.me' },
    'LinkedIn'              => { hostname   => 'linkedin.com',
                                 subdomains => 1 },
    'LiveFans'              => { hostname   => 'livefans.jp' },
    'LiveNation'            => { hostname   => [ map { "livenation.$_" } qw( asia at be ch co.jp co.nz co.th co.uk com com.au com.br com.tw cz de dk es fi fr hk hu it kr lat me my nl no ph pl pt se sg ) ] },
    'LoC'                   => { hostname   => 'loc.gov',
                                 subdomains => 1 },
    'Loudr'                 => { hostname   => 'loudr.fm' },
    'MainlyNorfolk'         => { hostname   => 'mainlynorfolk.info' },
    'Maniadb'               => { hostname   => 'maniadb.com' },
    'Melon'                 => { hostname   => 'melon.com' },
    'Metacritic'            => { hostname   => 'metacritic.com' },
    'MetalArchives'         => { hostname   => 'metal-archives.com' },
    'MetalMusicArchives'    => { hostname   => 'metalmusicarchives.com' },
    'MiguMusic'             => { hostname   => 'music.migu.cn' },
    'Mixcloud'              => { hostname   => 'mixcloud.com' },
    'MixesDB'               => { hostname   => 'mixesdb.com' },
    'MobyGames'             => { hostname   => 'mobygames.com' },
    'Mora'                  => { hostname   => 'mora.jp' },
    'MusicaPopularCl'       => { hostname   => 'musicapopular.cl' },
    'MusicInAfrica'         => { hostname   => 'musicinafrica.net' },
    'MusicMoz'              => { hostname   => 'musicmoz.org' },
    'MusikSammler'          => { hostname   => 'musik-sammler.de' },
    'Musixmatch'            => { hostname   => 'musixmatch.com' },
    'Musopen'               => { hostname   => 'musopen.org' },
    'Muziekweb'             => { hostname   => 'muziekweb.nl' },
    'Muzikum'               => { hostname   => 'muzikum.eu' },
    'MVDbase'               => { hostname   => 'mvdbase.com' },
    'MyAnimeList'           => { hostname   => 'myanimelist.net' },
    'MySpace'               => { hostname   => 'myspace.com' },
    'NaverVibe'             => { hostname   => 'vibe.naver.com' },
    'NDL'                   => { hostname   => 'iss.ndl.go.jp' },
    'NDLAuthorities'        => { hostname   => 'id.ndl.go.jp' },
    'NicoNicoVideo'         => { hostname   => 'nicovideo.jp' },
    'OCReMix'               => { hostname   => 'ocremix.org' },
    'OffizielleCharts'      => { hostname   => 'offiziellecharts.de' },
    'OnlineBijbel'          => { hostname   => 'onlinebijbel.nl' },
    'OpenLibrary'           => { hostname   => 'openlibrary.org' },
    'Operabase'             => { hostname   => 'operabase.com' },
    'Operadis'              => { hostname   => 'operadis-opera-discography.org.uk' },
    'OTOTOY'                => { hostname   => 'ototoy.jp' },
    'Overture'              => { hostname   => 'overture.doremus.org' },
    'Ozon'                  => { hostname   => 'ozon.ru' },
    'Patreon'               => { hostname   => 'patreon.com' },
    'PayPalMe'              => { hostname   => 'paypal.me' },
    'PetitLyrics'           => { hostname   => 'petitlyrics.com' },
    'Pinterest'             => { hostname   => 'pinterest.com' },
    'Piosenki'              => { hostname   => 'bibliotekapiosenki.pl' },
    'Pixiv'                 => { hostname   => 'pixiv.net' },
    'ProgArchives'          => { hostname   => 'progarchives.com' },
    'PsyDB'                 => { hostname   => 'psydb.net' },
    'Qobuz'                 => { hostname   => 'qobuz.com' },
    'QuebecInfoMusique'     => { hostname   => ['quebecinfomusique.com', 'qim.com'] },
    'RateYourMusic'         => { hostname   => 'rateyourmusic.com' },
    'Recochoku'             => { hostname   => 'recochoku.jp' },
    'ResidentAdvisor'       => { hostname   => 'ra.co' },
    'ReverbNation'          => { hostname   => 'reverbnation.com' },
    'RISM'                  => { hostname   => 'rism.online' },
    'RockComAr'             => { hostname   => 'rock.com.ar' },
    'RockensDanmarkskort'   => { hostname   => 'rockensdanmarkskort.dk' },
    'RockInChina'           => { hostname   => 'rockinchina.com' },
    'Rockipedia'            => { hostname   => 'rockipedia.no' },
    'Rockit'                => { hostname   => 'rockit.it' },
    'Rolldabeats'           => { hostname   => 'rolldabeats.com' },
    'Runeberg'              => { hostname   => 'runeberg.org' },
    'SecondHandSongs'       => { hostname   => 'secondhandsongs.com' },
    'SetlistFM'             => { hostname   => 'setlist.fm' },
    'SMDB'                  => { hostname   => 'smdb.kb.se' },
    'SNAC'                  => { hostname   => 'snaccooperative.org' },
    'Songfacts'             => { hostname   => 'songfacts.com' },
    'Songkick'              => { hostname   => 'songkick.com' },
    'SoundCloud'            => { hostname   => 'soundcloud.com' },
    'SoundtrackCollector'   => { hostname   => 'soundtrackcollector.com' },
    'Spotify'               => { hostname   => 'spotify.com',
                                 subdomains => 1 },
    'SpiritOfMetal'         => { hostname   => 'spirit-of-metal.com' },
    'SpiritOfRock'          => { hostname   => 'spirit-of-rock.com' },
    'Stage48'               => { hostname   => 'stage48.net' },
    'SteamDB'               => { hostname   => 'steamdb.info' },
    'StereoVeMono'          => { hostname   => 'stereo-ve-mono.com' },
    'Target'                => { hostname   => ['target.com', 'intl.target.com'] },
    'THBWiki'               => { hostname   => 'thwiki.cc' },
    'Theatricalia'          => { hostname   => 'theatricalia.com' },
    'TheDanceGypsy'         => { hostname   => 'thedancegypsy.com' },
    'TheSession'            => { hostname   => 'thesession.org' },
    'Threads'               => { hostname   => ['threads.com', 'threads.net'] },
    'Ticketmaster'          => { hostname   => [ map { "ticketmaster.$_" } qw( ae at be ca ch cl co co.nz co.uk co.za com com.au com.br com.mx cz de dk es fi fr ie it nl no pe pl se sg ) ] },
    'Tidal'                 => { hostname   => ['tidal.com', 'store.tidal.com'] },
    'TikTok'                => { hostname   => 'tiktok.com' },
    'Tipeee'                => { hostname   => 'tipeee.com' },
    'TMDB'                  => { hostname   => 'themoviedb.org' },
    'TobaranDualchais'      => { hostname   => 'tobarandualchais.co.uk' },
    'TouhouDB'              => { hostname   => 'touhoudb.com' },
    'Tower'                 => { hostname   => 'tower.jp' },
    'Traxsource'            => { hostname   => 'traxsource.com' },
    'TripleJUnearthed'      => { hostname   => ['abc.net.au', 'triplejunearthed.com'],
                                 url        => qr{^https?://(?:www\.)?(?:abc\.net\.au/triplejunearthed|triplejunearthed\.com)/}i },
    'Trove'                 => { hostname   => 'nla.gov.au',
                                 subdomains => 1 },
    'Tsutaya'               => { hostname   => 'shop.tsutaya.co.jp' },
    'Tunearch'              => { hostname   => 'tunearch.org' },
    'Twitch'                => { hostname   => 'twitch.tv' },
    'Twitter'               => { hostname   => 'twitter.com' },
    'UtaiteDB'              => { hostname   => 'utaitedb.net' },
    'UtaNet'                => { hostname   => 'uta-net.com' },
    'Utaten'                => { hostname   => 'utaten.com' },
    'VGMdb'                 => { hostname   => 'vgmdb.net' },
    'VIAF'                  => { hostname   => 'viaf.org' },
    'Vimeo'                 => { hostname   => 'vimeo.com',
                                 path       => qr{^/(?!ondemand)}i },
    'VimeoOnDemand'         => { hostname   => 'vimeo.com',
                                 path       => qr{^/ondemand}i },
    'VK'                    => { hostname   => 'vk.com' },
    'Vkdb'                  => { hostname   => 'vkdb.jp' },
    'Vkgy'                  => { hostname   => 'vk.gy' },
    'VNDB'                  => { hostname   => 'vndb.org' },
    'VocaDB'                => { hostname   => 'vocadb.net' },
    'Weibo'                 => { hostname   => 'weibo.com' },
    'WhoSampled'            => { hostname   => 'whosampled.com' },
    'Wikidata'              => { hostname   => 'wikidata.org',
                                 path       => qr{^/wiki}i },
    'Wikipedia'             => { hostname   => 'wikipedia.org',
                                 subdomains => 1,
                                 url        => qr{^https?://([\w-]{2,})\.wikipedia\.org/wiki/}i },
    'Wikisource'            => { hostname   => 'wikisource.org',
                                 subdomains => 1,
                                 url        => qr{^https?://([\w-]{2,})\.wikisource\.org/wiki/}i },
    'Worldcat'              => { hostname   => ['entities.oclc.org', 'id.oclc.org', 'worldcat.org'],
                                 url        => qr{^https?://(?:(?:entities|id)\.oclc\.org/worldcat/|(?:www\.)?worldcat\.org/)}i },
    'Yandex'                => { hostname   => [ map { "music.yandex.$_" } qw( by com kz ru ) ] },
    'YesAsia'               => { hostname   => 'yesasia.com' },
    'YouTube'               => { hostname   => 'youtube.com' },
    'YouTubeMusic'          => { hostname   => 'music.youtube.com' },
    'Zamp'                  => { hostname   => 'zamp.hr' },
    'Zemereshet'            => { hostname   => 'zemereshet.co.il' },

    # License links
    'CCBY'                  => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/by/}i },
    'CCBYND'                => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/by-nd/}i },
    'CCBYNC'                => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/by-nc/}i },
    'CCBYNCND'              => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/by-nc-nd/}i },
    'CCBYNCSA'              => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/by-nc-sa/}i },
    'CCBYSA'                => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/by-sa/}i },
    'CC0'                   => { hostname   => 'creativecommons.org',
                                 path       => qr{^/publicdomain/zero/}i },
    'CCPD'                  => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/publicdomain/}i },
    'CCSampling'            => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/sampling/}i },
    'CCNCSamplingPlus'      => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/nc-sampling\+/}i },
    'CCSamplingPlus'        => { hostname   => 'creativecommons.org',
                                 path       => qr{^/licenses/sampling\+/}i },
    'ArtLibre'              => { hostname   => 'artlibre.org',
                                 path       => qr{^/licence/lal} },
);

sub _find_url_specialization_by_hostname {
    my ($url, $hostname, $path) = @_;

    my $entries = $URL_SPECIALIZATIONS->{$hostname};
    return unless defined $entries;

    for my $entry (@$entries) {
        next if defined $entry->{url} && $url !~ $entry->{url};
        next if defined $entry->{path} && $path !~ $entry->{path};
        return $entry;
    }
    return;
}

sub _find_url_specialization {
    my $url = shift;

    my ($hostname, $path) = $url =~ qr{^https?://(?:www\.)?([^/]+)(.*)}i;

    $hostname = lc ($hostname // '');
    $path //= '';

    my $entry = _find_url_specialization_by_hostname($url, $hostname, $path);

    unless (defined $entry) {
        # Try removing the first subdomain and see if there's a match.
        $hostname =~ s/^[^.]+\.//;
        $entry = _find_url_specialization_by_hostname($url, $hostname, $path);
        return unless defined $entry && $entry->{subdomains};
    }

    return $entry->{class};
}

sub _build_columns
{
    return join q(, ), qw(
        id
        gid
        url
        edits_pending
    );
}

has '_columns' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_columns',
);

sub _entity_class
{
    my ($self, $row) = @_;
    if ($row->{url}) {
        my $class = _find_url_specialization($row->{url});
        return "MusicBrainz::Server::Entity::URL::$class"
            if defined $class;
    }
    return 'MusicBrainz::Server::Entity::URL';
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    # A URL is automatically deleted if it has no relationships, so we have
    # manually do this merge. We add the GID redirect first, then merge
    # all relationships (which will in turn delete the old URL).

    my @old_gids = @{
        $self->c->sql->select_single_column_array(
            'SELECT gid FROM url WHERE id = any(?)', \@old_ids,
        );
    };

    # Update all GID redirects from @old_ids to $new_id
    $self->update_gid_redirects($new_id, @old_ids);

    # Add new GID redirects
    $self->add_gid_redirects(map { $_ => $new_id } @old_gids);

    $self->c->model('Edit')->merge_entities('url', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('url', $new_id, \@old_ids);

    $self->delete(@old_ids);

    return 1;
}

sub get_by_url {
    my ($self, $url) = @_;

    my $normalized = URI->new($url)->canonical;
    my $row = $self->c->prefer_ro_sql->select_single_row_hash(
        <<~"SQL",
        SELECT ${\($self->_columns)}
          FROM ${\($self->_table)}
         WHERE url = ?
        SQL
        $normalized,
    );
    if (defined $row) {
        return $self->_new_from_row($row);
    }
    return;
}

sub find_by_urls {
    my ($self, $urls) = @_;

    my $normalized = [map { URI->new($_)->canonical->as_string } @$urls];
    $self->query_to_list(<<~"SQL", [$normalized]);
        SELECT ${\($self->_columns)}
          FROM ${\($self->_table)}
         WHERE url = any(?)
         ORDER BY url
        SQL
}

sub update
{
    my ($self, $url_id, $url_hash) = @_;
    croak '$url_id must be present and > 0' unless $url_id > 0;

    my $merge_into = $self->get_by_url($url_hash->{url});
    if (defined $merge_into && $merge_into->id != $url_id) {
        $self->merge($merge_into->id, $url_id);
        return $merge_into->id;
    }
    else {
        $url_hash->{url} = URI->new($url_hash->{url})->canonical;
        my $row = $self->_hash_to_row($url_hash);
        $self->sql->update_row('url', $row, { id => $url_id });
        return $url_id;
    }
}

sub delete {
    my ($self, @ids) = @_;
    $self->remove_gid_redirects(@ids);
    $self->sql->do('DELETE FROM url WHERE id = any(?)', \@ids);
}

sub _hash_to_row
{
    my ($self, $url) = @_;

    my $row = hash_to_row($url, {
        url => 'url',
    });

    return $row;
}

sub insert { confess 'Should not be used for URLs' }

sub find_or_insert {
    my ($self, $url) = @_;

    $url = URI->new($url)->canonical;
    my $row = $self->sql->select_single_row_hash('SELECT * FROM url WHERE url = ?', $url);

    unless ($row) {
        $self->sql->auto_commit(1);

        my $to_insert = { url => $url, gid => generate_gid() };
        $row = { %$to_insert, id => $self->sql->insert_row('url', $to_insert, 'id') };
    }

    return $self->_new_from_row($row);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
