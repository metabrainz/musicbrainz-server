package MusicBrainz::Server::Role::Translation;
use MooseX::Role::Parameterized;
use Locale::Messages qw( dgettext dpgettext dngettext );

parameter domain => ( required => 1, isa => 'Str' );

role {
    my $params = shift;

    method 'nop_gettext' => sub
    {
        # Just return the first argument to the caller
        # Used for N_l and N_lp
        shift;
        return shift;
    };

    method 'nop_ngettext' => sub
    {
        # Just return the arguments to the caller
        # Used for N_ln
        shift;
        return @_;
    };

    method 'gettext' => sub
    {
        my ($self, $msgid, $vars) = @_;

        my %vars = %$vars if (ref $vars eq "HASH");

        $self->_bind_domain($params->domain) unless $self->bound;

        $msgid =~ s/\r*\n\s*/ /xmsg if defined($msgid);

        return $self->_expand(dgettext($params->domain => $msgid), %vars) if $msgid;
    };

    method 'pgettext' => sub 
    {
        my ($self, $msgid, $msgctxt, $vars) = @_;

        my %vars = %$vars if (ref $vars eq "HASH");

        $self->_bind_domain($params->domain) unless $self->bound;

        $msgid =~ s/\r*\n\s*/ /xmsg if defined($msgid);

        return $self->_expand(dpgettext($params->domain => $msgctxt, $msgid), %vars) if $msgid;
    };

    method 'ngettext' => sub 
    {
        my ($self, $msgid, $msgid_plural, $n, $vars) = @_;

        my %vars = %$vars if (ref $vars eq "HASH");

        $self->_bind_domain($params->domain) unless $self->bound;

        $msgid =~ s/\r*\n\s*/ /xmsg if defined($msgid);

        return $self->_expand(dngettext($params->domain => $msgid, $msgid_plural, $n), %vars);
    };
};
