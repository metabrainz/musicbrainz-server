#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Getopt::Long;

use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw ( $EDITOR_MODBOT $EDIT_WORK_DELETE );
use MusicBrainz::Server::Types qw( $BOT_FLAG $AUTO_EDITOR_FLAG );

my $use_auto_mod = 1;
my $moderator = $EDITOR_MODBOT;
my $remove = 1;
my $verbose;
my $summary = 1;

my $c = MusicBrainz::Server::Context->create_script_context();

GetOptions(
    "automod!"          => \$use_auto_mod,
     "moderator=s"      => sub {
        my $user = $_[1];
                my $editor = $c->model('Editor')->get_by_name ($user);
        $editor or die "No such moderator '$user'";
                $moderator = $editor->id;
     },
    "remove!"           => \$remove,
    "verbose!"          => \$verbose,
    "summary!"          => \$summary,
    "help|h|?"          => sub { usage(); exit },
) or exit 2;

usage(), exit 2 if @ARGV;

sub usage
{
    print <<EOF;
Usage: EmptyWorks.pl [OPTIONS]

Allowed options are:
        --[no]automod     [don't] automod the inserted moderations
                          (default is to automod)
        --moderator=NAME  insert the moderations as moderator NAME
                          (default is the 'ModBot')
        --[no]remove      [don't] remove unused works
                          (default is --remove)
        --[no]verbose     [don't] show information about each work
        --[no]summary     [don't] show summary information at the end
                          (default is --summary)
    -h, --help            show this help (also "-?")

EOF
}

$verbose = ($remove ? 0 : 1)
    unless defined $verbose;

print(STDERR "Running with --noremove --noverbose --nosummary is pointless\n"), exit 1
    unless $remove or $verbose or $summary;

print localtime() . " : Finding unused works (using AR criteria)\n";

my $count = 0;
my $removed = 0;
my $privs = $BOT_FLAG;
$privs |= $AUTO_EDITOR_FLAG if $use_auto_mod;

my @works = values %{
    $c->model('Work')->get_by_ids(@{
        $c->raw_sql->select_single_column_array(
            'SELECT work.id
               FROM (SELECT unnest(?::INTEGER[])) work(id)
                  WHERE NOT EXISTS (
                        SELECT TRUE FROM edit_work
                          JOIN edit ON edit.id = edit_work.edit
                         WHERE edit_work.work = work.id
                           AND edit.status = 1
                        )',
            $c->sql->select_single_column_array(
                "SELECT work.id
                   FROM work
                  WHERE (last_updated < NOW() - '1 day'::INTERVAL
                         OR last_updated IS NULL)
                    AND work.edits_pending = 0
                    AND work.id NOT IN (
                        SELECT entity1 FROM l_artist_work
                        UNION ALL
                        SELECT entity1 FROM l_label_work
                        UNION ALL
                        SELECT entity1 FROM l_recording_work
                        UNION ALL
                        SELECT entity1 FROM l_release_work
                        UNION ALL
                        SELECT entity1 FROM l_release_group_work
                        UNION ALL
                        SELECT entity1 FROM l_url_work
                        UNION ALL
                        SELECT entity0 FROM l_work_work
                        UNION ALL
                        SELECT entity1 FROM l_work_work
                    )")
        )
    })
};

for my $work (@works) {
    ++$count;

    if (not $remove)
    {
        printf "%s : Need to remove %6d %-30.30s\n",
            scalar localtime, $work->id, $work->name if $verbose;
        next;
    }

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_WORK_DELETE,
        to_delete => $work,
        editor_id => $moderator,
        privileges => $privs
    );

    printf "%s : Inserted mod %6d for %6d %-30.30s\n",
        scalar localtime, $edit->id,
        $work->id, $work->name if $verbose;

    ++$removed;
    1;
}

if ($summary)
{
    printf "%s : Found %d unused work%s.\n",
        scalar localtime,
        $count, ($count==1 ? "" : "s");
    printf "%s : Successfully removed %d work%s\n",
        scalar localtime,
        $removed, ($removed==1 ? "" : "s")
        if $remove;
}

print localtime() . " : EmptyWorks.pl finished\n";

# eof EmptyArtists.pl
