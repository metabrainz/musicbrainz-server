package MusicBrainz::Server::Controller::Medium;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use HTTP::Status qw( :constants );

extends 'MusicBrainz::Server::Controller';
with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'medium',
    model       => 'Medium',
};

=head1 NAME

MusicBrainz::Server::Controller::Medium

=head1 DESCRIPTION

Handles user interaction with C<MusicBrainz::Server::Entity::Medium> entities.

=head1 METHODS

=head2 READ ONLY METHODS

=head2 base

Base action to specify that all actions live in the C<medium>
namespace.

=cut

sub base : Chained('/') PathPart('medium') CaptureArgs(0) { }

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $medium = $c->stash->{medium};
    my $release_gid = $c->model('Release')->find_gid_for_medium($medium->id);

    my $uri = $c->uri_for_action('/release/show', [ $release_gid ]);
    $uri->path($uri->path . '/disc/' . $medium->position);
    $uri->fragment('disc' . $medium->position);

    $c->response->redirect($uri, HTTP_SEE_OTHER);
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
