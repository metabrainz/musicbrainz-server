package MusicBrainz::Server::Email::AutoEditorElection;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Email;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Data::AutoEditorElection;

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
        'References'  => MusicBrainz::Server::Email::_message_id('autoeditor-election-%s', $self->election->id),
        'In-Reply-To' => MusicBrainz::Server::Email::_message_id('autoeditor-election-%s', $self->election->id),
        'Message-Id'  => MusicBrainz::Server::Email::_message_id('autoeditor-election-%s-%d', $self->election->id, time())
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
