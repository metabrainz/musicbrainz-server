package MusicBrainz::Server::Translation::Statistics;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Translation'; }

use Locale::Messages qw( dgettext dngettext );

sub gettext
{
    my ($self, $msgid, $vars) = @_;

    my %vars = %$vars if (ref $vars eq "HASH");

    $self->_bind_domain('statistics') unless $self->bound;
    $self->_set_language;

    $msgid =~ s/\r*\n\s*/ /xmsg if defined($msgid);

    return $self->_expand(dgettext('statistics' => $msgid), %vars) if $msgid;
}

sub ngettext {
    my ($self, $msgid, $msgid_plural, $n, $vars) = @_;

    my %vars = %$vars if (ref $vars eq "HASH");

    $self->_bind_domain('statistics') unless $self->bound;
    $self->_set_language;

    $msgid =~ s/\r*\n\s*/ /xmsg;

    return $self->_expand(dngettext('statistics' => $msgid, $msgid_plural, $n), %vars);
}

sub l  { __PACKAGE__->instance->gettext(@_) }
sub ln { __PACKAGE__->instance->ngettext(@_) }

1;
