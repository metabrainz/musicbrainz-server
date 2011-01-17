package MusicBrainz::Server::Controller::Statistics;
use Moose;
use Data::Dumper;
use MusicBrainz::Server::Data::Statistics;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub _percent : Private
{
    my ($stats, $numerator, $denominator) = @_;

    return "-" if (!$denominator);

    sprintf("%.1f%%", $stats->{data}->{$numerator} * 100 / $stats->{data}->{$denominator});
}

sub statistics : Path('')
{
    my ($self, $c) = @_;

# TODO: 
#       ALTER TABLE statistic ADD CONSTRAINT statistic_pkey PRIMARY KEY (id); fails
#       for duplicate key 1
#       count.quality.release.unknown is too high
#       count.editor.* is zero

    my $stats = $c->model('Statistics')->get_todays_statistics();
    $stats->{data}->{"count.release.various.p"} = 
                    _percent($stats, "count.release.various", "count.release");
    $stats->{data}->{"count.release.nonvarious.p"} = 
                    _percent($stats, "count.release.nonvarious", "count.release");
    $stats->{data}->{"count.release.has_discid.p"} = 
                    _percent($stats, "count.release.has_discid", "count.release");
    $stats->{data}->{"count.release.0discids.p"} = 
                    _percent($stats, "count.release.0discids", "count.release");
    $stats->{data}->{"count.release.1discids.p"} = 
                    _percent($stats, "count.release.1discids", "count.release.has_discid");
    $stats->{data}->{"count.release.2discids.p"} = 
                    _percent($stats, "count.release.2discids", "count.release.has_discid");
    $stats->{data}->{"count.release.3discids.p"} = 
                    _percent($stats, "count.release.3discids", "count.release.has_discid");
    $stats->{data}->{"count.release.4discids.p"} = 
                    _percent($stats, "count.release.4discids", "count.release.has_discid");
    $stats->{data}->{"count.release.5discids.p"} = 
                    _percent($stats, "count.release.5discids", "count.release.has_discid");
    $stats->{data}->{"count.release.6discids.p"} = 
                    _percent($stats, "count.release.6discids", "count.release.has_discid");
    $stats->{data}->{"count.release.7discids.p"} = 
                    _percent($stats, "count.release.7discids", "count.release.has_discid");
    $stats->{data}->{"count.release.8discids.p"} = 
                    _percent($stats, "count.release.8discids", "count.release.has_discid");
    $stats->{data}->{"count.release.9discids.p"} = 
                    _percent($stats, "count.release.9discids", "count.release.has_discid");
    $stats->{data}->{"count.release.10discids.p"} = 
                    _percent($stats, "count.release.10discids", "count.release.has_discid");

    $stats->{data}->{"count.recording.has_puid.p"} = 
                    _percent($stats, "count.recording.has_puid", "count.recording");
    $stats->{data}->{"count.recording.0puids.p"} = 
                    _percent($stats, "count.recording.0puids", "count.recording");
    $stats->{data}->{"count.recording.1puids.p"} = 
                    _percent($stats, "count.recording.1puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.2puids.p"} = 
                    _percent($stats, "count.recording.2puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.3puids.p"} = 
                    _percent($stats, "count.recording.3puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.4puids.p"} = 
                    _percent($stats, "count.recording.4puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.5puids.p"} = 
                    _percent($stats, "count.recording.5puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.6puids.p"} = 
                    _percent($stats, "count.recording.6puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.7puids.p"} = 
                    _percent($stats, "count.recording.7puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.8puids.p"} = 
                    _percent($stats, "count.recording.8puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.9puids.p"} = 
                    _percent($stats, "count.recording.9puids", "count.recording.has_puid");
    $stats->{data}->{"count.recording.10puids.p"} = 
                    _percent($stats, "count.recording.10puids", "count.recording.has_puid");

    $stats->{data}->{"count.puid.1recordings.p"} = 
                    _percent($stats, "count.puid.1recordings", "count.puid");
    $stats->{data}->{"count.puid.2recordings.p"} = 
                    _percent($stats, "count.puid.2recordings", "count.puid");
    $stats->{data}->{"count.puid.3recordings.p"} = 
                    _percent($stats, "count.puid.3recordings", "count.puid");
    $stats->{data}->{"count.puid.4recordings.p"} = 
                    _percent($stats, "count.puid.4recordings", "count.puid");
    $stats->{data}->{"count.puid.5recordings.p"} = 
                    _percent($stats, "count.puid.5recordings", "count.puid");
    $stats->{data}->{"count.puid.6recordings.p"} = 
                    _percent($stats, "count.puid.6recordings", "count.puid");
    $stats->{data}->{"count.puid.7recordings.p"} = 
                    _percent($stats, "count.puid.7recordings", "count.puid");
    $stats->{data}->{"count.puid.8recordings.p"} = 
                    _percent($stats, "count.puid.8recordings", "count.puid");
    $stats->{data}->{"count.puid.9recordings.p"} = 
                    _percent($stats, "count.puid.9recordings", "count.puid");
    $stats->{data}->{"count.puid.10recordings.p"} = 
                    _percent($stats, "count.puid.10recordings", "count.puid");

    $stats->{data}->{"count.quality.release.high.p"} = 
                    _percent($stats, "count.quality.release.high", "count.release");
    $stats->{data}->{"count.quality.release.normal.p"} = 
                    _percent($stats, "count.quality.release.normal", "count.release");
    $stats->{data}->{"count.quality.release.low.p"} = 
                    _percent($stats, "count.quality.release.low", "count.release");
    $stats->{data}->{"count.quality.release.unknown.p"} = 
                    _percent($stats, "count.quality.release.unknown", "count.release");

    $stats->{data}->{"count.editor.activelastweek.p"} = 
                    _percent($stats, "count.editor.activelastweek", "count.editor");
    $stats->{data}->{"count.editor.editlastweek.p"} = 
                    _percent($stats, "count.editor.editlastweek", "count.editor");
    $stats->{data}->{"count.editor.votelastweek.p"} = 
                    _percent($stats, "count.edit.votelastweek", "count.editor");

    $stats->{data}->{"count.edit.open.p"} = 
                    _percent($stats, "count.edit.open", "count.edit");
    $stats->{data}->{"count.edit.applied.p"} = 
                    _percent($stats, "count.edit.applied", "count.edit");
    $stats->{data}->{"count.edit.failedvote.p"} = 
                    _percent($stats, "count.edit.failedvote", "count.edit");
    $stats->{data}->{"count.edit.faileddep.p"} = 
                    _percent($stats, "count.edit.faileddep", "count.edit");
    $stats->{data}->{"count.edit.failedprereq.p"} = 
                    _percent($stats, "count.edit.failedprereq", "count.edit");
    $stats->{data}->{"count.edit.error.p"} = 
                    _percent($stats, "count.edit.error", "count.edit");
    $stats->{data}->{"count.edit.tobedeleted.p"} = 
                    _percent($stats, "count.edit.tobedeleted", "count.edit");
    $stats->{data}->{"count.edit.deleted.p"} = 
                    _percent($stats, "count.edit.deleted", "count.edit");

    $stats->{data}->{"count.vote.yes.p"} = 
                    _percent($stats, "count.vote.yes", "count.vote");
    $stats->{data}->{"count.vote.no.p"} = 
                    _percent($stats, "count.vote.no", "count.vote");
    $stats->{data}->{"count.vote.abstain.p"} = 
                    _percent($stats, "count.vote.abstain", "count.vote");

    print STDERR Dumper($stats);

    $c->stash( 
              template => 'statistics/index.tt',
              stats    => $stats
             );
}

=head1 LICENSE

Copyright (C) 2011 MetaBrainz Foundation Inc.

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
