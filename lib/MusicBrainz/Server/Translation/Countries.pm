package MusicBrainz::Server::Translation::Countries;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Translation'; }

use Locale::Messages qw( dgettext );

sub gettext
{
    my ($self, $msgid, $vars) = @_;

    my %vars = %$vars if (ref $vars eq "HASH");

    $self->_bind_domain('countries') unless $self->bound;
    $self->_set_language;

    $msgid =~ s/\r*\n\s*/ /xmsg if defined($msgid);

    return $self->_expand(dgettext('countries' => $msgid), %vars) if $msgid;
}

sub l  { __PACKAGE__->instance->gettext(@_) }

1;
