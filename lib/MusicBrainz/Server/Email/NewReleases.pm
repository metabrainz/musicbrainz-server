package MusicBrainz::Server::Email::NewReleases;
use Moose;
use namespace::autoclean;

use String::TT qw( strip tt );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Constants qw( $CONTACT_URL $EMAIL_SUPPORT_ADDRESS );
use MusicBrainz::Server::Email;

has 'editor' => (
    isa => 'Editor',
    required => 1,
    is => 'ro',
    handles => {
        to => 'email',
    }
);

with 'MusicBrainz::Server::Email::Role';

sub subject { 'New releases from your watched artists' }

has 'releases' => (
    isa => 'ArrayRef[Release]',
    is => 'ro',
    required => 1
);

sub extra_headers {
    my $self = shift;
    return (
        'Reply-To' => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id' => MusicBrainz::Server::Email::_message_id('watched-%s-%d', $self->editor->id, time())
    )
}

sub text {
    my $self = shift;
    return strip tt q{
[% FOR release=self.releases %]
[% release.name %] by [% release.artist_credit.name %] - released [% release.events.0.date.format %] on [% release.combined_format_name %]
[% self.server %]/release/[% release.gid %]
[% END %]
};
}

sub header {
    my $self = shift;
    return strip tt q{
This is a notification that artists you are watching have new releases
that have either just been released, or are due to be released in the near
future.
};
}

sub footer {
    my $self = shift;
    return strip tt qq{
Please do not reply to this message.  If you need help, please see
$CONTACT_URL
};
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
