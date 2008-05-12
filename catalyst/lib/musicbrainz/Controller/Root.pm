package musicbrainz::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

# We need this to specify the MusicBrainz perl codebase
use lib "/home/musicbrainz/blah/TemplateToolkit/cgi-bin";

use DBDefs;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

musicbrainz::Controller::Root - Root Controller for musicbrainz

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
    
}

=head2 end

Attempt to render a view, if needed. This will also set up some global variables in the 
context containing important information about the server used on the majority of templates.

=cut 

sub end : ActionClass('RenderView') {
    my ($self, $c) = @_;

    $c->stash->{server_details} = {
	version => &DBDefs::VERSION,
    };
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
