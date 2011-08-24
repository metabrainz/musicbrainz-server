package MusicBrainz::Server::ReportFactory;

use DBDefs;
use MusicBrainz::Server::PagedReport;

my @all = qw(
    DuplicateArtists
    ReleasesToConvert
    ArtistsThatMayBeGroups
    ArtistsThatMayBePersons
    BadAmazonURLs
    CollaborationRelationships
    EmptyReleaseGroups
    ISRCsWithManyRecordings
    MultipleASINs
    MultipleDiscogsLinks
    NoLanguage
    NoScript
    PartOfSetRelationships
    RecordingsWithEarliestReleaseRelationships
    SeparateDiscs
);

use MusicBrainz::Server::Report::DuplicateArtists;
use MusicBrainz::Server::Report::ReleasesToConvert;
use MusicBrainz::Server::Report::ArtistsThatMayBeGroups;
use MusicBrainz::Server::Report::ArtistsThatMayBePersons;
use MusicBrainz::Server::Report::BadAmazonURLs;
use MusicBrainz::Server::Report::CollaborationRelationships;
use MusicBrainz::Server::Report::EmptyReleaseGroups;
use MusicBrainz::Server::Report::ISRCsWithManyRecordings;
use MusicBrainz::Server::Report::MultipleASINs;
use MusicBrainz::Server::Report::MultipleDiscogsLinks;
use MusicBrainz::Server::Report::NoLanguage;
use MusicBrainz::Server::Report::NoScript;
use MusicBrainz::Server::Report::PartOfSetRelationships;
use MusicBrainz::Server::Report::RecordingsWithEarliestReleaseRelationships;
use MusicBrainz::Server::Report::SeparateDiscs;

my %all = map { $_ => 1 } @all;

sub all_report_names
{
    return @all;
}

sub create_report
{
    my ($class, $name, $c) = @_;

    return undef
        unless $all{$name};

    my $report_class = "MusicBrainz::Server::Report::$name";
    return $report_class->new( c => $c );
}

sub load_report_data
{
    my ($class, $name) = @_;

    my $data = &DBDefs::MB_SERVER_ROOT . "/data/reports/$name/$name";
    return MusicBrainz::Server::PagedReport->Load($data);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
