package MusicBrainz::Server::Entity::LinkAttribute;

use Moose;
use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( encode_entities );

has 'type_id' => (
    is => 'rw',
    isa => 'Int',
);

has 'type' => (
    is => 'rw',
    isa => 'LinkAttributeType',
);

has 'credited_as' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

has 'text_value' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

sub html {
    my ($self) = @_;

    my $type = $self->type;
    my $value = encode_entities($type->l_name);

    if ($type->root->id == $INSTRUMENT_ROOT_ID && $type->gid) {
        $value = "<a href=\"/instrument/" . $type->gid . "\">$value</a>";
    }

    if (non_empty($self->credited_as) && $type->l_name ne $self->credited_as) {
        $value = l('{attribute} [{credited_as}]', { attribute => $value, credited_as => encode_entities($self->credited_as) })
    }

    if (non_empty($self->text_value)) {
        $value = l('{attribute}: {value}', { attribute => $value, value => encode_entities($self->text_value) });
    }

    return $value;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
