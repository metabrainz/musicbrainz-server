package MusicBrainz::Server::Data::WikiDoc;
use Moose;

use Carp;
use Readonly;
use LWP::UserAgent;
use MusicBrainz::Server::Entity::WikiDocPage;
use URI::Escape qw( uri_unescape );
use Encode qw( decode );

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

Readonly my $WIKI_CACHE_TIMEOUT => 60 * 60;

sub _fix_html_markup
{
    my ($self, $content, $index) = @_;

    my $server      = DBDefs::WEB_SERVER;
    my $wiki_server = DBDefs::WIKITRANS_SERVER;

    # remove edit links
    $content =~ s[<span class="editsection">(.*?)</span>\s*][]g;

    my $temp = "";
    while(1) {
        if ($content =~ s[(.*?)<a(\s+?)href\="(.*?)"(.*?)>(.*?)</a>(.*)][]s) {
            my ($text, $pre, $url, $post, $linktext, $etc) = ($1, $2, $3, $4, $5, $6);

            # if this is not a link to the wikidocs server, don't mess with it.
            if (!($url =~ /^http:\/\/$wiki_server/)) {
                $temp .= "$text<a".$pre."href=\"$url\"$post>$linktext</a>";
                next;
            }
            $url =~ s[http://$wiki_server/][];
            if ($url =~ /^\?title=(.*?)&amp;action=edit/) {
                $temp .= "$text $linktext ";
                next;
            }

            my $isWD = exists($index->{$url});
            my $css = $isWD ? "official" : "unofficial";
            my $title = $isWD ? "WikiDocs" : "Wiki";

            my $newpost = "";
            while (1) {
                if ($post =~ s/(\w+?)="(.*?)"//s) {
                    my ($attr, $value) = ($1, $2);
                    if ($attr eq 'title') {
                        $newpost .= " title=\"$title: $2\"";
                    }
                }
                else {
                    last;
                }
            }
            $newpost .= " class=\"$css\""; 
            $temp .= "$text<a".$pre."href=\"http://$server/doc/$url\"$newpost>$linktext</a>$etc";
        }
        else {
            last;
        }
    }
    $temp .= $content;
    $content = $temp;

    # this fixes image links to point to the wiki
    $content =~ s[src="/-/images][src="http://$wiki_server/-/images]g;

    # Remove links to images in the wiki
    $content =~ s/<a href=".*?\/doc\/Image:.*?".*?>(.*?)<\/a>/$1/g;

    # remove ugly ass border=1 from tables
    $content =~ s/table border="1"/table/g;

    # Obfuscate e-mail addresses
    $content =~ s/(\w+)\@(\w+)/$1&#x0040;$2/g;
    $content =~ s/mailto:/mailto&#x3a;/g;

    # expand placeholders which point to the current webserver [@WEB_SERVER@/someurl title]
    $content =~ s/\[\@WEB_SERVER\@([^ ]*) ([^\]]*)\]/<img src="\/images\/edit.gif" alt="" \/><a href="$1">$2<\/a>/g;

    return $content;
}

sub _create_page
{
    my ($self, $id, $version, $content, $index) = @_;

    my $title = $id;
    $title =~ s/_/ /g;

    $content = $self->_fix_html_markup($content, $index);

    my %args = ( title => $title, content  => $content );
    if (defined $version) {
        $args{version} = $version;
    }
    return MusicBrainz::Server::Entity::WikiDocPage->new(%args);
}

sub _load_page
{
    my ($self, $id, $version, $index) = @_;

    return MusicBrainz::Server::Entity::WikiDocPage->new({ canonical => "Main_Page" })
        if ($id eq "");

    my $doc_url = sprintf "http://%s/%s?action=render", &DBDefs::WIKITRANS_SERVER, $id;
    if (defined $version) {
        $doc_url .= "&oldid=$version";
    }

    my $ua = LWP::UserAgent->new(max_redirect => 0);
    $ua->env_proxy;
    my $response = $ua->get($doc_url);

    if (!$response->is_success) {
        if ($response->is_redirect && $response->header("Location") =~ /http:\/\/(.*?)\/(.*)$/) {
            return $self->get_page(uri_unescape($2));
        }
        return undef;
    }

    my $content = decode "utf-8", $response->content;
    if ($content =~ /<div class="noarticletext">/s) {
        return undef;
    }

    if ($content =~ /<span class="redirectText"><a href="http:\/\/.*?\/(.*?)"/) {
        return MusicBrainz::Server::Entity::WikiDocPage->new({ canonical => uri_unescape($1) });
    }

    return $self->_create_page($id, $version, $content, $index);
}

sub get_page
{
    my ($self, $id, $version, $index) = @_;

    my $cache = $self->c->cache('wikidoc');
    my $cache_key = defined $version ? "$id-$version" : "$id-x";

    my $page = $cache->get($cache_key);
    return $page
        if defined $page;

    $page = $self->_load_page($id, $version, $index);

    my $timeout = defined $version ? $WIKI_CACHE_TIMEOUT : undef;
    $cache->set($cache_key, $page, $timeout);

    return $page;
}

sub get_current_page_version
{
    my ($self, $id) = @_;

    my $doc_url = sprintf "http://%s/%s?action=history", &DBDefs::WIKITRANS_SERVER, $id;
    my $ua = LWP::UserAgent->new(max_redirect => 0);
    $ua->env_proxy;
    my $response = $ua->get($doc_url);

    if ($response->content =~ /amp;diff=(\d+)\&amp;oldid=/) {
        return $1;
    }
    return undef;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
