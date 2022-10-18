package MusicBrainz::Server::Controller::URL;
use Moose;
use namespace::autoclean;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'URL',
    entity_name     => 'url',
    relationships   => { all => ['show', 'edit'] }
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';

=head1 NAME

MusicBrainz::Server::Controller::Url - Catalyst Controller for working
with Url entities

=cut

=head1 DESCRIPTION

Handles user interaction with URL entities (which are used in advanced
relationships).

=head1 METHODS

=cut

sub base : Chained('/') PathPart('url') CaptureArgs(0) { }

sub show : Chained('load') PathPart('') {
    my ($self, $c) = @_;
    $c->stash(
        component_path => 'url/UrlIndex',
        component_props => {url => $c->stash->{url}->TO_JSON},
        current_view => 'Node',
    );
}

=head2 edit

Edit the details of an already existing link

=cut

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form      => 'URL',
    edit_type => $EDIT_URL_EDIT,
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1
