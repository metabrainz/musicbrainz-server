package MusicBrainz::Server::Data::URL;
use Moose;
use namespace::autoclean;

use Carp;
use MusicBrainz::Server::Data::Utils qw( generate_gid hash_to_row );
use MusicBrainz::Server::Entity::URL;
use URI;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Relatable';
with
    'MusicBrainz::Server::Data::Role::PendingEdits' => { table => 'url' },
    'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'url' },
    'MusicBrainz::Server::Data::Role::Merge';

sub _type { 'url' }

my %URL_SPECIALIZATIONS = (

    # External links section
    '45cat'               => qr{^https?://(?:www\.)?45cat\.com/}i,
    '45worlds'            => qr{^https?://(?:www\.)?45worlds\.com/}i,
    'Allmusic'            => qr{^https?://(?:www\.)?allmusic\.com/}i,
    'AmazonMusic'         => qr{^https:\/\/music\.amazon\.(?:ae|at|com\.au|com\.br|ca|cn|com|de|es|fr|in|it|jp|co\.jp|com\.mx|nl|pl|se|sg|com\.tr|co\.uk)/}i,
    'AniDB'               => qr{^https?://(?:www\.)?anidb\.net/}i,
    'AnimeNewsNetwork'    => qr{^https?://(?:www\.)?animenewsnetwork\.com/}i,
    'AnisonGeneration'    => qr{^https?://anison\.info/}i,
    'AppleBooks'          => qr{^https?://books\.apple\.com/}i,
    'AppleMusic'          => qr{^https?://music\.apple\.com/}i,
    'ASIN'                => qr{^https?://(?:www\.)?amazon(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i,
    'Audiomack'           => qr{^https?://(?:www\.)?audiomack\.com/}i,
    'BaiduBaike'          => qr{^https?://baike\.baidu\.com/}i,
    'Bandcamp'            => qr{^https?://([^/]+\.)?bandcamp\.com/}i,
    'Bandsintown'         => qr{^https?://(?:www\.)?bandsintown\.com/}i,
    'Beatport'            => qr{^https?://([^/]+\.)?beatport\.com/}i,
    'BigCartel'           => qr{^https?://([^/]+\.)?bigcartel\.com}i,
    'BnFCatalogue'        => qr{^https?://catalogue\.bnf\.fr/}i,
    'BookBrainz'          => qr{^https?://(?:www\.)?bookbrainz\.org}i,
    'Boomkat'             => qr{^https?://(?:www\.)?boomkat\.com}i,
    'Boomplay'            => qr{^https?://(?:www\.)?boomplay\.com/}i,
    'BrahmsIrcam'         => qr{^https?://brahms\.ircam\.fr/}i,
    'Bugs'                => qr{^https?://music\.bugs\.co\.kr/}i,
    'Canzone'             => qr{^https?://(?:www\.)?discografia\.dds\.it/}i,
    'Cancioneros'         => qr{^https?://(?:www\.)?cancioneros\.si/}i,
    'Castalbums'          => qr{^https?://(?:www\.)?castalbums\.org/}i,
    'CBFiddleRx'          => qr{^https?://(?:www\.)?cbfiddle\.com/rx/}i,
    'CcMixter'            => qr{^https?://(?:www\.)?ccmixter\.org/}i,
    'CDJapan'             => qr{^https?://(?:www\.)?cdjapan\.co\.jp/}i,
    'ChangeTip'           => qr{^https?://(?:www\.)?changetip\.com/tipme/}i,
    'CiNii'               => qr{^https?://(?:www\.)?ci\.nii\.ac\.jp/}i,
    'ClassicalArchives'   => qr{^https?://(?:www\.)?classicalarchives\.com/}i,
    'Commons'             => qr{^https?://commons\.wikimedia\.org/wiki/File:}i,
    'CPDL'                => qr{^https?://cpdl\.org/wiki/}i,
    'DAHR'                => qr{^https?://adp\.library\.ucsb\.edu/}i,
    'Dailymotion'         => qr{^https?://(?:www\.)?dailymotion\.com/}i,
    'DanceDB'             => qr{^https?://(?:www\.)?tedcrane\.com/DanceDB/}i,
    'Deezer'              => qr{^https?://(?:www\.)?deezer\.com/}i,
    'DeviantArt'          => qr{^https?://(?:www\.)?deviantart\.com/}i,
    'DHHU'                => qr{^https?://(?:www\.)?dhhu\.dk/}i,
    'Directlyrics'        => qr{^https?://(?:www\.)?directlyrics\.com/}i,
    'Discogs'             => qr{^https?://(?:www\.)?discogs\.com/}i,
    'DiscosDoBrasil'      => qr{^https?://(?:www\.)?discosdobrasil\.com\.br/}i,
    'Dogmazic'            => qr{^https?://(?:[^/]+\.)?dogmazic\.net/}i,
    'DNB'                 => qr{^https?://(?:www\.)?d-nb\.info/}i,
    'DRAM'                => qr{^https?://(?:www\.)?dramonline\.org/}i,
    'DynamicRangeDB'      => qr{^https?://dr\.loudness-war\.info/}i,
    'Encyclopedisque'     => qr{^https?://(?:www\.)?encyclopedisque\.fr/}i,
    'ESTER'               => qr{^https?://(?:www\.)?ester\.ee/}i,
    'Facebook'            => qr{^https?://(?:www\.)?facebook\.com/}i,
    'Finna'               => qr{^https?://(?:www\.)?finna\.fi/}i,
    'Finnmusic'           => qr{^https?://(?:www\.)?finnmusic\.net/}i,
    'Flattr'              => qr{^https?://(?:www\.)?flattr\.com/profile/}i,
    'FolkWiki'            => qr{^https?://(?:www\.)?folkwiki\.se/}i,
    'FonoFi'              => qr{^https?://(?:www\.)?fono\.fi/}i,
    'Gakki'               => qr{^https?://(?:www\.)?saisaibatake\.ame-zaiku\.com/(?:gakki|musical|musical_instrument)/}i,
    'Generasia'           => qr{^https?://(?:www\.)?generasia\.com/wiki/}i,
    'Genius'              => qr{^https?://(?:[^/]+\.)?genius\.com/}i,
    'GeoNames'            => qr{^http://sws\.geonames\.org/}i,
    'Goodreads'           => qr{^https?://(?:www\.)?goodreads\.com/}i,
    'Gutenberg'           => qr{^https?://(?:www\.)?gutenberg\.org/}i,
    'HMikuWiki'           => qr{^https?://www5\.atwiki\.jp/hmiku/}i,
    'Hoick'               => qr{^https?://(?:www\.)?hoick\.jp/}i,
    'IBDb'                => qr{^https?://(?:www\.)?ibdb\.com/}i,
    'IdRef'               => qr{^https?://(?:www\.)?idref\.fr/}i,
    'IMDb'                => qr{^https?://(?:www\.)?imdb\.com/}i,
    'IMSLP'               => qr{^https?://(?:www\.)?imslp\.org/wiki/}i,
    'IMVDb'               => qr{^https?://(?:www\.)?imvdb\.com/}i,
    'IOBDb'               => qr{^https?://(?:www\.)?lortel\.org/}i,
    'Indiegogo'           => qr{^https?://(?:www\.)?indiegogo\.com/}i,
    'Instagram'           => qr{^https?://(?:www\.)?instagram\.com/}i,
    'InternetArchive'     => qr{^https?://(?:www\.)?archive\.org/details/}i,
    'IrishTune'           => qr{^https?://(?:www\.)?irishtune\.info/}i,
    'ISRCTW'              => qr{^https?://(?:www\.)?isrc\.ncl\.edu\.tw/}i,
    'iTunes'              => qr{^https?://itunes\.apple\.com/}i,
    'Jamendo'             => qr{^https?://(?:www\.)?jamendo\.com/}i,
    'Japameta'            => qr{^https?://(?:www\.)?japanesemetal\.gooside\.com/}i,
    'JazzMusicArchives'   => qr{^https?://(?:www\.)?jazzmusicarchives\.com/}i,
    'JLyric'              => qr{^https?://(?:www\.)?j-lyric\.net/}i,
    'Joysound'            => qr{^https?://(?:www\.)?joysound\.com/}i,
    'JunoDownload'        => qr{^https?://(?:www\.)?junodownload\.com/}i,
    'Kashinavi'           => qr{^https?://(?:www\.)?kashinavi\.com/}i,
    'KBR'                 => qr{^https?://opac\.kbr\.be/}i,
    'Kget'                => qr{^https?://(?:www\.)?kget\.jp/}i,
    'Kickstarter'         => qr{^https?://(?:www\.)?kickstarter\.com/}i,
    'Kofi'                => qr{^https?://(?:www\.)?ko-fi\.com/}i,
    'LaBoiteAuxParoles'   => qr{^https?://(?:www\.)?laboiteauxparoles\.com/}i,
    'Lantis'              => qr{^https?://(?:www\.)?lantis\.jp/}i,
    'LastFM'              => qr{^https?://(?:www\.)?last\.fm/}i,
    'LibraryThing'        => qr{^https?://(?:www\.)?librarything\.com/}i,
    'Lieder'              => qr{^https?://(?:www\.)?lieder\.net/}i,
    'LinkedIn'            => qr{^https?://([^/]+\.)?linkedin\.com/}i,
    'LiveFans'            => qr{^https?://(?:www\.)?livefans\.jp/}i,
    'LoC'                 => qr{^https?://(?:[^/]+\.)?loc\.gov/}i,
    'Loudr'               => qr{^https?://(?:www\.)?loudr\.fm/}i,
    'LyricEvesta'         => qr{^https?://lyric\.evesta\.jp/}i,
    'MainlyNorfolk'       => qr{^https?://(?:www\.)?mainlynorfolk\.info/}i,
    'Maniadb'             => qr{^https?://(?:www\.)?maniadb\.com/}i,
    'Melon'               => qr{^https?://www\.melon\.com/}i,
    'MetalArchives'       => qr{^https?://(?:www\.)?metal-archives\.com/}i,
    'MiguMusic'           => qr{^https?://music\.migu\.cn/}i,
    'Mixcloud'            => qr{^https?://(?:www\.)?mixcloud\.com/}i,
    'MobyGames'           => qr{^https?://(?:www\.)?mobygames\.com/}i,
    'Mora'                => qr{^https?://(?:www\.)?mora\.jp/}i,
    'MusicaPopularCl'     => qr{^https?://(?:www\.)?musicapopular\.cl/}i,
    'MusicMoz'            => qr{^https?://(?:www\.)?musicmoz\.org/}i,
    'MusikSammler'        => qr{^https?://(?:www\.)?musik-sammler\.de/}i,
    'Musixmatch'          => qr{^https?://(?:www\.)?musixmatch\.com/}i,
    'Musopen'             => qr{^https?://(?:www\.)?musopen\.org/}i,
    'Muziekweb'           => qr{^https?://www\.muziekweb\.nl/}i,
    'Muzikum'             => qr{^https?://(?:www\.)?muzikum\.eu/}i,
    'MVDbase'             => qr{^https?://(?:www\.)?mvdbase\.com/}i,
    'MySpace'             => qr{^https?://(?:www\.)?myspace\.com/}i,
    'Napster'             => qr{^https?://[\w-]{2}\.napster\.com/}i,
    'NDL'                 => qr{^https?://(?:www\.)?iss\.ndl\.go\.jp/}i,
    'NDLAuthorities'      => qr{^https?://id\.ndl\.go\.jp/}i,
    'NicoNicoVideo'       => qr{^https?://(?:www\.)?nicovideo\.jp/}i,
    'OCReMix'             => qr{^https?://(?:www\.)?ocremix\.org/}i,
    'OffizielleCharts'    => qr{^https?://(?:www\.)?offiziellecharts\.de/}i,
    'OnlineBijbel'        => qr{^https?://(?:www\.)?onlinebijbel\.nl/}i,
    'OpenLibrary'         => qr{^https?://(?:www\.)?openlibrary\.org/}i,
    'Operabase'           => qr{^https?://(?:www\.)?operabase\.com/}i,
    'Operadis'            => qr{^https?://(?:www\.)?operadis-opera-discography\.org\.uk/}i,
    'Overture'            => qr{^https?://overture\.doremus\.org/}i,
    'Ozon'                => qr{^https?://(?:www\.)?ozon\.ru/}i,
    'Patreon'             => qr{^https?://(?:www\.)?patreon\.com/}i,
    'PayPalMe'            => qr{^https?://(?:www\.)?paypal\.me/}i,
    'PetitLyrics'         => qr{^https?://(?:www\.)?petitlyrics\.com/}i,
    'Pinterest'           => qr{^https?://(?:www\.)?pinterest\.com/}i,
    'Piosenki'            => qr{^https?://(?:www\.)?bibliotekapiosenki\.pl/}i,
    'Pixiv'               => qr{^https?://(?:www\.)?pixiv\.net/}i,
    'Pomus'               => qr{^https?://(?:www\.)?pomus\.net/}i,
    'ProgArchives'        => qr{^https?://(?:www\.)?progarchives\.com/}i,
    'PsyDB'               => qr{^https?://(?:www\.)?psydb\.net/}i,
    'Qobuz'               => qr{^https?://(?:www\.)?qobuz\.com/}i,
    'QuebecInfoMusique'   => qr{^https?://(?:www\.)?qim\.com/}i,
    'RateYourMusic'       => qr{^https?://(?:www\.)?rateyourmusic\.com/}i,
    'Recochoku'           => qr{^https?://(?:www\.)?recochoku\.jp/}i,
    'ResidentAdvisor'     => qr{^https?://(?:www\.)?ra\.co/}i,
    'ReverbNation'        => qr{^https?://(?:www\.)?reverbnation\.com/}i,
    'RockComAr'           => qr{^https?://(?:www\.)?rock\.com\.ar/}i,
    'RockensDanmarkskort' => qr{^https?://(?:www\.)?rockensdanmarkskort\.dk/}i,
    'RockInChina'         => qr{^https?://(?:www\.)?rockinchina\.com/}i,
    'Rockipedia'          => qr{^https?://(?:www\.)?rockipedia\.no/}i,
    'Rolldabeats'         => qr{^https?://(?:www\.)?rolldabeats\.com/}i,
    'Runeberg'            => qr{^https?://(?:www\.)?runeberg\.org/}i,
    'SecondHandSongs'     => qr{^https?://(?:www\.)?secondhandsongs\.com/}i,
    'SetlistFM'           => qr{^https?://(?:www\.)?setlist\.fm/}i,
    'SMDB'                => qr{^https?://(?:www\.)?smdb\.kb\.se/}i,
    'SNAC'                => qr{^https?://(?:www\.)?snaccooperative\.org/}i,
    'Songfacts'           => qr{^https?://(?:www\.)?songfacts\.com/}i,
    'Songkick'            => qr{^https?://(?:www\.)?songkick\.com/}i,
    'SoundCloud'          => qr{^https?://(?:www\.)?soundcloud\.com/}i,
    'SoundtrackCollector' => qr{^https?://(?:www\.)?soundtrackcollector\.com/}i,
    'Spotify'             => qr{^https?://([^/]+\.)?spotify\.com/}i,
    'SpiritOfMetal'       => qr{^https?://(?:www\.)?spirit-of-metal\.com/}i,
    'SpiritOfRock'        => qr{^https?://(?:www\.)?spirit-of-rock\.com/}i,
    'Stage48'             => qr{^https?://(?:www\.)?stage48\.net/}i,
    'Target'              => qr{^https?://(?:(?:intl|www)\.)?target\.com/}i,
    'Theatricalia'        => qr{^https?://(?:www\.)?theatricalia\.com/}i,
    'TheDanceGypsy'       => qr{^https?://(?:www\.)?thedancegypsy\.com/}i,
    'TheSession'          => qr{^https?://(?:www\.)?thesession\.org/}i,
    'Threads'             => qr{^https?://(?:www\.)?threads\.net/}i,
    'Tidal'               => qr{^https?://(?:[^/]+\.)?tidal\.com/}i,
    'TikTok'              => qr{^https?://(?:www\.)?tiktok\.com/}i,
    'Tipeee'              => qr{^https?://(?:www\.)?tipeee\.com/}i,
    'TMDB'                => qr{^https?://(?:www\.)?themoviedb\.org/}i,
    'TobaranDualchais'    => qr{^https?://(?:www\.)?tobarandualchais\.co\.uk/}i,
    'TouhouDB'            => qr{^https?://(?:www\.)?touhoudb\.com/}i,
    'Tower'               => qr{^https?://(?:www\.)?tower\.jp/}i,
    'Traxsource'          => qr{^https?://(?:www\.)?traxsource.com/}i,
    'TripleJUnearthed'    => qr{^https?://(?:www\.)?(?:abc\.net\.au/triplejunearthed|triplejunearthed\.com)/}i,
    'Trove'               => qr{^https?://(?:www\.)?(?:trove\.)?nla\.gov\.au/}i,
    'Tsutaya'             => qr{^https?://(?:www\.)?shop\.tsutaya\.co\.jp/}i,
    'Tunearch'            => qr{^https?://(?:www\.)?tunearch\.org/}i,
    'Twitch'              => qr{^https?://(?:www\.)?twitch\.tv/}i,
    'Twitter'             => qr{^https?://(?:www\.)?twitter\.com/}i,
    'UtaiteDB'            => qr{^https?://(?:www\.)?utaitedb\.net/}i,
    'Utamap'              => qr{^https?://(?:www\.)?utamap\.com/}i,
    'UtaNet'              => qr{^https?://(?:www\.)?uta-net\.com/}i,
    'Utaten'              => qr{^https?://(?:www\.)?utaten\.com/}i,
    'VGMdb'               => qr{^https?://(?:www\.)?vgmdb\.net/}i,
    'VIAF'                => qr{^https?://(?:www\.)?viaf\.org/}i,
    'Vimeo'               => qr{^https?://(?:www\.)?vimeo\.com/(?!ondemand)}i,
    'VimeoOnDemand'       => qr{^https?://(?:www\.)?vimeo\.com/ondemand}i,
    'VK'                  => qr{^https?://(?:www\.)?vk\.com/}i,
    'Vkdb'                => qr{^https?://(?:www\.)?vkdb\.jp/}i,
    'VNDB'                => qr{^https?://(?:www\.)?vndb\.org/}i,
    'VocaDB'              => qr{^https?://(?:www\.)?vocadb\.net/}i,
    'Weibo'               => qr{^https?://(?:www\.)?weibo\.com/}i,
    'WhoSampled'          => qr{^https?://(?:www\.)?whosampled\.com/}i,
    'Wikidata'            => qr{^https?://(?:www\.)?wikidata\.org/wiki/}i,
    'Wikipedia'           => qr{^https?://([\w-]{2,})\.wikipedia\.org/wiki/}i,
    'Wikisource'          => qr{^https?://([\w-]{2,})\.wikisource\.org/wiki/}i,
    'Worldcat'            => qr{^https?://(?:id\.oclc\.org/worldcat/|(?:www\.)?worldcat\.org/)}i,
    'YesAsia'             => qr{^https?://(?:www\.)?yesasia\.com/}i,
    'YouTube'             => qr{^https?://(?:www\.)?youtube\.com/}i,
    'YouTubeMusic'        => qr{^https?://music\.youtube\.com/}i,
    'Yunisan'             => qr{^https?://(?:www22\.)?big\.or\.jp/}i,

    # License links
    'CCBY'              => qr{^https?://creativecommons\.org/licenses/by/}i,
    'CCBYND'            => qr{^https?://creativecommons\.org/licenses/by-nd/}i,
    'CCBYNC'            => qr{^https?://creativecommons\.org/licenses/by-nc/}i,
    'CCBYNCND'          => qr{^https?://creativecommons\.org/licenses/by-nc-nd/}i,
    'CCBYNCSA'          => qr{^https?://creativecommons\.org/licenses/by-nc-sa/}i,
    'CCBYSA'            => qr{^https?://creativecommons\.org/licenses/by-sa/}i,
    'CC0'               => qr{^https?://creativecommons\.org/publicdomain/zero/}i,
    'CCPD'              => qr{^https?://creativecommons\.org/licenses/publicdomain/}i,
    'CCSampling'        => qr{^https?://creativecommons\.org/licenses/sampling/}i,
    'CCNCSamplingPlus'  => qr{^https?://creativecommons\.org/licenses/nc-sampling\+/}i,
    'CCSamplingPlus'    => qr{^https?://creativecommons\.org/licenses/sampling\+/}i,
    'ArtLibre'          => qr{^https?://artlibre\.org/licence/lal}i,

);

sub _columns
{
    return 'id, gid, url, edits_pending';
}

sub _entity_class
{
    my ($self, $row) = @_;
    if ($row->{url}) {
        for my $class (keys %URL_SPECIALIZATIONS) {
            my $regex = $URL_SPECIALIZATIONS{$class};
            return "MusicBrainz::Server::Entity::URL::$class"
                if ($row->{url} =~ $regex);
        }
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
            'SELECT gid FROM url WHERE id = any(?)', \@old_ids
        )
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

sub find_by_url {
    my ($self, $url) = @_;
    my $normalized = URI->new($url)->canonical;
    my $query = 'SELECT ' . $self->_columns . ' FROM ' . $self->_table .
                ' WHERE url = ?';
    $self->query_to_list($query, [$normalized]);
}

sub update
{
    my ($self, $url_id, $url_hash) = @_;
    croak '$url_id must be present and > 0' unless $url_id > 0;

    my ($merge_into) = grep { $_->id != $url_id }
        $self->find_by_url($url_hash->{url});

    if ($merge_into) {
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
    $self->sql->do('DELETE FROM url WHERE id = any(?)', \@ids);
}

sub _hash_to_row
{
    my ($self, $values) = @_;
    return hash_to_row($values, {
        url => 'url',
    });
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
