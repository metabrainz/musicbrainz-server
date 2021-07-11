package MusicBrainz::Server::Entity::StatisticsEvent;

use Moose;
use MooseX::Types::URI qw( Uri );
use MooseX::Types::Moose qw( Str );

has 'date' => (
    is => 'rw',
    isa => 'Str'
);

has 'title' => (
    is => 'rw',
    isa => 'Str'
);

has 'link' => (
    is => 'rw',
    isa => Uri,
    coerce => 1,
);

has 'description' => (
    is => 'rw',
    isa => 'Str'
);

sub TO_JSON {
    my ($self) = @_;

    return {
        date => $self->date,
        description => $self->description,
        link => $self->link->as_string,
        title => $self->title,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
