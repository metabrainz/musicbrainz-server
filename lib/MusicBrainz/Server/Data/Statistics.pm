package MusicBrainz::Server::Data::Statistics;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Server::Types qw( :edit_status :vote );
use MusicBrainz::Server::Constants qw( $VARTIST_ID $EDITOR_MODBOT $EDITOR_FREEDB :quality );
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Entity::Statistics;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Sql';

sub _table { 'statistic' }

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Statistics';
}

sub fetch {
    my ($self, @names) = @_;

    my $query = 'SELECT name, value FROM ' . $self->_table;
    $query .= ' WHERE name IN (' . placeholders(@names) . ')' if @names;

    my %stats =
        map { $_->{name} => $_->{value} }
        @{ $self->sql->select_list_of_hashes($query, @names) };

    if (@names) {
        if(wantarray) {
            return @stats{@names};
        }
        else {
            my $value = $stats{ $names[0] }
                or warn "No statistics for '$names[0]'";
            return $value;
        }
    }
    else {
        return \%stats;
    }
}

sub insert {
    my ($self, %updates) = @_;
    $self->sql->do('LOCK TABLE ' . $self->_table . ' IN EXCLUSIVE MODE');
    for my $key (keys %updates) {
        next unless defined $updates{$key};

        $self->sql->insert_row(
            $self->_table,
            { name => $key, value => $updates{$key} }
        );
    }
}

sub last_refreshed {
    my $self = shift;
    return $self->sql->select_single_value(
        'SELECT min(date_collected) FROM ' . $self->_table);
}

