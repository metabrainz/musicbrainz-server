package MusicBrainz::Server::Role::SendsEmail;
use Moose::Role;

use Email::MIME;
use Email::Send;
use Template;

requires 'generate_email_headers';

=head2 template_directory

Where the templates for sending emails can be found

=cut

has 'template_directory' => (
    isa => 'Path::Class::Dir',
    is  => 'ro',
);

=head2 send_email $template, %opts

Send an email from a template.

C<$template> is the template to process for sending email (relative to
the root directory).

=cut

sub send_email
{
    my ($self, $template, $context, %opts) = @_;

    my $tt = Template->new({
        INCLUDE_PATH => $self->template_directory->stringify,
    });
    my $message;
    $tt->process($template, $context, \$message)
        or die $template->error;

    my %mime = (
        header => [
            @{ $self->generate_email_headers },
            @{ $opts{extra_headers} }
        ],
        body => $message,
    );

    my $email = Email::MIME->create(%mime);
    my $transport = Email::Send->new({ mailer => 'Sendmail' });

    my $return = $transport->send($email);
    die "Could not send email: $return" if !$return;
}

1;