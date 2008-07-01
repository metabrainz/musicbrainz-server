package MusicBrainz::Server::Controller::Release;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use MusicBrainz::Server::Release;
use MusicBrainz;

=head1 NAME

MusicBrainz::Server::Controller::Release - Catalyst Controller for working with Release entities

=cut

=head1 DESCRIPTION

=head1 METHODS

=head1 releaseLinkRaw

Create stash data to link to a Release entity using root/components/entity-link.tt

=cut

sub releaseLinkRaw
{
    my ($name, $mbid) = @_;

    {
        name => $name,
        mbid => $mbid,
        type => 'release'
    };
}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1;