my %stats = (
    "count.release" => {
        DESC => "Count of all releases",
        SQL => "SELECT COUNT(*) FROM release",
    },
    "count.releasegroup" => {
        DESC => "Count of all release groups",
        SQL => "SELECT COUNT(*) FROM release_group",
    },
    "count.artist" => {
        DESC => "Count of all artists",
        SQL => "SELECT COUNT(*) FROM artist",
    },
    "count.label" => {
        DESC => "Count of all labels",
        SQL => "SELECT COUNT(*) FROM label",
    },
    "count.discid" => {
        DESC => "Count of all disc IDs",
        SQL => "SELECT COUNT(*) FROM cdtoc",
    },
    "count.edit" => {
        DESC => "Count of all edits",
        SQL => "SELECT COUNT(*) FROM edit",
        DB => 'RAWDATA'
    },
    "count.editor" => {
        DESC => "Count of all editors",
        SQL => "SELECT COUNT(*) FROM editor",
    },
    "count.barcode" => {
        DESC => "Count of all unique Barcodes",
        SQL => "SELECT COUNT(distinct barcode) FROM release",
    },
    "count.puid" => {
        DESC => "Count of all PUIDs joined to recordings",
        SQL => "SELECT COUNT(*) FROM recording_puid",
    },
    "count.puid.ids" => {
        DESC => "Count of unique PUIDs",
        SQL => "SELECT COUNT(DISTINCT puid) FROM recording_puid",
    },
    "count.track" => {
        DESC => "Count of all tracks",
        SQL => "SELECT COUNT(*) FROM track",
    },
    "count.recording" => {
        DESC => "Count of all recordings",
        SQL => "SELECT COUNT(*) FROM recording",
    },
    "count.work" => {
        DESC => "Count of all works",
        SQL => "SELECT COUNT(*) FROM work",
    },
    "count.artistcredit" => {
        DESC => "Count of all artist credits",
        SQL => "SELECT COUNT(*) FROM artist_credit",
    },
    "count.isrc.all" => {
        DESC => "Count of all ISRCs joined to recordings",
        SQL => "SELECT COUNT(*) FROM isrc",
    },
    "count.isrc" => {
        DESC => "Count of unique ISRCs",
        SQL => "SELECT COUNT(distinct isrc) FROM isrc",
    },
    "count.vote" => {
        DESC => "Count of all votes",
        SQL => "SELECT COUNT(*) FROM vote",
        DB => 'RAWDATA'
    },
    "count.release.various" => {
        DESC => "Count of all 'Various Artists' releases",
        SQL => 'SELECT COUNT(*) FROM release
                  JOIN artist_credit ac ON ac.id = artist_credit
                  JOIN artist_credit_name acn ON acn.artist_credit = ac.id
                 WHERE artist_count = 1 AND artist = ' . $VARTIST_ID,
    },
    "count.release.nonvarious" => {
        DESC => "Count of all releases, other than 'Various Artists'",
        PREREQ => [qw[ count.release count.release.various ]],
        CALC => sub {
            my ($self, $sql) = @_;

            $self->fetch("count.release")
                - $self->fetch("count.release.various")
        },
    },
    "count.medium.has_discid" => {
        DESC => "Count of media with at least one disc ID",
        SQL => "SELECT COUNT(DISTINCT medium)
                  FROM medium_cdtoc",
    },

    "count.recording.has_isrc" => {
        DESC => "Count of recordings with at least one ISRC",
        SQL => "SELECT COUNT(DISTINCT recording) FROM isrc",
    },
    "count.recording.has_puid" => {
        DESC => "Count of recordings with at least one PUID",
        SQL => "SELECT COUNT(DISTINCT recording) FROM recording_puid",
    },

    "count.edit.open" => {
        DESC => "Count of open edits",
        DB => 'RAWDATA',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT status, COUNT(*) FROM edit GROUP BY status",
            );

            my %dist = map { @$_ } @$data;

            +{
                "count.edit.open"           => $dist{$STATUS_OPEN}          || 0,
                "count.edit.applied"        => $dist{$STATUS_APPLIED}       || 0,
                "count.edit.failedvote" => $dist{$STATUS_FAILEDVOTE}    || 0,
                "count.edit.faileddep"  => $dist{$STATUS_FAILEDDEP}     || 0,
                "count.edit.error"      => $dist{$STATUS_ERROR}         || 0,
                "count.edit.failedprereq"   => $dist{$STATUS_FAILEDPREREQ}  || 0,
                "count.edit.evalnochange"   => 0,
                "count.edit.tobedeleted"    => $dist{$STATUS_TOBEDELETED}   || 0,
                "count.edit.deleted"        => $dist{$STATUS_DELETED}       || 0,
            };
        },
    },
    "count.edit.applied" => {
        DESC => "Count of applied edits",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.failedvote" => {
        DESC => "Count of edits which were voted down",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.faileddep" => {
        DESC => "Count of edits which failed their dependency check",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.error" => {
        DESC => "Count of edits which failed because of an internal error",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.failedprereq" => {
        DESC => "Count of edits which failed because a prerequisitite moderation failed",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.evalnochange" => {
        DESC => "Count of evalnochange edits",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.tobedeleted" => {
        DESC => "Count of edits marked as 'to be deleted'",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.deleted" => {
        DESC => "Count of deleted edits",
        PREREQ => [qw[ count.edit.open ]],
        PREREQ_ONLY => 1,
    },
    "count.edit.perday" => {
        DESC => "Count of edits per day",
        SQL => "SELECT count(id) FROM edit
                WHERE open_time >= (now() - interval '1 day')
                  AND editor NOT IN (". $EDITOR_FREEDB .", ". $EDITOR_MODBOT .")",
        DB => 'RAWDATA'
    },
    "count.edit.perweek" => {
        DESC => "Count of edits per week",
        SQL => "SELECT count(id) FROM edit
                WHERE open_time >= (now() - interval '7 days')
                  AND editor NOT IN (". $EDITOR_FREEDB .", ". $EDITOR_MODBOT .")",
        DB => 'RAWDATA'
    },

    "count.cdstub" => {
        DESC => "Count of all existing CD Stubs",
        SQL => "SELECT COUNT(*) FROM release_raw",
        DB => 'RAWDATA'
    },
    "count.cdstub.submitted" => {
        DESC => "Count of all submitted CD Stubs",
        SQL => "SELECT MAX(id) FROM release_raw",
        DB => 'RAWDATA'
    },
    "count.cdstub.track" => {
        DESC => "Count of all CD Stub tracks",
        SQL => "SELECT COUNT(*) FROM track_raw",
        DB => 'RAWDATA'
    },

    "count.vote.yes" => {
        DESC => "Count of 'yes' votes",
        DB => 'RAWDATA',
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT vote, COUNT(*) FROM vote GROUP BY vote",
            );

            my %dist = map { @$_ } @$data;

            +{
                "count.vote.yes"        => $dist{$VOTE_YES} || 0,
                "count.vote.no"         => $dist{$VOTE_NO}  || 0,
                "count.vote.abstain"    => $dist{$VOTE_ABSTAIN} || 0,
            };
        },
    },
    "count.vote.no" => {
        DESC => "Count of 'no' votes",
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
    },
    "count.vote.abstain" => {
        DESC => "Count of 'abstain' votes",
        PREREQ => [qw[ count.vote.yes ]],
        PREREQ_ONLY => 1,
    },
    "count.vote.perday" => {
        DESC => "Count of votes per day",
        DB => 'RAWDATA',
        SQL => "SELECT count(id) FROM vote
                WHERE vote_time >= (now() - interval '1 day')
                  AND vote <> ". $VOTE_ABSTAIN,
    },
    "count.vote.perweek" => {
        DESC => "Count of votes per week",
        DB => 'RAWDATA',
        SQL => "SELECT count(id) FROM vote
                WHERE vote_time >= (now() - interval '7 days')
                  AND vote <> ". $VOTE_ABSTAIN,
    },

    # count active moderators in last week(?)
    # editing / voting / overall

    "count.editor.editlastweek" => {
        DESC => "Count of editors who have submitted edits during the last week",
        DB => 'RAWDATA',
        CALC => sub {
            my ($self, $sql) = @_;

            my $threshold_id = $sql->select_single_value(
                "SELECT MAX(id) FROM edit
                WHERE open_time <= (now() - interval '7 days')",
            );

            # Active voters
            my $voters = $sql->select_single_value(
                "SELECT COUNT(DISTINCT editor)
                FROM vote
                WHERE edit > ?
                AND editor != ?",
                $threshold_id,
                $EDITOR_FREEDB,
            );

            # Editors
            my $editors = $sql->select_single_value(
                "SELECT COUNT(DISTINCT editor)
                FROM edit
                WHERE id > ?
                AND editor != ?",
                $threshold_id,
                $EDITOR_FREEDB,
            );

            # Either
            my $both = $sql->select_single_value(
                "SELECT COUNT(DISTINCT m) FROM (
                    SELECT editor AS m
                    FROM edit
                    WHERE id > ?
                    UNION
                    SELECT editor AS m
                    FROM vote
                    WHERE edit > ?
                ) t WHERE m != ?",
                $threshold_id,
                $threshold_id,
                $EDITOR_FREEDB,
            );
            
            +{
                "count.editor.editlastweek" => $editors,
                "count.editor.votelastweek" => $voters,
                "count.editor.activelastweek"=> $both,
            };
        },
    },
    "count.editor.votelastweek" => {
        DESC => "Count of editors who have voted on edits during the last week",
        PREREQ => [qw[ count.editor.editlastweek ]],
        PREREQ_ONLY => 1,
    },
    "count.editor.activelastweek" => {
        DESC => "Count of active editors (editing or voting) during the last week",
        PREREQ => [qw[ count.editor.editlastweek ]],
        PREREQ_ONLY => 1,
    },

    # To add?
    # - top 10 moderators
    #   - open and accepted last week
    #   - accepted all time
    # Top 10 voters all time

    # Tags
    "count.tag" => {
        DESC => "Count of all tags",
        SQL => "SELECT COUNT(*) FROM tag",
    },
    "count.tag.raw.artist" => {
        DESC => "Count of all artist raw tags",
        SQL => "SELECT COUNT(*) FROM artist_tag_raw",
        DB => 'RAWDATA'
    },
    "count.tag.raw.label" => {
        DESC => "Count of all label raw tags",
        SQL => "SELECT COUNT(*) FROM label_tag_raw",
        DB => 'RAWDATA'
    },
    "count.tag.raw.releasegroup" => {
        DESC => "Count of all release-group raw tags",
        SQL => "SELECT COUNT(*) FROM release_group_tag_raw",
        DB => 'RAWDATA'
    },
    "count.tag.raw.release" => {
        DESC => "Count of all release raw tags",
        SQL => "SELECT COUNT(*) FROM release_tag_raw",
        DB => 'RAWDATA'
    },
    "count.tag.raw.recording" => {
        DESC => "Count of all recording raw tags",
        SQL => "SELECT COUNT(*) FROM recording_tag_raw",
        DB => 'RAWDATA'
    },
    "count.tag.raw.work" => {
        DESC => "Count of all work raw tags",
        SQL => "SELECT COUNT(*) FROM work_tag_raw",
        DB => 'RAWDATA'
    },
    "count.tag.raw" => {
        DESC => "Count of all raw tags",
        PREREQ => [qw[ count.tag.raw.artist count.tag.raw.label count.tag.raw.release count.tag.raw.releasegroup count.tag.raw.recording count.tag.raw.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.tag.raw.artist') + 
                   $self->fetch('count.tag.raw.label') +
                   $self->fetch('count.tag.raw.release') +
                   $self->fetch('count.tag.raw.releasegroup') +
                   $self->fetch('count.tag.raw.work') +
                   $self->fetch('count.tag.raw.recording');
        },
    },

    # Ratings
    "count.rating.artist" => {
        DESC => "Count of artist ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM artist_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.artist"       => $data->[0]   || 0,
                "count.rating.raw.artist"   => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.artist" => {
        DESC => "Count of all artist raw ratings",
        PREREQ => [qw[ count.rating.artist ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.releasegroup" => {
        DESC => "Count of release group ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM release_group_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.releasegroup"     => $data->[0]   || 0,
                "count.rating.raw.releasegroup" => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.releasegroup" => {
        DESC => "Count of all release group raw ratings",
        PREREQ => [qw[ count.rating.releasegroup ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.recording" => {
        DESC => "Count of recording ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM recording_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.recording"        => $data->[0]   || 0,
                "count.rating.raw.recording"    => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.recording" => {
        DESC => "Count of all recording raw ratings",
        PREREQ => [qw[ count.rating.track ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.label" => {
        DESC => "Count of label ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM label_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.label"        => $data->[0]   || 0,
                "count.rating.raw.label"    => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.label" => {
        DESC => "Count of all label raw ratings",
        PREREQ => [qw[ count.rating.label ]],
        PREREQ_ONLY => 1,
    },
    "count.rating.work" => {
        DESC => "Count of work ratings",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_single_row_array(
                "SELECT COUNT(*), SUM(rating_count) FROM work_meta WHERE rating_count > 0",
            );

            +{
                "count.rating.work"        => $data->[0]   || 0,
                "count.rating.raw.work"    => $data->[1]   || 0,
            };
        },
    },
    "count.rating.raw.work" => {
        DESC => "Count of all work raw ratings",
        PREREQ => [qw[ count.rating.work ]],
        PREREQ_ONLY => 1,
    },
    "count.rating" => {
        DESC => "Count of all ratings",
        PREREQ => [qw[ count.rating.artist count.rating.label count.rating.releasegroup count.rating.recording count.rating.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.rating.artist') + 
                   $self->fetch('count.rating.label') +
                   $self->fetch('count.rating.releasegroup') +
                   $self->fetch('count.rating.work') +
                   $self->fetch('count.rating.recording');
        },
    },
    "count.rating.raw" => {
        DESC => "Count of all raw ratings",
        PREREQ => [qw[ count.rating.raw.artist count.rating.raw.label count.rating.raw.releasegroup count.rating.raw.recording count.rating.raw.work ]],
        CALC => sub {
            my ($self, $sql) = @_;
            return $self->fetch('count.rating.raw.artist') + 
                   $self->fetch('count.rating.raw.label') +
                   $self->fetch('count.rating.raw.releasegroup') +
                   $self->fetch('count.rating.raw.work') +
                   $self->fetch('count.rating.raw.recording');
        },
    },

    "count.release.Ndiscids" => {
        DESC => "Distribution of disc IDs per release (varying disc IDs)",
        PREREQ => [qw[ count.release count.release.has_discid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT medium, COUNT(*) AS c
                    FROM medium_cdtoc
                    GROUP BY medium
                ) AS t
                GROUP BY c
                ",
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch("count.release")
                - $self->fetch("count.release.has_discid");

            +{
                map {
                    "count.release.".$_."discids" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.quality.release.high" => {
        DESC => "Count of high quality releases",
        CALC => sub {
            my ($self, $sql) = @_;

            my $data = $sql->select_list_of_lists(
                "SELECT quality, COUNT(*) FROM release GROUP BY quality",
            );

            my %dist = map { @$_ } @$data;
            +{
                "count.quality.release.high"        => $dist{$QUALITY_HIGH} || 0,
                "count.quality.release.low"     => $dist{$QUALITY_LOW}      || 0,
                "count.quality.release.normal"  => $dist{$QUALITY_NORMAL}   || 0,
                "count.quality.release.unknown" => $dist{$QUALITY_UNKNOWN}  || 0,
            };
        },
    },
    "count.quality.release.low" => {
        DESC => "Count of low quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    "count.quality.release.normal" => {
        DESC => "Count of normal quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },
    "count.quality.release.unknown" => {
        DESC => "Count of unknow quality releases",
        PREREQ => [qw[ count.quality.release.high ]],
        PREREQ_ONLY => 1,
    },

    "count.puid.Nrecordings" => {
        DESC => "Distribution of recordings per PUID (collisions)",
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT puid, COUNT(*) AS c
                    FROM recording_puid
                    GROUP BY puid
                ) AS t
                GROUP BY c
                ",
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }
            
            +{
                map {
                    "count.puid.".$_."recordings" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.recording.Npuids" => {
        DESC => "Distribution of PUIDs per recording (varying PUIDs)",
        PREREQ => [qw[ count.recording count.recording.has_puid ]],
        CALC => sub {
            my ($self, $sql) = @_;

            my $max_dist_tail = 10;

            my $data = $sql->select_list_of_lists(
                "SELECT c, COUNT(*) AS freq
                FROM (
                    SELECT recording, COUNT(*) AS c
                    FROM recording_puid
                    GROUP BY recording
                ) AS t
                GROUP BY c
                ",
            );

            my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

            for (@$data)
            {
                $dist{ $_->[0] } = $_->[1], next
                    if $_->[0] < $max_dist_tail;

                $dist{$max_dist_tail} += $_->[1];
            }

            $dist{0} = $self->fetch("count.recording")
                - $self->fetch("count.recording.has_puid");
            
            +{
                map {
                    "count.recording.".$_."puids" => $dist{$_}
                } keys %dist
            };
        },
    },

    "count.ar.links" => {
        DESC => "Count of all advanced relationships links",
        CALC => sub {
            my ($self, $sql) = @_;
            my %r;
            $r{'count.ar.links'} = 0;

            for my $t ($self->c->model('Relationship')->all_pairs) {
                my $table = join('_', 'l', @$t);
                my $n = $sql->select_single_value(
                    "SELECT count(*) FROM $table");
                $r{"count.ar.links.$table"} = $n;
                $r{'count.ar.links'} += $n;
            }

            return \%r;
        },
    },

    (
        map {
            my ($l0, $l1) = @$_;
            "count.ar.links.l_${l0}_${l1}" => {
                DESC => "Count of $l0-$l1 advanced relationship links",
                PREREQ => [qw( count.ar.links )],
                PREREQ_ONLY => 1
            }
        } MusicBrainz::Server::Data::Relationship->all_pairs
    )
);

sub recalculate {
    my ($self, $statistic) = @_;

    my $definition = $stats{$statistic}
        or warn("Unknown statistic '$statistic'"), return;

    return if $definition->{PREREQ_ONLY};

    my $db = $definition->{DB} || 'READWRITE';
    my $sql = $db eq 'READWRITE' ? $self->sql
            : $db eq 'RAWDATA'   ? $self->c->raw_sql
            : die "Unknown database: $db";

    if (my $query = $definition->{SQL}) {
        my $value = $sql->select_single_value($query);
		$self->insert($statistic => $value);
        return;
    }

    if (my $calculate = $definition->{CALC}) {
        my $output = $calculate->($self, $sql);
        if (ref($output) eq "HASH")
        {
            $self->insert(%$output);
        } else {
            $self->insert($statistic => $output);
        }
    }
}

sub recalculate_all
{
    my $self = shift;

    my %notdone = %stats;
    my %done;

    while (1) {
        last unless %notdone;

        my $count = 0;

        # Work out which stats from %notdone we can do this time around
        for my $name (sort keys %notdone) {
            my $d = $stats{$name}{PREREQ} || [];
            next if grep { $notdone{$_} } @$d;

            # $name has no unsatisfied dependencies.  Let's do it!
            $self->recalculate($name);

            $done{$name} = delete $notdone{$name};
            ++$count;
        }

        next if $count;

        my $s = join ", ", keys %notdone;
        die "Failed to solve stats dependencies: circular dependency? ($s)";
    }
}

sub get_latest_statistics {

    my $self = shift;
    my $query = "SELECT id,
                        date_collected,
                        name,
                        value
                   FROM statistic
                  WHERE date_collected = (SELECT MAX(date_collected) FROM statistic)";

    $self->sql->select($query) or return;

    my $stats = MusicBrainz::Server::Entity::Statistics->new();
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        $stats->date_collected($row->{date_collected})
            unless $stats->date_collected;
        $stats->data->{$row->{name}} = $row->{value};
    }
    $self->sql->finish;

    return $stats;
}

1;
