package MusicBrainz::Server::Translation::Attributes;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Translation'; }

use Locale::Messages qw( dpgettext );

sub pgettext
{
    my ($self, $msgid, $msgctxt, $vars) = @_;

    my %vars = %$vars if (ref $vars eq "HASH");

    $self->_bind_domain('attributes') unless $self->bound;
    $self->_set_language;

    $msgid =~ s/\r*\n\s*/ /xmsg if defined($msgid);

    return $self->_expand(dpgettext('attributes' => $msgctxt, $msgid), %vars) if $msgid;
}

sub lp { __PACKAGE__->instance->pgettext(@_) }

1;
