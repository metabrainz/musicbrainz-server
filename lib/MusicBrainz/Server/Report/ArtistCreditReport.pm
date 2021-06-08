package MusicBrainz::Server::Report::ArtistCreditReport;
use Moose::Role;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $artist_credits = $self->c->model('ArtistCredit')->get_by_ids(
        map { $_->{artist_credit_id} } @$items
    );

    return [
        map +{
            %$_,
            artist_credit => to_json_object($artist_credits->{ $_->{artist_credit_id} }),
        }, @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
