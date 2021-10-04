package MusicBrainz::Server::Data::CDStub;

use Moose;
use namespace::autoclean;

use DBDefs;
use MusicBrainz::Server::Data::Utils qw(
    check_data
    load_subobjects
);
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Exceptions qw( BadData Duplicate );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_barcode );
use Readonly;

extends 'MusicBrainz::Server::Data::Entity';

Readonly my $LIMIT_TOP_CDSTUBS => 1000;

sub _table
{
    return 'release_raw JOIN cdtoc_raw ON cdtoc_raw.release = release_raw.id';
}

sub _columns
{
    return join(', ', qw(
        release_raw.id
        title
        artist
        added
        last_modified
        lookup_count
        modify_count
        source
        barcode
        comment
        discid
        track_count
        leadout_offset
        track_offset
    ));
}

sub _column_mapping
{
    return {
        id => 'id',
        title => 'title',
        artist => 'artist',
        date_added=> 'added',
        last_modified => 'last_modified',
        lookup_count => 'lookup_count',
        modify_count => 'modify_count',
        source => 'source',
        barcode => sub { MusicBrainz::Server::Entity::Barcode->new_from_row(shift, shift) },
        comment => 'comment',
        discid => 'discid',
        track_count => 'track_count',
        leadout_offset => 'leadout_offset',
        track_offset => 'track_offset',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDStub';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'cdstub', @objs);
}

sub load_top_cdstubs
{
    my ($self, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 ORDER BY lookup_count desc, modify_count DESC';
    $self->query_to_list_limited($query, [], $LIMIT_TOP_CDSTUBS, $offset);
}

sub increment_lookup_count
{
    my ($self, $cdstub_id) = @_;
    return if DBDefs->DB_READ_ONLY;

    $self->sql->auto_commit(1);
    $self->sql->do('UPDATE release_raw SET lookup_count = lookup_count + 1 WHERE id = ?', $cdstub_id);
}

sub get_by_discid {
    my ($self, $discid) = @_;

    my @cdstubs = $self->_get_by_keys('discid', $discid);
    return $cdstubs[0];
}

sub insert
{
    my ($self, $cdstub_hash) = @_;

    my @tracks = @{ $cdstub_hash->{tracks} };
    my ($track_artists, $track_titles) = (0, 0);
    for my $track (@tracks) {
        $track_artists++ if $track->{artist};
        $track_titles++ if $track->{title};
    }

    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($cdstub_hash->{toc});

    check_data($cdstub_hash,
        l('No title provided') => sub {
            my $data = shift;
            $data->{title}
        },
        l('No artist names provided') => sub {
            my $data = shift;
            $data->{artist} || $track_artists > 0;
        },
        l('Not all tracks specify an artist') => sub {
            my $data = shift;
            $track_artists == 0 || $track_artists == @tracks
        },
        l('Not all tracks have a title') => sub {
            my $data = shift;
            $track_titles == @tracks
        },
        l('Cannot add a CD stub with no tracks') => sub {
            my $data = shift;
            @tracks > 0
        },
        l('Incomplete TOC data') => sub {
            my $data = shift;
            $data->{toc} && defined $cdtoc
        },
        l('Missing disc ID') => sub {
            my $data = shift;
            $data->{discid}
        },
        l('Disc ID does match parsed TOC') => sub {
            my $data = shift;
            $data->{discid} eq $cdtoc->discid
        },
        l('Number of submitted tracks does not match track count in TOC') => sub {
            my $data = shift;
            @tracks == $cdtoc->track_count
        },
        l('Invalid barcode') => sub {
            my $data = shift;
            !$data->{barcode} || is_valid_barcode($data->{barcode});
        }
    );

    delete $cdstub_hash->{artist} if ($track_artists);

    if (my @releases = $self->c->model('Release')->find_by_disc_id($cdtoc->discid)) {
        MusicBrainz::Server::Exceptions::Duplicate->throw(
            message    => l('There are already MusicBrainz releases with this disc ID'),
            duplicates => \@releases
        );
    }

    if (my $stub = $self->c->model('CDStub')->get_by_discid($cdtoc->discid)) {
        MusicBrainz::Server::Exceptions::Duplicate->throw(
            message    => l('There is already a CD stub with this disc ID'),
            duplicates => [ $stub ]
        );
    }

    Sql::run_in_transaction(sub {
        my $release_id = $self->sql->insert_row('release_raw', {
            title => $cdstub_hash->{title},
            artist => $cdstub_hash->{artist},
            comment => $cdstub_hash->{comment} // '',
            barcode => $cdstub_hash->{barcode} || undef,
            lookup_count => int(rand(10)) # FIXME - at least comment why we do this. -- aCiD2
        }, 'id');

        my $cdtoc_id = $self->sql->insert_row('cdtoc_raw', {
            release => $release_id,
            discid => $cdtoc->discid,
            track_count => $cdtoc->track_count,
            leadout_offset => $cdtoc->leadout_offset,
            track_offset => $cdtoc->track_offset
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

sub delete
{
    my ($self, $discid) = @_;
    my $release_id = $self->sql->select_single_value(
        'DELETE FROM cdtoc_raw WHERE discid = ? RETURNING release',
        $discid);
    $self->sql->do(
        'DELETE FROM track_raw WHERE release = ?',
        $release_id);
    $self->sql->do(
        'DELETE FROM release_raw WHERE id = ?',
        $release_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
