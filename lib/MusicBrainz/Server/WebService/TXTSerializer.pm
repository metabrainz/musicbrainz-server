package MusicBrainz::Server::WebService::TXTSerializer;

use Moose;

sub mime_type { 'text/plain' }

sub fmt { 'txt' }

sub serialize {
    my ($self, $type, $text, $inc, $opts) = @_;

    if (ref $text eq 'ARRAY') {
        return join "\n", @$text;
    }
    return "$text";
}

sub output_error {
    my ($self, $err) = @_;

    my $error_text = $err . ' For usage, please see: https://musicbrainz.org/development/mmd';

    return $error_text;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
