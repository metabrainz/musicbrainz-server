package MusicBrainz::Server::Report::ArtistReport;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $artists = $self->c->model('Artist')->get_by_ids(
        map { $_->{artist_id} } @$items
    );

    $self->c->model('ArtistType')->load(values %$artists);

    return [
        map +{
            %$_,
            artist => to_json_object($artists->{ $_->{artist_id} }),
        }, @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
