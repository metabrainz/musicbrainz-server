package MusicBrainz::Server::Report::ReleaseGroupReport;
use Moose::Role;

with 'MusicBrainz::Server::Report::QueryReport';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $releasegroups = $self->c->model('ReleaseGroup')->get_by_ids(
        map { $_->{release_group_id} } @$items
    );
    $self->c->model('ArtistCredit')->load(values %$releasegroups);
    $self->c->model('ReleaseGroupType')->load(values %$releasegroups);

    return [
        map +{
            %$_,
            release_group => $releasegroups->{ $_->{release_group_id} }
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
