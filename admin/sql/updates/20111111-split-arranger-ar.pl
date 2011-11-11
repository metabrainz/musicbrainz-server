#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

$c->sql->begin;

my @updated_link_type_ids;
my @updated_link_ids;

my @link_type_gids = (
	'0084e70a-873e-4f7f-b3ff-635b9e863dae', # artist:work
	'18f159bb-44f0-4aef-b198-a4736ad9b659', # artist:release
	'4820daa1-98d6-4f8b-aa4b-6895c5b79b27'  # artist:recording
);

for my $gid (@link_type_gids) {

    my $link_type_instrument = $c->model('LinkType')->get_by_gid($gid);

    my $link_type_generic = $c->model('LinkType')->insert({
        parent_id           => $link_type_instrument->parent_id,
        entity0_type        => $link_type_instrument->entity0_type,
        entity1_type        => $link_type_instrument->entity1_type,
        child_order         => $link_type_instrument->child_order,
        name                => 'arranger',
        description         => $link_type_instrument->description,
        link_phrase         => '{additional:additionally} arranged',
        reverse_link_phrase => '{additional} arranger',
        short_link_phrase   => '{additional:additionally} arranged',
        attributes          => [
            { type => 1, min => 0, max => 1 },      # additional
        ],
    });

    my $link_type_vocal = $c->model('LinkType')->insert({
        parent_id           => $link_type_generic->id,
        entity0_type        => $link_type_instrument->entity0_type,
        entity1_type        => $link_type_instrument->entity1_type,
        child_order         => 2,
        name                => 'vocal arranger',
        description         => $link_type_instrument->description,
        link_phrase         => '{additional:additionally} {vocal} vocal arranged',
        reverse_link_phrase => '{additional} {vocal} vocal arranger',
        short_link_phrase   => '{additional:additionally} arranged {vocal} vocal on',
        attributes          => [
            { type => 1, min => 0, max => 1 },      # additional
            { type => 3, min => 0, max => undef },  # vocal
        ],
    });

    $c->model('LinkType')->update($link_type_instrument->id, {
        parent_id           => $link_type_generic->id,
        child_order         => 1,
        name                => 'instrument arranger',
        short_link_phrase   => '{additional:additionally} arranged {instrument} on',
        attributes          => [
            { type => 1, min => 0, max => 1 },      # additional
            { type => 14, min => 1, max => undef }, # instrument
        ],
    });

    push @updated_link_type_ids, $link_type_instrument->id;

    my $link_ids = $c->sql->select_single_column_array(
        "SELECT id FROM link WHERE link_type = ?",
        $link_type_instrument->id);

    my $links = $c->model('Link')->get_by_ids(@$link_ids);
    for my $link_id (@$link_ids) {
        my $link = $links->{$link_id};
        unless ($link->has_attribute('instrument')) {
            print "Updating link $link_id to link_type " . $link_type_generic->id . "\n";
            $c->sql->update_row('link',
                { link_type => $link_type_generic->id },
                { id => $link_id });
            push @updated_link_ids, $link->id;
        }
    }

}

$c->sql->commit;

$c->model('LinkType')->_delete_from_cache(@updated_link_type_ids);
$c->model('Link')->_delete_from_cache(@updated_link_ids);

