package MusicBrainz::Server::Model::Documentation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;
use DBDefs;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::WikiTransclusion;

sub fetch_page
{
    my ($self, $id) = @_;

    my $wt = MusicBrainz::Server::WikiTransclusion->new($self->dbh);
    my $index = $wt->GetPageIndex();

    if (!defined $index)
    {
        return {
            success => 0,
            status  => "Index not available",
            id      => $id,
        };
    }

    my $is_wiki_page = exists($index->{$id}) ? 1 : 0;
    my $cache_key = "wikidocs-$id";
    my $page = MusicBrainz::Server::Cache->get($cache_key);

    if (defined $page)
    {
        return {
            success => 1,
            body    => $page,
            id      => $id,
        };
    }

    my $doc_url = sprintf ('http://%s/%s?action=ContentRev',
                           DBDefs::WIKITRANS_SERVER, $id);

    if ($is_wiki_page) { $doc_url .= $index->{id}; }

    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new(max_redirect => 0);
    $ua->env_proxy;
    my $response = $ua->get($doc_url);

    if (!$response->is_success)
    {
        if ($response->is_redirect &&
            $response->header("Location") =~ /http:\/\/(.*?)\/(.*)$/)
        {
            return $self->fetch_page($1);
        }
        else
        {
            return {
                success => 0,
                status  => $response->status_line,
                page_id => $id,
            };
        }
    }
    else
    {
        $page = $response->content;
        if ($page =~ /<a id="top"><\/a>\s+<a id="bottom"><\/a>/s)
        {
            return {
                success => 0,
                status  => 404,
                page_id => $id,
            };
        }
        else
        {
            my $server      = DBDefs::WEB_SERVER;
            my $wiki_server = DBDefs::WIKITRANS_SERVER;

            # Remove intertwingled links to non-existent pages.
            $page =~ s/<a class="nonexistent" [^>]+>([^<]+)<\/a>/$1/g;

            # Remove intertwingled links to non-existent pages (if nonexist_qm=1)
			$page =~ s/<a class="nonexistent" [^>]+>\?<\/a>//g;

			# Remove intertwingled links to non-existent pages (if nonexist_qm=0)
			$page =~ s/<a class="nonexistent" [^>]+>([^<]+)<\/a>/$1/g;

            $page =~ s[href="http:/(\w)]['href="http://' . $server . "/$1"]eg;

            # Change main div id to be wiki_content
            $page =~ s/id="content/id="wiki_content/ig;

            my $temp = "";
            while (1)
            {
                if ($page =~ s/(.*?)<a(.*?)href="\/(.*?)"(.*?)>(.*?)<\/a>//s)
                {
                    my ($pre, $href, $rep, $post, $linktext) = ($1, $2, $3, $4, $5);
                    
                    # Distinguish between wikidocs and normal wiki pages.
                    my $is_wiki_doc = exists($index->{$rep});
                    my $css         = $is_wiki_doc ? "official" : "unofficial";
                    my $title       = $is_wiki_doc ? "Wiki docs link" : "Wiki link";
                    
                    $temp .= qq!$pre<a$href class="$css" title="$title" href="http://$server/doc/$rep"$post>$linktext</a>!;
                }
                else
                {
                    $temp .= $page;
                    last;
                }
			}
            $page = $temp;

            # This fixes image links to point to the wiki
            $page =~ s[src="/-/]['src="http://' . $wiki_server . "/-/$1"]eg;

            # Assume img src URLs which contain "AttachFile&amp;do=get" are attachments to the
			# wiki page being transcluded.
            # TODO : Does this strain the wiki server too much?
            $page =~ s[<img src="([^"]*action=AttachFile&amp;do=get[^"]*)"][<img src="http://wiki.musicbrainz.org$1"]g;
            $page =~ s[(<a href="http:\/\/(www\.)?musicbrainz.org.*?">)<img src="http:\/\/wiki.musicbrainz.org\/-\/musicbrainz\/img\/moin-www\.png".*?>][$1]g;

            # Remove external links icons from links that point to mb.org
            $page =~ s[(<a href="http:\/\/(www\.)?musicbrainz.org.*?">)<img src="http:\/\/wiki.musicbrainz.org\/-\/musicbrainz\/img\/moin-www\.png".*?>][$1]g;

            # Move headers one level up
            $page =~ s/<(\/?)h2/<$1h1/ig;
            $page =~ s/<(\/?)h3/<$1h2/ig;
            $page =~ s/<(\/?)h4/<$1h3/ig;
            $page =~ s/<(\/?)h5/<$1h4/ig;

            # Fix code blocks
            $page =~ s/&lt;code&gt;/<code>/ig;
            $page =~ s/&lt;\/code&gt;/<\/code>/ig;

            # Obfuscate email addresses
            $page =~ s/(\w+)\@(\w+)/$1&#x0040;$2/g;
            $page =~ s/mailto:/mailto&#x3a;/g;

            # Expand placeholders which point to the current webserver [@WEB_SERVER@/someurl title]
            $page =~ s/\[\@WEB_SERVER\@([^ ]*) ([^\]]*)\]/<img src="\/images\/edit.gif" alt="" \/><a href="$1">$2<\/a>/g;

            # Now store page in cache
            MusicBrainz::Server::Cache->set($cache_key, $page, MusicBrainz::Server::WikiTransclusion::CACHE_INTERVAL);

            return {
                success => 1,
                body    => $page
            };
        }
    }
}

1;
