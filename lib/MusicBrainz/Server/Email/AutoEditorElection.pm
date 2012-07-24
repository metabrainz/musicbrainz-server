package MusicBrainz::Server::Email::AutoEditorElection;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Email;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Data::AutoEditorElection;
use DBDefs;

has 'election' => (
    isa => 'AutoEditorElection',
    required => 1,
    is => 'ro',
);

with 'MusicBrainz::Server::Email::Role';

sub to { 'mb-automods Mailing List <musicbrainz-automods@lists.musicbrainz.org>' }

sub extra_headers {
    my $self = shift;
    my @headers = (
        'References' => sprintf('<autoeditor-election-%s@%s>', $self->election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL),
        'In-Reply-To' => sprintf('<autoeditor-election-%s@%s>', $self->election->id, &DBDefs::WEB_SERVER_USED_IN_EMAIL),
        'Message-Id' => sprintf('<autoeditor-election-%s-%d@%s>', $self->election->id, time(), &DBDefs::WEB_SERVER_USED_IN_EMAIL)
    );
    push @headers, (BCC => MusicBrainz::Server::Email::_user_address($self->election->candidate)) 
        if $self->election->candidate->email;
    return @headers;
}

sub subject {
    my $self = shift;
    return 'Autoeditor Election: ' . $self->election->candidate->name;
}

1;

=head1 COPYRIGHT

Copyright (C) 2011 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
