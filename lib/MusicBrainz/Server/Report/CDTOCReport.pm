package MusicBrainz::Server::Report::CDTOCReport;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $cdtocs = $self->c->model('CDTOC')->get_by_ids(
        map { $_->{cdtoc_id} } @$items
    );

    my $releases = $self->c->model('Release')->get_by_ids(
        map { $_->{release_id} } @$items
    );

    $self->c->model('ArtistCredit')->load(values %$releases);

    return [
        map +{
            %$_,
            cdtoc => to_json_object($cdtocs->{ $_->{cdtoc_id} }),
            release => to_json_object($releases->{ $_->{release_id} }),
        }, @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 Jerome Roy

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
