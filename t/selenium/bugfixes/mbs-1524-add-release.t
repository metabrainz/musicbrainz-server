use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://localhost:3000" );

$sel->open_ok("/release/add?release-group=153f0a09-fead-3370-9b17-379ebd09446b");
$sel->type_ok("annotation", "this is an annotation to test MBS-1524.");
$sel->click_ok("step_tracklist");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("css=textarea.tracklist", "1. foo\n2. bar");
$sel->fire_event_ok("css=textarea.tracklist", "blur");
$sel->click_ok("step_editnote");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_element_present_ok("css=table.add-release-annotation");
ok(not $sel->is_text_present("[deleted]"));
$sel->text_is("css=table.add-release-annotation td p", "this is an annotation to test MBS-1524.");
