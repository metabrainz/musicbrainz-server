use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://localhost:3000/" );

$sel->open_ok("/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7/edit");
$sel->click_ok("step_tracklist");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=Advanced");
WAIT: {
    for (1..60) {
        if (eval { $sel->is_element_present("css=input.track-name:eq(1)") }) { pass; last WAIT }
        sleep(1);
    }
    fail("timeout");
}
$sel->type_ok("css=input.track-name:eq(1)", "the Love Bug (MBS-1204 test edit)");
$sel->type_ok("css=input.pos:eq(1)", "3");
$sel->type_ok("css=input.pos:eq(3)", "1");
$sel->click_ok("step_recordings");
$sel->wait_for_page_to_load_ok("30000");
$sel->value_is("rec_mediums.0.associations.0.confirmed", "1");
$sel->value_is("rec_mediums.0.associations.1.confirmed", "1");
$sel->value_is("rec_mediums.0.associations.2.confirmed", "");
$sel->value_is("rec_mediums.0.associations.0.gid", "3f33fc37-43d0-44dc-bfd6-60efd38810c5");
$sel->value_is("rec_mediums.0.associations.1.gid", "84c98ebf-5d40-4a29-b7b2-0e9c26d9061d");
$sel->value_is("rec_mediums.0.associations.2.gid", "0cf3008f-e246-428f-abc1-35f87d584d60");
$sel->click_ok("link=Confirm");
$sel->click_ok("link=Done");
$sel->click_ok("css=a[href=#change-recording]:eq(2)");
$sel->click_ok("css=input.newrecording:eq(1)");
$sel->click_ok("step_tracklist");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("step_recordings");
$sel->wait_for_page_to_load_ok("30000");
$sel->value_is("rec_mediums.0.associations.1.gid", "new");
