package MusicBrainz::Server::Report::ReleaseReport;
use Moose::Role;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

sub _load_extra_release_info {
    my ($self, @releases) = @_;

    $self->c->model('ArtistCredit')->load(@releases);
}

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $releases = $self->c->model('Release')->get_by_ids(
        map { $_->{release_id} } @$items
    );

    $self->_load_extra_release_info(values %$releases);

    return [
        map +{
            %$_,
            release => to_json_object($releases->{ $_->{release_id} }),
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
