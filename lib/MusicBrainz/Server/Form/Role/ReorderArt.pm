package MusicBrainz::Server::Form::Role::ReorderArt;
use strict;
use warnings;

use Data::Compare;
use HTML::FormHandler::Moose::Role;
use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( artwork ) }

has_field 'artwork' => ( type => 'Repeatable' );
has_field 'artwork.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'artwork.position' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );

after validate => sub {
    my $self = shift;

    my $old_artwork = $self->init_object->{artwork};

    my @old_ids = sort { $a<=>$b } map { $_->{id} } @$old_artwork;
    my @new_ids = sort { $a<=>$b } map { $_->{id} } @{ $self->field('artwork')->value };

    my $are_ids_same = Compare( \@old_ids, \@new_ids );

    if (!$are_ids_same) {
        $self->field('artwork')->add_error(l(
            'The edit could not be applied because the images have changed. ' .
            'Please try again.',
        ));
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
