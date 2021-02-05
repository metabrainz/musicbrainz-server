package MusicBrainz::Server::Entity::CritiqueBrainz::User;

use Moose;
use DBDefs;

has id => (
    is => 'ro',
    isa => 'Str'
);

has name => (
    is => 'ro',
    isa => 'Str'
);

sub href {
    my ($self) = @_;
    return DBDefs->CRITIQUEBRAINZ_SERVER . '/user/' . $self->id;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        id => $self->id,
        name => $self->name,
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
