package MusicBrainz::Server::Data::CDStub;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    check_data
    load_subobjects
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Exceptions qw( BadData Duplicate );
use MusicBrainz::Server::Validation;

extends 'MusicBrainz::Server::Data::Entity';

use Readonly;
Readonly my $LIMIT_TOP_CDSTUBS => 1000;

sub _table
{
    return 'release_raw';
}

sub _columns
{
    return 'id, title, artist, added, lastmodified, lookupcount, modifycount, source, barcode, comment';
}

sub _column_mapping
{
    return {
        id => 'id',
        title => 'title',  
        artist => 'artist',
        date_added=> 'added',
        last_modified => 'lastmodified',
        lookup_count => 'lookupcount',
        modify_count => 'modifycount',
        source => 'source',
        barcode => 'barcode',
        comment => 'comment',
        discid => 'discid',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDStub';
}

sub _dbh
{
    return shift->c->raw_dbh;
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'cdstub', @objs);
}

sub load_top_cdstubs
{
    my ($self, $limit, $offset) = @_;
    my $query = "SELECT release_raw." . $self->_columns . ", discid
                 FROM " . $self->_table . ", cdtoc_raw 
                 WHERE release_raw.id = cdtoc_raw.release
                 ORDER BY lookupcount desc, modifycount DESC 
                 OFFSET ?
                 LIMIT  ?";
    return query_to_list_limited(
        $self->c->raw_dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $offset || 0, $LIMIT_TOP_CDSTUBS - $offset);
}

sub increment_lookup_count
{
    my ($self, $cdstub_id) = @_;
    $self->sql->auto_commit(1);
    $self->sql->do('UPDATE release_raw SET lookupcount = lookupcount + 1 WHERE id = ?', $cdstub_id);
}

sub get_by_discid
{
    my ($self, $discid) = @_;
    my $query = 'SELECT release_raw.' . $self->_columns . ', discid
                   FROM ' . $self->_table . '
                   JOIN cdtoc_raw ON cdtoc_raw.release = release_raw.id
                  WHERE discid = ?';
    return query_to_list($self->c->raw_dbh, sub { $self->_new_from_row(shift) }, $query, $discid);
}

sub insert
{
    my ($self, $cdstub_hash) = @_;

    my @tracks = @{ $cdstub_hash->{tracks} };
    my ($track_artists, $track_titles) = (0, 0);
    for my $track (@tracks) {
        $track_artists++ if $track->{artist};
        $track_titles++;
    }

    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($cdstub_hash->{toc});

    use Function::Parameters qw( check );
    check_data($cdstub_hash, 
        'No title provided' => check ($data) {
            $data->{title}
        },
        'No artist names provided' => check ($data) {
            $data->{artist} || $track_artists > 0; 
        },
        'Not all tracks specify an artist' => check ($data) {
            $track_artists == 0 || $track_artists == @tracks
        },
        'Not all tracks have a title' => check ($data) {
            $track_titles == @tracks
        },
        'Cannot add a CD stub with no tracks' => check ($data) {
            @tracks > 0
        },
        'Incomplete TOC data' => check ($data) {
            $data->{toc} && defined $cdtoc
        },
        'Missing disc ID' => check ($data) {
            $data->{discid}
        },
        'Disc ID does match parsed TOC' => check ($data) {
            $data->{discid} eq $cdtoc->discid
        },
        'Number of submitted tracks does not match track count in TOC' => check ($data) {
            @tracks == $cdtoc->track_count
        },
        'Invalid barcode' => check ($data) {
            !$data->{barcode} || MusicBrainz::Server::Validation::IsValidBarcode($data->{barcode});
        }
    );

    delete $cdstub_hash->{artist} if ($track_artists);

    if(my @releases = $self->c->model('Release')->find_by_disc_id($cdtoc->discid)) {
        MusicBrainz::Server::Exceptions::Duplicate->throw(
            message    => 'There are already MusicBrainz releases with this disc ID',
            duplicates => \@releases
        );
    }

    if(my $stub = $self->c->model('CDStub')->get_by_discid($cdtoc->discid)) {
        MusicBrainz::Server::Exceptions::Duplicate->throw(
            message    => 'There is already a CD stub with this disc ID',
            duplicates => [ $stub ]
        );
    }

    Sql::run_in_transaction(sub {
        my $release_id = $self->sql->insert_row('release_raw', {
            title => $cdstub_hash->{title},
            artist => $cdstub_hash->{artist},
            comment => $cdstub_hash->{comment} || undef,
            barcode => $cdstub_hash->{barcode} || undef,
            lookupcount => int(rand(10)) # FIXME - at least comment why we do this. -- aCiD2
        }, 'id');

        my $cdtoc_id = $self->sql->insert_row('cdtoc_raw', {
            release => $release_id,
            discid => $cdtoc->discid,
            trackcount => $cdtoc->track_count,
            leadoutoffset => $cdtoc->leadout_offset,
            trackoffset => $cdtoc->track_offset
        }, 'id');

        # FIXME Batch insert
        my $index = 1;
        for my $track (@tracks) {
            $self->sql->insert_row('track_raw', {
                release => $release_id,
                title => $track->{title},
                artist => $track->{artist},
                sequence => $index++
            });
        }
    }, $self->sql);
}

sub update
{
    my ($self, $cdstub, $hash) = @_;
    $self->sql->begin;
    $self->sql->update_row('release_raw', {
        map { $_ => $hash->{$_} } qw( title artist comment barcode )
    }, { id => $cdstub->id });

    for my $track ($cdstub->all_tracks) {
        my $update = $hash->{tracks}->[ $track->sequence - 1 ];
        next unless $update && keys %$update;
        $self->c->model('CDStubTrack')->update($track->id, $update);
    }

    $self->sql->commit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Robert Kaye

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
