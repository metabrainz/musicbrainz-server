package musicbrainz::Controller::Main;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

musicbrainz::Controller::Main - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'main/index.tt';
}

sub hackers : Global {
    my ($self, $c) = @_;

    $c->stash->{template} = 'main/template-hackers.tt';
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
