package MusicBrainz::Server::View::Email::Template;

use strict;
use warnings;

use base 'Catalyst::View::Email::Template';

__PACKAGE__->config(
    stash_key       => 'email',
    template_prefix => '',
    default => {
        view => 'Default',
    },
    sender => {
        mailer => 'SMTP',
    },
);

1;
