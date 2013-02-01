package MusicBrainz::Server::Data::NES::URL;
use Moose;
use namespace::autoclean;

use Class::Load;
use MusicBrainz::Server::Entity::Tree::URL;
use MusicBrainz::Server::Entity::URL;

with 'MusicBrainz::Server::Data::Role::NES';
with 'MusicBrainz::Server::Data::NES::CoreEntity' => {
    root => '/url'
};

my %URL_SPECIALIZATIONS = (
    '45cat'           => qr{^https?://(?:www.)?45cat.com/}i,
    'Allmusic'        => qr{^https?://(?:www.)?allmusic.com/}i,
    'ASIN'            => qr{^https?://(?:www.)?amazon(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i,
    'BBCMusic'        => qr{^https?://(?:www.)?bbc.co.uk/music/}i,
    'Canzone'         => qr{^https?://(?:www.)?discografia.dds.it/}i,
    'CDBaby'          => qr{^https?://(?:www.)?cdbaby.com/}i,
    'DHHU'            => qr{^https?://(?:www.)?dhhu.dk/}i,
    'Discogs'         => qr{^https?://(?:www.)?discogs.com/}i,
    'DiscosDoBrasil'  => qr{^https?://(?:www.)?discosdobrasil.com.br/}i,
    'Encyclopedisque' => qr{^https?://(?:www.)?encyclopedisque.fr/}i,
    'ESTERTallinn'    => qr{^https?://tallinn.ester.ee/}i,
    'ESTERTartu'      => qr{^https?://tartu.ester.ee/}i,
    'Facebook'        => qr{^https?://(?:www.)?facebook.com/}i,
    'IBDb'            => qr{^https?://(?:www.)?ibdb.com/}i,
    'IMDb'            => qr{^https?://(?:www.)?imdb.com/}i,
    'IMSLP'           => qr{^https?://(?:www.)?imslp.org/wiki/}i,
    'IOBDb'           => qr{^https?://(?:www.)?lortel.org/}i,
    'InternetArchive' => qr{^https?://(?:www.)?archive.org/details/}i,
    'ISRCTW'          => qr{^https?://(?:www.)?isrc.ncl.edu.tw/}i,
    'Jamendo'         => qr{^https?://(?:www.)?jamendo.com/}i,
    'LastFM'          => qr{^https?://(?:www.)?last.fm/}i,
    'Lieder'          => qr{^https?://(?:www.)?recmusic.org/lieder/}i,
    'LyricWiki'       => qr{^https?://lyrics.wikia.com/}i,
    'MetalArchives'   => qr{^https?://(?:www.)?metal-archives.com/}i,
    'MusicMoz'        => qr{^https?://(?:www.)?musicmoz.org/}i,
    'MusikSammler'    => qr{^https?://(?:www.)?musik-sammler.de/}i,
    'MySpace'         => qr{^https?://(?:www.)?myspace.com/}i,
    'OCReMix'         => qr{^https?://(?:www.)?ocremix.org/}i,
    'Ozon'            => qr{^https?://(?:www.)?ozon.ru/}i,
    'PsyDB'           => qr{^https?://(?:www.)?psydb.net/}i,
    'PureVolume'      => qr{^https?://(?:www.)?purevolume.com/}i,
    'Rateyourmusic'   => qr{^https?://(?:www.)?rateyourmusic.com/}i,
    'RockInChina'     => qr{^https?://(?:www.)?rockinchina.com/}i,
    'Rolldabeats'     => qr{^https?://(?:www.)?rolldabeats.com/}i,
    'SecondHandSongs' => qr{^https?://(?:www.)?secondhandsongs.com/}i,
    'Songfacts'       => qr{^https?://(?:www.)?songfacts.com/}i,
    'SoundCloud'      => qr{^https?://(?:www.)?soundcloud.com/}i,
    'SpiritOfMetal'   => qr{^https?://(?:www.)?spirit-of-metal.com/}i,
    'Theatricalia'    => qr{^https?://(?:www.)?theatricalia.com/}i,
    'Trove'           => qr{^https?://(?:www.)?trove.nla.gov.au/}i,
    'Twitter'         => qr{^https?://(?:www.)?twitter.com/}i,
    'VGMdb'           => qr{^https?://(?:www.)?vgmdb.net/}i,
    'Wikipedia'       => qr{^https?://([\w-]{2,})\.wikipedia.org/wiki/}i,
    'Worldcat'        => qr{^https?://(?:www.)?worldcat.org/}i,
    'YouTube'         => qr{^https?://(?:www.)?youtube.com/}i,
);

sub determine_url_class {
    my $url = shift;
    for my $class (keys %URL_SPECIALIZATIONS) {
        my $regex = $URL_SPECIALIZATIONS{$class};
        next unless $url =~ $regex;

        $class = "MusicBrainz::Server::Entity::URL::$class";
        Class::Load::load_class($class);
        return $class if ($url =~ $regex);
    }
    return 'MusicBrainz::Server::Entity::URL';
};

sub find_or_insert {
    my ($self, $edit, $editor, $url) = @_;
    $self->create(
        $edit, $editor,
        MusicBrainz::Server::Entity::Tree::URL->new(
            url => determine_url_class($url)->new(
                url => $url
            )
        )
    );
}

sub tree_to_json {
    my ($self, $tree) = @_;

    return (
        url => $tree->url->url->as_string
    );
}

sub map_core_entity {
    my ($self, $response) = @_;
    my %data = %{ $response->{data} };
    return determine_url_class($data{url})->new(
        url => $data{url},

        gid => $response->{mbid},
        revision_id => $response->{revision}
    );
}

1;
