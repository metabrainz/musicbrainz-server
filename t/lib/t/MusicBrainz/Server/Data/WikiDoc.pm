package t::MusicBrainz::Server::Data::WikiDoc;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use FindBin qw($Bin);
use LWP;
use LWP::UserAgent::Mockable;
use MusicBrainz::Server::Test;
use Test::More;

use MusicBrainz::Server::Data::WikiDoc;

with 't::Context';

=head1 DESCRIPTION

This test checks that WikiDoc _create_page works and that redirects
are followed.

=cut

test '_create_page' => sub {
    my $test = shift;
    my $wd_data = $test->c->model('WikiDoc');

    my $page = $wd_data->_create_page('Artist_Name', 123, <<~'HTML');
        <h3>
            <span class="editsection">
                [<a
                    href="http://wiki.musicbrainz.org/?title=Artist_Name&amp;action=edit&amp;section=6"
                    title="Edit section: Section"
                 >edit</a>]
            </span>
             Section</h3>
        <p>Foo</p>
        HTML

    is($page->title, 'Artist Name', 'Created page has the right title');
    is($page->version, 123, 'Created page has the right version number');
    like(
        $page->content,
        qr{<h3> Section</h3>},
        'Created page contains the intended header',
    );
};

test 'Redirect resolution' => sub {
    my $test = shift;
    my $wd_data = $test->c->model('WikiDoc');

    LWP::UserAgent::Mockable->reset( playback => $Bin.'/lwp-sessions/data_wikidoc.xmlwebservice-redirect.lwp-mock' );
    LWP::UserAgent::Mockable->set_playback_validation_callback(\&basic_validation);

    my $page = $wd_data->get_page('XML_Webservice');
    is(
        $page->canonical,
        'Development/XML_Web_Service/Version_2',
        'Getting a page from a redirect returns the right canonical page title',
    );

    LWP::UserAgent::Mockable->finished;
};

sub basic_validation {
    my ($actual, $expected) = @_;
    is($actual->uri, $expected->uri, 'Called ' . $expected->uri);
    is($actual->method, $expected->method, 'Method is ' . $expected->method);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
