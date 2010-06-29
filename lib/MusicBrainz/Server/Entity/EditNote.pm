package MusicBrainz::Server::Entity::EditNote;
use Moose;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Validation qw( encode_entities );

has 'editor_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'edit_id' => (
    isa => 'Int',
    is => 'rw',
);

has 'edit' => (
    isa => 'Edit',
    is => 'rw',
);

has 'text' => (
    isa => 'Str',
    is => 'rw',
);

has 'post_time' => (
    isa => 'DateTime',
    is => 'rw',
    coerce => 1
);

sub as_html
{
    my ($self) = @_;

    my $text = $self->text;

    my $is_url = 1;
    my $server = &DBDefs::WEB_SERVER;

    my $html = join "", map {

        # shorten url's that are longer 50 characters
        my $encurl = encode_entities($_);
        my $shorturl = $encurl;
        if (length($_) > 50)
        {
            $shorturl = substr($_, 0, 48);
            $shorturl = encode_entities($shorturl);
            $shorturl .= "&#8230;";
        }
        ($is_url = not $is_url)
            ? qq[<a href="$encurl" title="$encurl">$shorturl</a>]
            : $encurl;
    } split /
        (
         # Something that looks like the start of a URL
         \b
         (?:https?|ftp)
         :\/\/
         .*?
         
         # Stop at one of these sequences:
         (?=
          \z # end of string
          | \s # any space
          | [,\.!\?](?:\s|\z) # punctuation then space or end
          | [\x29"'>] # any of these characters "
          )
         )
         /six, $text, -1;

    $html =~ s[\b(?:mod(?:eration)? #?|edit[#:\s]+|edit id[#:\s]+|change[#:\s]+)(\d+)\b]
         [<a href="http://$server/show/edit/?editid=$1">edit #$1</a>]gi;

    # links to wikidocs
    $html =~ s/doc:(\w[\/\w]*)(``)*/<a href="\/doc\/$1">$1<\/a>/gi;
    $html =~ s/\[(\p{IsUpper}[\/\w]*)\]/<a href="\/doc\/$1">$1<\/a>/g;

    $html =~ s/<\/?p[^>]*>//g;
    $html =~ s/<br[^>]*\/?>//g;
    $html =~ s/&#39;&#39;&#39;(.*?)&#39;&#39;&#39;/<strong>$1<\/strong>$2/g;
    $html =~ s/&#39;&#39;(.*?)&#39;&#39;/<em>$1<\/em>/g;
    $html =~ s/(\015\012|\012\015|\012|\015)/<br\/>/g;

    return $html;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
