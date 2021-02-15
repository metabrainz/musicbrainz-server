package MusicBrainz::Server::Entity::Link;
use Moose;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::DatePeriod';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'LinkType' };

sub entity_type { 'link' }

has 'attributes' => (
    is => 'rw',
    isa => 'ArrayRef[LinkAttribute]',
    traits => [ 'Array' ],
    default => sub { [] },
    lazy => 1,
    handles => {
        clear_attributes => 'clear',
        all_attributes   => 'elements',
        add_attribute    => 'push'
    }
);

sub has_attribute
{
    my ($self, $name) = @_;

    $name = lc $name;
    foreach my $attr ($self->all_attributes) {
        my $type = $attr->type;
        if (defined $type->root && lc $type->root->name eq $name) {
            return 1;
        }
    }
    return 0;
}

sub get_attribute
{
    my ($self, $name) = @_;

    my @values;
    $name = lc $name;
    foreach my $attr ($self->all_attributes) {
        my $type = $attr->type;
        if (defined $type->root && lc $type->root->name eq $name) {
            push @values, lc $attr->type->name;
        }
    }
    return \@values;
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
