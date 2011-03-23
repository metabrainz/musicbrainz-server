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

$sel->open_ok("/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7/edit");
$sel->click_ok("step_tracklist");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=Add Disc");
$sel->type_ok("css=textarea.tracklist:eq(1)", "1. I do not really want to add this disc (4:45)");
$sel->fire_event_ok("css=textarea.tracklist:eq(1)", "blur");
$sel->click_ok("id-next");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("id-previous");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("css=#mediums\\.1\\.basicdisc input.remove-disc");
$sel->click_ok("id-next");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("step_editnote");
$sel->wait_for_page_to_load_ok("30000");
ok(not $sel->is_element_present("css=table.add-medium"));
