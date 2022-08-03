package MusicBrainz::Server::Entity::CritiqueBrainz::Review;

use Moose;
use DBDefs;
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Types;

has id => (
    is => 'ro',
    isa => 'Str'
);

has created => (
    is => 'ro',
    isa => 'DateTime'
);

has body => (
    is => 'ro',
    isa => 'Str'
);

has author => (
    is => 'ro',
    isa => 'MusicBrainz::Server::Entity::CritiqueBrainz::User'
);

has rating => (
    is => 'ro',
    isa => 'Maybe[Int]'
);

sub href {
    my ($self) = @_;
    return DBDefs->CRITIQUEBRAINZ_SERVER . '/review/' . $self->id;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        author => to_json_object($self->author),
        body => $self->body,
        created => datetime_to_iso8601($self->created),
        id => $self->id,
        rating => $self->rating,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
