package t::Email;

use Email::MIME;
use JSON::XS qw( decode_json );
use Moose::Role;
use namespace::autoclean;
use Test::More;

use DBDefs;
use MusicBrainz::Server::Data::Utils qw( non_empty );

with 't::Context';

sub _get_email {
    my ($self, $id) = @_;
    my $response = $self->c->lwp->get(DBDefs->MAILPIT_API . '/message/' . $id . '/raw');
    my $parsed = Email::MIME->new($response->content);
    my %headers = $parsed->header_str_pairs;
    my $body = '';
    $parsed->walk_parts(sub {
        my ($part) = @_;
        return if $part->subparts || $part->content_type !~ /^text\/plain;/;
        $body .= $part->body_str;
    });
    return {
        headers => \%headers,
        body => $body,
    };
}

sub _mailpit_configured {
    return non_empty(DBDefs->MAILPIT_API);
}

sub _mb_mail_service_configured {
    return non_empty(DBDefs->MAIL_SERVICE_BASE_URL);
}

sub skip_unless_mailpit_configured {
    my ($self) = @_;
    unless ($self->_mailpit_configured) {
        plan skip_all => '`MAILPIT_API` is not configured. This test will be skipped.';
    }
}

sub skip_unless_mb_mail_service_configured {
    my ($self) = @_;
    unless ($self->_mb_mail_service_configured) {
        plan skip_all => '`MAIL_SERVICE_BASE_URL` is not configured. This test will be skipped.';
    }
}

sub clear_email_deliveries {
    my ($self) = @_;
    return unless $self->_mailpit_configured;
    $self->c->lwp->delete(DBDefs->MAILPIT_API . '/messages');
}

sub get_emails {
    my ($self) = @_;
    return () unless $self->_mailpit_configured;
    my $c = $self->c;
    my $response = $c->lwp->get(DBDefs->MAILPIT_API . '/messages');
    my $content = decode_json($response->content);
    my @emails;
    for my $msg (@{ $content->{messages} }) {
        push @emails, $self->_get_email($msg->{ID});
    }
    $self->clear_email_deliveries if @emails;
    return @emails;
}

around run_test => sub {
    my ($orig, $self, @args) = @_;

    $self->clear_email_deliveries;

    $self->$orig(@args);

    $self->clear_email_deliveries;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
