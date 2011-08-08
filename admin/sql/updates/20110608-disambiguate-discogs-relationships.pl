#!/usr/bin/env perl
use strict;
use LWP::Simple qw();
use List::MoreUtils qw( uniq );
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;

my %MB_RELEASE_FORMAT_MAPPING = (
   'Digital Media'  => 'File',
   '7" Vinyl'       => 'Vinyl',
   '10" Vinyl'      => 'Vinyl',
   '12" Vinyl'      => 'Vinyl',
   'DVD-Video'      => 'DVD',
   'DVD-Audio'      => 'DVD',
   'HD-DVD'         => 'HD DVD',
   'LaserDisc'      => 'Laserdisc',
);

my %DISCOGS_RELEASE_FORMAT_MAPPING = (
   'CDr'            => 'CD',
   'DVDr'           => 'DVD',
   'Blu-ray-R'      => 'Blu-ray',
);

sub mangle_catno
{
    my $catno = lc $_[0] || '';
    $catno =~ s/\W//g; # remove non-alphanumeric characters
    $catno =~ s/(^|[^0-9])0+/$1/g; # remove leading zeros from numbers
    return $catno;
}

sub match_discogs_catno_barcode_country
{
    my ($discogs_info, $mb_releases) = @_;
	my @release_ids = keys %{ $mb_releases };

    # Try to match catalog numbers
    my @matches;
    if ($discogs_info->[1]) {
        my @discogs_catnos = uniq map { mangle_catno($_) } split /;/, $discogs_info->[1];
        my $discogs_country = $discogs_info->[3];
        foreach my $rid (keys %{ $mb_releases }) {
            my $mb_release = $mb_releases->{$rid};
            my @mb_catnos = uniq map { mangle_catno($_->{catalog_number}) } grep { $_ } @{$mb_release->labels};
            my $barcode = $mb_release->{barcode} || '';
            $barcode =~ s/^0+//; # remove leading zeros
            my $country = $mb_release->{country}->{name} || '';
            $country = "UK" if $country eq "United Kingdom";
            $country = "US" if $country eq "United States";
            next unless $country eq $discogs_country;
            next unless @mb_catnos || $barcode;
            foreach my $discogs_catno (@discogs_catnos) {
                my $found = 0;
                if ($barcode eq $discogs_catno || substr($barcode, 0, -1) eq $discogs_catno) {
                    push @matches, $rid;
                    last;
                }
                foreach my $mb_catno (@mb_catnos) {
                    if ($mb_catno eq $discogs_catno) {
                        push @matches, $rid;
                        $found = 1;
                        last;
                    }
                }
                last if $found;
            }
        }
    }
    return @matches;
}

sub match_discogs_catno_barcode
{
    my ($discogs_info, $mb_releases) = @_;
	my @release_ids = keys %{ $mb_releases };

    # Try to match catalog numbers
    my @matches;
    if ($discogs_info->[1]) {
        my @discogs_catnos = uniq grep { $_ } map { mangle_catno($_) } split /;/, $discogs_info->[1];
        foreach my $rid (keys %{ $mb_releases }) {
            my $mb_release = $mb_releases->{$rid};
            my @mb_catnos = uniq grep { $_ } map { mangle_catno($_->{catalog_number}) } @{$mb_release->labels};
            my $barcode = $mb_release->{barcode} || '';
            $barcode =~ s/^0+//; # remove leading zeros
            next unless @mb_catnos || $barcode;
            foreach my $discogs_catno (@discogs_catnos) {
                my $found = 0;
                if ($barcode eq $discogs_catno ||
                    substr($barcode, 0, -1) eq $discogs_catno) {
                    push @matches, $rid;
                    last;
                }
                foreach my $mb_catno (@mb_catnos) {
                    if ($mb_catno eq $discogs_catno) {
                        push @matches, $rid;
                        $found = 1;
                        last;
                    }
                }
                last if $found;
            }
        }
    }
    return @matches;
}

sub match_discogs_catno_format
{
    my ($discogs_info, $mb_releases) = @_;
	my @release_ids = keys %{ $mb_releases };

    # Try to match parts catalog numbers and medium format
    my @matches;
    if ($discogs_info->[1]) {
        my @discogs_catnos = uniq map { mangle_catno($_) } split /;/, $discogs_info->[1];
        my $discogs_format = map { $DISCOGS_RELEASE_FORMAT_MAPPING{$_} || $_ } split /;/, $discogs_info->[5];
        foreach my $rid (keys %{ $mb_releases }) {
            my $mb_release = $mb_releases->{$rid};
            my @mb_catnos = uniq map { mangle_catno($_->{catalog_number}) } grep { $_ } @{$mb_release->labels};
            my @formats = uniq map { $MB_RELEASE_FORMAT_MAPPING{$_->format_name} || $_->format_name } grep { $_->format_name } @{$mb_release->mediums};
            my $format =  join(';', @formats) || '';
            next unless @mb_catnos && $format;
            foreach my $discogs_catno (@discogs_catnos) {
                my $found = 0;
                foreach my $catno (@mb_catnos) {
                    if ($discogs_format eq $format &&
                        (index($catno, $discogs_catno) >= 0 ||
                        index($discogs_catno, $catno) >= 0)) {
                        push @matches, $rid;
                        last;
                    }
                }
                last if $found;
            }
        }
    }
    return @matches;
}

