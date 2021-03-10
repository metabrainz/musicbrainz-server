package MusicBrainz::Server::Report::ReleaseGroupReport;
use Moose::Role;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

sub _load_extra_release_group_info {
    my ($self, @release_groups) = @_;

    $self->c->model('ArtistCredit')->load(@release_groups);
    $self->c->model('ReleaseGroupType')->load(@release_groups);
}

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $releasegroups = $self->c->model('ReleaseGroup')->get_by_ids(
        map { $_->{release_group_id} } @$items
    );

    $self->_load_extra_release_group_info(values %$releasegroups);

    return [
        map +{
            %$_,
            release_group => to_json_object($releasegroups->{ $_->{release_group_id} }),
        }, @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
