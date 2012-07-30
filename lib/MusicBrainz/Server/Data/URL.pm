package MusicBrainz::Server::Data::URL;
use Moose;
use namespace::autoclean;

use Carp;
use MusicBrainz::Server::Data::Utils qw( generate_gid hash_to_row );
use MusicBrainz::Server::Entity::URL;

extends 'MusicBrainz::Server::Data::CoreEntity';
with
    'MusicBrainz::Server::Data::Role::Editable' => { table => 'url' },
    'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'url' },
    'MusicBrainz::Server::Data::Role::Merge';

my %URL_SPECIALIZATIONS = (
    '45cat'           => qr{^https?://(?:www.)?45cat.com/}i,
    'Allmusic'        => qr{^https?://(?:www.)?allmusic.com/}i,
    'ASIN'            => qr{^https?://(?:www.)?amazon(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i,
    'BBCMusic'        => qr{^https?://(?:www.)?bbc.co.uk/music/}i,
    'Canzone'         => qr{^https?://(?:www.)?discografia.dds.it/}i,
    'CDBaby'          => qr{^https?://(?:www.)?cdbaby.com/}i,
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

sub _gid_redirect_table
{
    return 'url_gid_redirect';
}

sub _table
{
    return 'url';
}

sub _columns
{
    return 'id, gid, url, description, edits_pending';
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
    $self->c->model('Relationship')->merge_entities('url', $new_id, @old_ids);

    $self->_delete(@old_ids);

    return 1;
}

sub update
{
    my ($self, $url_id, $url_hash) = @_;
    croak '$url_id must be present and > 0' unless $url_id > 0;
    my $query = 'SELECT id FROM url WHERE url = ? AND id != ?';
    if (my $merge = $self->sql->select_single_value($query, $url_hash->{url}, $url_id)) {
        $self->merge($merge, $url_id);
        return $merge;
    }
    else {
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
        description => 'description'
    });
}

sub find_or_insert
{
    my ($self, $url) = @_;
    my $id = $self->sql->select_single_value('SELECT id FROM url WHERE url = ?',
                                             $url);
    unless ($id) {
        $self->sql->auto_commit(1);
        $id = $self->sql->insert_row('url', {
            url => $url,
            gid => generate_gid()
        }, 'id');
    }

    return $self->_new_from_row({
        id => $id,
        url => $url
    });
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
