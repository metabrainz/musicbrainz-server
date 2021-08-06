package MusicBrainz::Server::Entity::LinkAttribute;

use Moose;
use MusicBrainz::Server::Constants qw( $INSTRUMENT_ROOT_ID );
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( encode_entities );

with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'LinkAttributeType' };

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
        $value = '<a href="/instrument/' . $type->gid . qq(">$value</a>);
    }

    if (non_empty($self->credited_as) && $type->l_name ne $self->credited_as) {
        $value = l('{attribute} [{credited_as}]', { attribute => $value, credited_as => encode_entities($self->credited_as) })
    }

    if (non_empty($self->text_value)) {
        $value = l('{attribute}: {value}', { attribute => $value, value => encode_entities($self->text_value) });
    }

    return $value;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        type => $self->type->TO_JSON,
        $self->type->creditable && non_empty($self->credited_as) ? (credited_as => $self->credited_as) : (),
        # text values are required
        $self->type->free_text ? (text_value => $self->text_value) : (),
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
