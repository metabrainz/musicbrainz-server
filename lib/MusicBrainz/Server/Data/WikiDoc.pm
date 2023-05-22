package MusicBrainz::Server::Data::WikiDoc;
use Moose;
use namespace::autoclean;

use Carp;
use Readonly;
use HTML::TreeBuilder::XPath;
use MusicBrainz::Server::Entity::WikiDocPage;
use MusicBrainz::Server::ExternalUtils qw( get_chunked_with_retry );
use URI::Escape qw( uri_escape_utf8 uri_unescape );
use Encode qw( decode );

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $WIKI_CACHE_TIMEOUT => 60 * 60;
Readonly my $WIKI_IMAGE_PREFIX => '/-/images';

sub _fix_html_links
{
    my ($self, $node, $index) = @_;

    my $wiki_server = DBDefs->WIKITRANS_SERVER;

    my $class = $node->attr('class') || '';

    # Remove the title attribute from all links
    $node->attr('title', undef);

    # if this is not a link to _our_ wikidocs server, don't mess with it.
    return if ($class =~ m/external/ || $class =~ m/extiw/);

    my $href = $node->attr('href') || '';

    if ($href =~ m,^(?:https?:)?//$wiki_server/(File|Image):, || $class =~ m/new/)
    {
        my $child = $node->getFirstChild();
        if (defined $child && ref($child) eq 'HTML::Element' && $child->tag eq 'img' && ($child->attr('class') // '') eq 'zoomable')
        {
            # Transform link on "zoomable" image to point directly to the original image
            my $href = $child->attr('src') || '';
            $href =~ s,^$WIKI_IMAGE_PREFIX,//$wiki_server$WIKI_IMAGE_PREFIX,;
            $href =~ s,^(//$wiki_server$WIKI_IMAGE_PREFIX)/thumb(.*)/[0-9]+px-[^/]*$,$1$2,;
            $node->attr('href', $href);
            $node->attr('title', 'Open in a new tab');
            $node->attr('target', '_blank');
        }
        else
        {
            # Remove broken links & links to images in the wiki otherwise
            $node->replace_with($node->content_list);
        }
    }
    # if this is not a link to the wikidocs server, don't mess with it.
    elsif ($href =~ m,^(?:https?:)?//$wiki_server,)
    {
        $href =~ s,^(?:https?:)?//$wiki_server/?,/doc/,;
        $node->attr('href', $href);
    }
    elsif ($href =~ m,^$WIKI_IMAGE_PREFIX,) {
        $href =~ s,$WIKI_IMAGE_PREFIX?,//$wiki_server$WIKI_IMAGE_PREFIX,;
        $node->attr('href', $href);
    }
}

sub _fix_html_markup
{
    my ($self, $content, $index) = @_;

    my $wiki_server = DBDefs->WIKITRANS_SERVER;
    my $tree = HTML::TreeBuilder::XPath->new;

    $tree->parse_content('<html><body>'.$content.'</body></html>');
    for my $node ($tree->findnodes(
                      '//span[contains(@class, "editsection")]')->get_nodelist)
    {
        $node->delete();
    }

    for my $node ($tree->findnodes('//a')->get_nodelist)
    {
        $self->_fix_html_links($node, $index);
    }

    for my $node ($tree->findnodes('//img')->get_nodelist)
    {
        my $src = $node->attr('src') || '';
        $node->attr('src', $src) if ($src =~ s,$WIKI_IMAGE_PREFIX,//$wiki_server$WIKI_IMAGE_PREFIX,);
        # Also re-write srcset values
        my $srcset = $node->attr('srcset') || '';
        $node->attr('srcset', $srcset) if ($srcset =~ s,$WIKI_IMAGE_PREFIX,//$wiki_server$WIKI_IMAGE_PREFIX,g);
    }

    for my $node ($tree->findnodes('//table')->get_nodelist)
    {
        my $class = $node->attr('class') || '';

        # Special cases where we don't want this class added
        next if ($class =~ /(\btoc\b|\btbl\b)/);

        $node->attr('class', 'wikitable ' . $class);
    }

    $content = $tree->as_HTML;

    # Obfuscate email addresses
    $content =~ s/(\w+)\@(\w+)/$1&#x0040;$2/g;
    $content =~ s/mailto:/mailto&#x3a;/g;

    return $content;
}

sub _create_page
{
    my ($self, $id, $version, $content, $index) = @_;

    my $title = $id =~ tr/_/ /r;
    # Create hierarchy for displaying in the h1
    my @hierarchy = split('/',$title);

    # Format nicely for <title>
    $title =~ s,/, / ,g;

    $content = $self->_fix_html_markup($content, $index);

    my %args = ( title => $title, hierarchy => \@hierarchy, content  => $content );
    if (defined $version) {
        $args{version} = $version;
    }
    return MusicBrainz::Server::Entity::WikiDocPage->new(%args);
}

sub _load_page
{
    my ($self, $id, $version, $index) = @_;

    return MusicBrainz::Server::Entity::WikiDocPage->new({ canonical => 'MusicBrainz_Documentation' })
        if ($id eq '');

    my $doc_url = sprintf 'http://%s/%s?action=render&redirect=no', DBDefs->WIKITRANS_SERVER, uri_escape_utf8($id);
    if (defined $version) {
        $doc_url .= "&oldid=$version";
    }

    my $response = get_chunked_with_retry($self->c->lwp, $doc_url);

    return undef unless $response;

    if (!$response->is_success) {
        if ($response->is_redirect && $response->header('Location') =~ /https?:\/\/(.*?)\/(.*)$/) {
            return $self->get_page(uri_unescape($2));
        }
        return undef;
    }

    my $content = decode 'utf-8', $response->content;
    if ($content =~ /<title>Error/s) {
        return undef;
    }

    if ($content =~ /<div class="noarticletext">/s) {
        return undef;
    }

    if ($content =~ m{<ul class="redirectText"><li><a href="(?:https?:)?(?://[^/]+)?/(.*?)"}) {
        return MusicBrainz::Server::Entity::WikiDocPage->new({ canonical => uri_unescape($1) });
    }

    return $self->_create_page($id, $version, $content, $index);
}

sub get_page
{
    my ($self, $id, $version, $index) = @_;

    my $prefix = 'wikidoc';
    my $cache = $self->c->cache($prefix);
    my $cache_key = defined $version ? "$prefix:$id:$version" : "$prefix:$id:current";

    my $page = $cache->get($cache_key);
    return $page
        if defined $page;

    $page = $self->_load_page($id, $version, $index) or return undef;

    $cache->set($cache_key, $page, $WIKI_CACHE_TIMEOUT);

    return $page;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
