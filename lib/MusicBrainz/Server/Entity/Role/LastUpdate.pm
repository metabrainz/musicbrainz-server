package MusicBrainz::Server::Entity::Role::LastUpdate;

use Moose::Role;
use MusicBrainz::Server::Types qw( PgDateStr );
use namespace::autoclean;
use DateTime::Format::Pg;

has 'last_updated' => (
    is => 'rw',
    isa => PgDateStr,
    coerce => 1,
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    my $last_updated = $self->last_updated;
    if (defined $last_updated) {
        $last_updated = DateTime::Format::Pg->parse_datetime($self->last_updated);
        $last_updated->set_time_zone('UTC');
        $json->{last_updated} = $last_updated->iso8601 . 'Z';
    } else {
        $json->{last_updated} = undef;
    }

    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

