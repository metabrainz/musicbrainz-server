package MusicBrainz::Server::Data::URL;
use Moose;
use namespace::autoclean;

use Carp;
use MusicBrainz::Server::Data::Utils qw( generate_gid hash_to_row );
use MusicBrainz::Server::Entity::URL;
use URI;

extends 'MusicBrainz::Server::Data::CoreEntity';
with
    'MusicBrainz::Server::Data::Role::Editable' => { table => 'url' },
    'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'url' },
    'MusicBrainz::Server::Data::Role::Merge';

sub _type { 'url' }

my %URL_SPECIALIZATIONS = (

    # External links section
    '45cat'               => qr{^https?://(?:www.)?45cat.com/}i,
    'Allmusic'            => qr{^https?://(?:www.)?allmusic.com/}i,
    'AnimeNewsNetwork'    => qr{^https?://(?:www.)?animenewsnetwork.com/}i,
    'ASIN'                => qr{^https?://(?:www.)?amazon(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i,
    'BBCMusic'            => qr{^https?://(?:www.)?bbc.co.uk/music/}i,
    'Bandcamp'            => qr{^https?://([^/]+.)?bandcamp.com/}i,
    'Canzone'             => qr{^https?://(?:www.)?discografia.dds.it/}i,
    'Castalbums'          => qr{^https?://(?:www.)?castalbums.org/}i,
    'CDBaby'              => qr{^https?://(?:www.)?cdbaby.com/}i,
    'CiNii'               => qr{^https?://(?:www.)?ci.nii.ac.jp/}i,
    'Commons'             => qr{^https?://commons.wikimedia.org/wiki/File:}i,
    'DanceDB'             => qr{^https?://(?:www.)?tedcrane.com/DanceDB/}i,
    'DHHU'                => qr{^https?://(?:www.)?dhhu.dk/}i,
    'Discogs'             => qr{^https?://(?:www.)?discogs.com/}i,
    'DiscosDoBrasil'      => qr{^https?://(?:www.)?discosdobrasil.com.br/}i,
    'DNB'                 => qr{^https?://(?:www.)?d-nb.info/}i,
    'Encyclopedisque'     => qr{^https?://(?:www.)?encyclopedisque.fr/}i,
    'ESTER'               => qr{^https?://(?:www.)?ester.ee/}i,
    'Facebook'            => qr{^https?://(?:www.)?facebook.com/}i,
    'Finna'               => qr{^https?://(?:www.)?finna.fi/}i,
    'Finnmusic'           => qr{^https?://(?:www.)?finnmusic.net/}i,
    'FolkWiki'            => qr{^https?://(?:www.)?folkwiki.se/}i,
    'FonoFi'              => qr{^https?://(?:www.)?fono.fi/}i,
    'Generasia'           => qr{^https?://(?:www.)?generasia.com/wiki/}i,
    'Genius'              => qr{^https?://(?:[^/]+\.)?genius.com/}i,
    'GooglePlus'          => qr{^https?://(?:www.)?plus.google.com/}i,
    'IBDb'                => qr{^https?://(?:www.)?ibdb.com/}i,
    'IMDb'                => qr{^https?://(?:www.)?imdb.com/}i,
    'IMSLP'               => qr{^https?://(?:www.)?imslp.org/wiki/}i,
    'IOBDb'               => qr{^https?://(?:www.)?lortel.org/}i,
    'IMVDb'               => qr{^https?://(?:www.)?imvdb.com/}i,
    'InternetArchive'     => qr{^https?://(?:www.)?archive.org/details/}i,
    'Instagram'           => qr{^https?://(?:www.)?instagram.com/}i,
    'GooglePlay'          => qr{^https?://play.google.com/}i,
    'iTunes'              => qr{^https?://itunes.apple.com/}i,
    'ISRCTW'              => qr{^https?://(?:www.)?isrc.ncl.edu.tw/}i,
    'Jamendo'             => qr{^https?://(?:www.)?jamendo.com/}i,
    'Japameta'            => qr{^https?://(?:www.)?japanesemetal.gooside.com/}i,
    'LastFM'              => qr{^https?://(?:www.)?last.fm/}i,
    'Lieder'              => qr{^https?://(?:www.)?lieder.net/}i,
    'Loudr'               => qr{^https?://(?:www.)?loudr.fm/}i,
    'LyricWiki'           => qr{^https?://lyrics.wikia.com/}i,
    'MainlyNorfolk'       => qr{^https?://(?:www.)?mainlynorfolk.info/}i,
    'Maniadb'             => qr{^https?://(?:www.)?maniadb.com/}i,
    'MetalArchives'       => qr{^https?://(?:www.)?metal-archives.com/}i,
    'MusicMoz'            => qr{^https?://(?:www.)?musicmoz.org/}i,
    'MusikSammler'        => qr{^https?://(?:www.)?musik-sammler.de/}i,
    'MVDbase'             => qr{^https?://(?:www.)?mvdbase.com/}i,
    'MySpace'             => qr{^https?://(?:www.)?myspace.com/}i,
    'NDL'                 => qr{^https?://(?:www.)?iss.ndl.go.jp/}i,
    'OCReMix'             => qr{^https?://(?:www.)?ocremix.org/}i,
    'OpenLibrary'         => qr{^https?://(?:www.)?openlibrary.org/}i,
    'Operadis'            => qr{^https?://(?:www.)?operadis-opera-discography.org.uk/}i,
    'Ozon'                => qr{^https?://(?:www.)?ozon.ru/}i,
    'Piosenki'            => qr{^https?://(?:www.)?bibliotekapiosenki.pl/}i,
    'Pomus'               => qr{^https?://(?:www.)?pomus.net/}i,
    'PsyDB'               => qr{^https?://(?:www.)?psydb.net/}i,
    'PureVolume'          => qr{^https?://(?:www.)?purevolume.com/}i,
    'QuebecInfoMusique'   => qr{^https?://(?:www.)?qim.com/}i,
    'Rateyourmusic'       => qr{^https?://(?:www.)?rateyourmusic.com/}i,
    'ResidentAdvisor'     => qr{^https?://(?:www.)?residentadvisor.net/}i,
    'RockensDanmarkskort' => qr{^https?://(?:www.)?rockensdanmarkskort.dk/}i,
    'RockInChina'         => qr{^https?://(?:www.)?rockinchina.com/}i,
    'Rockipedia'          => qr{^https?://(?:www.)?rockipedia.no/}i,
    'Rolldabeats'         => qr{^https?://(?:www.)?rolldabeats.com/}i,
    'SecondHandSongs'     => qr{^https?://(?:www.)?secondhandsongs.com/}i,
    'SMDB'                => qr{^https?://(?:www.)?smdb.kb.se/}i,
    'Songfacts'           => qr{^https?://(?:www.)?songfacts.com/}i,
    'SoundCloud'          => qr{^https?://(?:www.)?soundcloud.com/}i,
    'Stage48'             => qr{^https?://(?:www.)?stage48.net/}i,
    'STcollector'         => qr{^https?://(?:www.)?soundtrackcollector.com/}i,
    'Spotify'             => qr{^https?://([^/]+.)?spotify.com/}i,
    'SpiritOfMetal'       => qr{^https?://(?:www.)?spirit-of-metal.com/}i,
    'SpiritOfRock'        => qr{^https?://(?:www.)?spirit-of-rock.com/}i,
    'Theatricalia'        => qr{^https?://(?:www.)?theatricalia.com/}i,
    'TheDanceGypsy'       => qr{^https?://(?:www.)?thedancegypsy.com/}i,
    'TheSession'          => qr{^https?://(?:www.)?thesession.org/}i,
    'TripleJUnearthed'    => qr{^https?://(?:www.)?triplejunearthed.com/}i,
    'Trove'               => qr{^https?://(?:www.)?(?:trove.)?nla.gov.au/}i,
    'Tunearch'            => qr{^https?://(?:www.)?tunearch.org/}i,
    'Twitter'             => qr{^https?://(?:www.)?twitter.com/}i,
    'VGMdb'               => qr{^https?://(?:www.)?vgmdb.net/}i,
    'VIAF'                => qr{^https?://(?:www.)?viaf.org/}i,
    'Videogamin'          => qr{^https?://(?:www.)?videogam.in/}i,
    'VK'                  => qr{^https?://(?:www.)?vk.com/}i,
    'Vkdb'                => qr{^https?://(?:www.)?vkdb.jp/}i,
    'WhoSampled'          => qr{^https?://(?:www.)?whosampled.com/}i,
    'Wikidata'            => qr{^https?://(?:www.)?wikidata.org/wiki/}i,
    'Wikipedia'           => qr{^https?://([\w-]{2,})\.wikipedia.org/wiki/}i,
    'Worldcat'            => qr{^https?://(?:www.)?worldcat.org/}i,
    'YouTube'             => qr{^https?://(?:www.)?youtube.com/}i,
    'Yunisan'             => qr{^https?://(?:www22.)?big.or.jp/}i,

    # License links
    'CCBY'              => qr{^http://creativecommons.org/licenses/by/}i,
    'CCBYND'            => qr{^http://creativecommons.org/licenses/by-nd/}i,
    'CCBYNC'            => qr{^http://creativecommons.org/licenses/by-nc/}i,
    'CCBYNCND'          => qr{^http://creativecommons.org/licenses/by-nc-nd/}i,
    'CCBYNCSA'          => qr{^http://creativecommons.org/licenses/by-nc-sa/}i,
    'CCBYSA'            => qr{^http://creativecommons.org/licenses/by-sa/}i,
    'CC0'               => qr{^http://creativecommons.org/publicdomain/zero/}i,
    'CCPD'              => qr{^http://creativecommons.org/licenses/publicdomain/}i,
    'CCSampling'        => qr{^http://creativecommons.org/licenses/sampling/}i,
    'CCNCSamplingPlus'  => qr{^http://creativecommons.org/licenses/nc-sampling\+/}i,
    'CCSamplingPlus'    => qr{^http://creativecommons.org/licenses/sampling\+/}i,
    'ArtLibre'          => qr{^http://artlibre.org/licence/lal}i,

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

    $self->_delete(@old_ids);

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

sub _delete {
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

sub insert { confess "Should not be used for URLs" }

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

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
