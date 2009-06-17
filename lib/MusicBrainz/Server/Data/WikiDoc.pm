package MusicBrainz::Server::Data::WikiDoc;
use Moose;

use Carp;
use MusicBrainz::Server::Entity::WikiDoc;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::WikiTransclusion;
use URI::Escape qw( uri_unescape );

use Moose;
has 'c' => (
    is => 'rw',
    isa => 'Object'
);
__PACKAGE__->meta->make_immutable;
no Moose;

sub fetch_page
{
    my ($self, $id) = @_;

    # replace spaces with _
    $id =~ s/ /_/g;
    my $title = $id;
    $title =~ s/_/ /g;

    my $wt = MusicBrainz::Server::WikiTransclusion->new($self->c->mb->dbh);
    my $index = $wt->GetPageIndex();

    if (!defined $index)
    {
        return MusicBrainz::Server::Entity::WikiDoc->new(
            result  => 500,  
            status  => "Index not available",
            id      => $id,
            title   => $title,
        );
    }

    my $is_wiki_page = exists($index->{$id}) ? 1 : 0;
    my $cache_key = "wikidocs-$id";
    my $page = MusicBrainz::Server::Cache->get($cache_key);

    if (defined $page)
    {
        return MusicBrainz::Server::Entity::WikiDoc->new(
            result  => 200,  
            body    => $page,
            id      => $id,
            title   => $title,
            version => $is_wiki_page ? $index->{$id} : 0
        );
    }

    my $doc_url = "http://" . &DBDefs::WIKITRANS_SERVER . "/"
        . $id . "?action=render"
        . ($is_wiki_page ? ("&oldid=".$index->{$id}) : "");

    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new(max_redirect => 0);
    $ua->env_proxy;
    my $response = $ua->get($doc_url);

    if (!$response->is_success)
    {
        if ($response->is_redirect &&
            $response->header("Location") =~ /http:\/\/(.*?)\/(.*)$/)
        {
            return $self->fetch_page(uri_unescape($2));
        }
        else
        {
            return MusicBrainz::Server::Entity::WikiDoc->new(
                result  => $response->code,
                status  => $response->status_line,
                id      => $id,
                title   => $title,
            );
        }
    }
    else
    {
        $page = $response->content;
        if ($page =~ /<div class="noarticletext">/s)
        {
            return MusicBrainz::Server::Entity::WikiDoc->new(
                result  => 404,  
                status  => "Ooops! Page not found (404).",
                id      => $id,
                title   => $title,
            );
        }
        elsif ($page =~ /<span class="redirectText"><a href="http:\/\/.*?\/(.*?)"/)
        {
            return $self->fetch_page(uri_unescape($1));
        }
        else
        {
            my $server      = DBDefs::WEB_SERVER;
            my $wiki_server = DBDefs::WIKITRANS_SERVER;

            # remove edit links
            $page =~ s[<span class="editsection">(.*?)</span>][]g;

            my $temp = "";
            while(1)
            {
                if ($page =~ s=(.*?)<a(\s+?)href\="(.*?)"(.*?)>(.*?)</a>==s)
                {
                    my ($text, $pre, $url, $post, $linktext) = ($1, $2, $3, $4, $5);

                    # if this is not a link to the wikidocs server, don't mess with it.
                    if (!($url =~ /^http:\/\/$wiki_server/))
                    {
                        $temp .= "$text<a".$pre."href=\"$url\"$post>$linktext</a>";
                        next;
                    }
                    $url =~ s-http://$wiki_server/--;
                    if ($url =~ /^\?title=(.*?)&amp;action=edit/)
                    {
                        $temp .= "$text $linktext ";
                        next;
                    }

                    my $isWD = exists($index->{$url});
                    my $css = $isWD ? "official" : "unofficial";
                    my $title = $isWD ? "WikiDocs" : "Wiki";

                    my $newpost = "";
                    for(;;)
                    {
                        if ($post =~ s/(\w+?)="(.*?)"//s)
                        {
                            my ($attr, $value) = ($1, $2);
                            if ($attr eq 'title')
                            {
                                $newpost .= " title=\"$title: $2\"";
                            }
                        }
                        else
                        {
                            last;
                        }
                    }
                    $newpost .= " class=\"$css\""; 
                    $temp .= "$text<a".$pre."href=\"http://$server/doc/$url\"$newpost>$linktext</a>";
                }
                else
                {
                    last;
                }
            }
            $temp .= $page;
            $page = $temp;

            # this fixes image links to point to the wiki
            $page =~ s[src="/-/images][src="http://$wiki_server/-/images]g;

            # Remove links to images in the wiki
            $page =~ s/<a href=".*?\/doc\/Image:.*?".*?>(.*?)<\/a>/$1/g;

            # remove ugly ass border=1 from tables
            $page =~ s/table border="1"/table/g;

            # Obfuscate e-mail addresses
            $page =~ s/(\w+)\@(\w+)/$1&#x0040;$2/g;
            $page =~ s/mailto:/mailto&#x3a;/g;

            # expand placeholders which point to the current webserver [@WEB_SERVER@/someurl title]
            $page =~ s/\[\@WEB_SERVER\@([^ ]*) ([^\]]*)\]/<img src="\/images\/edit.gif" alt="" \/><a href="$1">$2<\/a>/g;

            # Now store page in cache
            MusicBrainz::Server::Cache->set($cache_key, $page, &MusicBrainz::Server::WikiTransclusion::CACHE_INTERVAL);

            return MusicBrainz::Server::Entity::WikiDoc->new(
                result  => 200,  
                body    => $page,
                id      => $id,
                title   => $title,
                version => $is_wiki_page ? $index->{$id} : 0
            );
        }
    }
}

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
