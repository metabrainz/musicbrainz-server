package MusicBrainz::Server::Entity::CritiqueBrainz::Review;

use Moose;
use DBDefs;
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

sub href {
    my ($self) = @_;
    return DBDefs->CRITIQUEBRAINZ_SERVER . '/review/' . $self->id;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
