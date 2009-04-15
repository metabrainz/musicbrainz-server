package MusicBrainz::Server::Model::AutoEditorElection;

use strict;
use warnings;

use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config(class => 'MusicBrainz::Server::AutoEditorElection');

sub prepare_arguments
{
    my ($self, $c) = @_;
    return [$c->mb->dbh, {
        generate_profile_link  => sub { $c->uri_for('/user/profile', shift->name) },
        generate_election_link => sub { $c->uri_for('/election', shift->id) },
        template_directory     => $c->path_to('root', 'elections', 'email'),
    }];
}

sub mangle_arguments
{
    my ($self, $args) = @_;
    return @$args;
}

1;