sub match_discogs_year_country_format
{
    my ($discogs_info, $mb_releases) = @_;
	my @release_ids = keys %{ $mb_releases };

    # Try countries and years
    my @matches;
    if ($discogs_info->[3] && $discogs_info->[4]) {
        my $discogs_year = substr($discogs_info->[4], 0, 4);
        my $discogs_country = $discogs_info->[3];
        my $discogs_format = map { $DISCOGS_RELEASE_FORMAT_MAPPING{$_} || $_ } split /;/, $discogs_info->[5];
        foreach my $rid (keys %{ $mb_releases }) {
            my $mb_release = $mb_releases->{$rid};
            my $year = $mb_release->{date}->{year} || '';
            my $country = $mb_release->{country}->{name} || '';
            $country = "UK" if $country eq "United Kingdom";
            $country = "US" if $country eq "United States";
            my @formats = uniq map { $MB_RELEASE_FORMAT_MAPPING{$_->format_name} || $_->format_name } grep { $_->format_name } @{$mb_release->mediums};
            my $format =  join(';', @formats) || '';
            if ($year && $country && $year eq $discogs_year &&
                $country eq $discogs_country &&
                ($format eq '' || $format eq $discogs_format)) {
                push @matches, $rid;
                last;
            }
        }
    }
    return @matches;
}

# Load Discogs URL data
my %discogs;
LWP::Simple::mirror("http://users.musicbrainz.org/murdos/ngs/discogs.dat", "discogs.dat");
open(DISCOGS, "<discogs.dat");
while (<DISCOGS>) {
    my $line = $_;
    $line =~ s/\s*$//;
    my @fields = split /\t/, $line;
    $discogs{$fields[0]} = \@fields;
}
close(DISCOGS);

my $c = MusicBrainz::Server::Context->create_script_context;

# Find Discogs release URLs linked to multiple MB releases
my @to_fix = @{
	$c->sql->select_list_of_hashes(
		"SELECT url.id AS url_id, regexp_replace(url.url, '.*/([0-9]+).*', E'\\\\1') AS discogs_id,
			array_agg(lru.entity0) as release_ids
		FROM l_release_url lru
			JOIN link ON (link.id = lru.link AND link.link_type = 76)
			JOIN url ON url.id = lru.entity1
			JOIN (SELECT tmplru.entity1 
				FROM l_release_url tmplru
					JOIN link tmplink ON (tmplink.id = tmplru.link AND tmplink.link_type = 76)
				GROUP BY entity1 HAVING COUNT(*) > 1
			) tmp ON tmp.entity1 = lru.entity1
		GROUP BY url_id, discogs_id
		ORDER BY url_id, discogs_id
	")
};

$c->sql->begin;

my $i = 0;
my $deleted = 0;

for my $row (@to_fix) {

    printf STDERR " %d/%d\r", $i++, scalar(@to_fix);

    my @wrong_links;

	# Try to disambiguate Discogs release URLs
	my $discogs_info = $discogs{$row->{discogs_id}};
	if (defined $discogs_info) {

		my %mb_releases = %{ $c->model('Release')->get_by_ids( @{ $row->{release_ids} } ) };
        $c->model('ReleaseLabel')->load(values %mb_releases);
        $c->model('Country')->load(values %mb_releases);

		my @matches;
		@matches = match_discogs_catno_barcode_country($discogs_info, \%mb_releases);
		unless (@matches) {
		    @matches = match_discogs_catno_barcode($discogs_info, \%mb_releases);
		    unless (@matches) {
                $c->model('Medium')->load_for_releases(values %mb_releases);
                $c->model('MediumFormat')->load(map { $_->all_mediums } values %mb_releases);
			    @matches = match_discogs_catno_format($discogs_info, \%mb_releases);
			    unless (@matches) {
				    @matches = match_discogs_year_country_format($discogs_info, \%mb_releases);
				    unless (@matches) {
					    @matches = @{ $row->{release_ids} };
				    }
			    }
		    }
        }

        my %matches = map { $_ => 1 } @matches;
        foreach my $release_id (@{ $row->{release_ids} }) {
            push @wrong_links, [ $release_id, $row->{url_id} ] unless $matches{$release_id};
        }

        $c->sql->do("
            DELETE FROM l_release_url 
            USING link
            WHERE link_type = 76 AND edits_pending = 0 AND l_release_url.link = link.id AND (" 
            . join(" OR ", ('(entity0, entity1) = (?,?)') x scalar(@wrong_links))  . ")",
            map { @$_ } @wrong_links
        ) if scalar(@wrong_links);

        $deleted += scalar(@wrong_links);
    
	}

}

printf "Number of relationships deleted: %d\n", $deleted;

$c->sql->commit;

if ($@) {
    printf STDERR "ERROR: %s\n", $@;
    $c->sql->rollback;
}

