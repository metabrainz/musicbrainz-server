package MusicBrainz::Server::Report::WorkReport;
use Moose::Role;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

sub _load_extra_work_info {
    my ($self, @works) = @_;

    $self->c->model('WorkType')->load(@works);
}

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $works = $self->c->model('Work')->get_by_ids(
        map { $_->{work_id} } @$items
    );

    $self->_load_extra_work_info(values %$works);

    return [
        map +{
            %$_,
            work => to_json_object($works->{ $_->{work_id} }),
        }, @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
