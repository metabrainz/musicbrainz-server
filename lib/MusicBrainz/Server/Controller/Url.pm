package MusicBrainz::Server::Controller::Url;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

MusicBrainz::Server::Controller::Url - Catalyst Controller for working with Url entities

=cut

=head1 DESCRIPTION

=head1 METHODS

=head1 urlLinkRaw

Create stash data to link to a URL entity using root/components/entity-link.tt

=cut

sub urlLinkRaw
{
    my ($url, $mbid) = @_;

    {
        url => $url,
        mbid => $mbid,
        type => 'url'
    };
}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1
