package MusicBrainz::Server::Data::CDStubTrack;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'track_raw';
}

sub _columns
{
    return 'id, release, title, artist, sequence';
}

sub _column_mapping
{
    return {
        id => 'id',
        cdstub_id  => 'release',
        title => 'title',
        artist => 'artist',
        sequence => 'sequence',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDStubTrack';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release', @objs);
}

sub load_for_cdstub
{
    my ($self, @cdstubs) = @_;
    my %id_to_cdstub = map { $_->id => $_ } @cdstubs;
    my @ids = keys %id_to_cdstub;
    return unless @ids; # nothing to do
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE release IN (" . placeholders(@ids) . ")
                 ORDER BY release, sequence";
    my @tracks = $self->query_to_list($query, \@ids);
    foreach my $track (@tracks) {
        $id_to_cdstub{$track->cdstub_id}->add_track($track);
    }
}

sub update
{
    my ($self, $track_id, $hash) = @_;
    $self->sql->update_row('track_raw', $hash, { id => $track_id });
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
