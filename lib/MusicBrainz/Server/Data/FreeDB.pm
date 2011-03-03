package MusicBrainz::Server::Data::FreeDB;
use Moose;

use constant FREEDB_SERVER1 => "freedb2.org";
use constant FREEDB_SERVER2 => "freedb.freedb.org";
use constant FREEDB_PROTOCOL => 6; # speaks UTF-8

use Carp 'confess';
use LWP::UserAgent;
use URI;

with 'MusicBrainz::Server::Data::Role::Context';

sub lookup {
    my ($self, $category, $id) = @_;

    return
        $self->_retrieve(FREEDB_SERVER1, "cddb read $category $id") ||
        $self->_retrieve(FREEDB_SERVER2, "cddb read $category $id");
}

sub _retrieve
{
    my ($self, $server, $query) = @_;

    my $cache_key = "FreeDB-$server-$query";
    my $cache = $self->c->cache('freedb');

    if (my $r = $cache->get($cache_key)) {
	    return $r;
    }
    else {
        my $r = $self->_retrieve_no_cache($server, $query);
        $cache->set($cache_key => $r);
        return $r;
    }
}

sub _retrieve_no_cache
{
    my ($self, $server, $query) = @_;

    confess "A server address/name must be given."
        if ($server eq '');

    my $url = URI->new("http://$server/~cddb/cddb.cgi");
    $url->query_form([
        cmd => $query,
        hello => 'webmaster musicbrainz.org musicbrainz.org 1.0',
        proto => FREEDB_PROTOCOL
    ]);

    my $ua = LWP::UserAgent->new(max_redirect => 0);
	$ua->env_proxy;
    my $response = $ua->get($url);

    return undef unless $response->is_success;

	my $page = $response->content;

	my @lines = split /\n/, $page;
    my $line = shift @lines;

    my @response = split ' ', $line;
    if ($response[0] == 202) {
        return undef;
    }
    if ($response[0] < 200 || $response[0] > 299) {
        return undef;
    }

    return $self->_parse_tracks(\@lines)
        if ($query =~ /^cddb.read/);

    #
    # Parse the query

    my ($category, $disc_id);
    if ($response[0] == 200)
    {
        $category = $response[1];
        $disc_id = $response[2];
    }
    #
    # Do we have more than one match?  Just use the first match.
    #
    elsif ($response[0] == 210 or $response[0] == 211)
    {
        my (@categories, @disc_ids);

        for (my $i = 1; ; $i++)
        {
            $line = $lines[$i-1];

            @response = split ' ', $line;
            last if $response[0] eq '.';

            $categories[$i] = $response[0];
            $disc_ids[$i] = $response[1];
        }

        $category = $categories[1];
        $disc_id = $disc_ids[1];
    }

    # FIXME lots of undef warnings coming from here
    $query = "cddb+read+$category+$disc_id";
	my $ref = $self->_retrieve_no_cache($server, $query);

	return $ref;
}

sub _parse_tracks
{
	my ($self, $lines) = @_;

    my $artist = "";
    my $title = "";

    my $in_offsets = 0;
    my $last_track_offset = 0;
    my %info;
    $info{durations} = '';

    # Used for debugging
    my $response = $info{_response} = [];
    my $offsets = $info{_offsets} = [];
    my $disc_length = \$info{_disc_length};
    my @track_titles;

    foreach my $line (@$lines)
    {
     	push @$response, $line;

    	my @chars = split(//, $line, 2);
        if ($chars[0] eq '#')
        {
            if ($line =~ /Track frame offsets/)
            {
                $in_offsets = 1;
                next;
            }
            if (!$in_offsets)
            {
                next;
            }
            # parse the track offsets and the total time 
            if ($line =~ /Disc length:/)
            {
                $line =~ s/^# Disc length:\s*(\d*).*$/$1/i;
	 			$$disc_length = $1;
                $info{durations} .= ($line * 1000) - int(($last_track_offset*1000) / 75);
                $in_offsets = 0;
                next;
            }
            $line =~ tr/0-9//cd;
            if ($line eq '')
            {
                next;
            }
		    push @$offsets, $line;
            if($last_track_offset > 0) 
            {
                $info{durations} .= int ((($line - $last_track_offset)*1000) / 75) . " ";
            }           
            $last_track_offset = $line;
            next;
        }

        my @response = split ' ', $line;
        if ($response[0] eq '.')
        {
            last;
        }

        #print $line;
        my @parts = split '=', $line;
        if ($parts[0] eq "DTITLE")
        {
	    my $temp;
            if ($artist eq "")
            {
                ($artist, $temp) = split ' \/ ', $parts[1], 2
		    or
                ($artist, $temp) = split '\/', $parts[1], 2;
            }
            else
            {
                $temp = $parts[1];
            }
            $temp = "" if not defined $temp;
            $temp =~ s/^[\n\r]*(.*?)[\r\n]*$/$1/;
            $title .= $temp;
            next;
        }

        my @subparts = split '([0-9]+)', $parts[0];
        if ($subparts[0] eq "TTITLE")
        {
            chomp $parts[1];
            chop $parts[1];
            $track_titles[$subparts[1]] .= $parts[1];
            $track_titles[$subparts[1]] =~ s/^\s*(.*?)\s*$/$1/;
            next;
        }
    }

    $artist =~ s/^\s*(.*?)\s*$/$1/ if defined $artist;
    $title =~ s/^\s*(.*?)\s*$/$1/ if defined $title;

    if (!defined $title || $title eq "")
    {
        $title = $artist;
    }

    $info{artist} = $info{sortname} = $artist;
    $info{album} = $title;

    $title = $self->normalize_disc_numbers($title);

    my @tracks;

    for (my $i = 0; $i < scalar(@track_titles); $i++)
    {
        my $t = $track_titles[$i];
        push @tracks, { track=>$t, tracknum => ($i+1) };
    }

    $info{tracks} = \@tracks;

    return \%info;
}

sub normalize_disc_numbers
{
    my ($self, $name) = @_;
    my ($new, $disc);

    # TODO use [0-9] instead of \d?
    # TODO undef warnings come from here
    no warnings;
    if ($name =~ /^(.*)(\(|\[)\s*(disk|disc|cd)\s*(\d+|one|two|three|four)(\)|\])$/i)
    {
        $new = $1;
        $disc = $4;
    }
    elsif ($name =~ /^(.*)(disk|disc|cd)\s*(\d+|one|two|three|four)$/i)
    {
        $new = $1;
        $disc = $3;
    }
    use warnings;

    if (defined $new && defined $disc)
    {
        $disc = 1 if ($disc =~ /one/i);
        $disc = 2 if ($disc =~ /two/i);
        $disc = 3 if ($disc =~ /three/i);
        $disc = 4 if ($disc =~ /four/i);
        if ($disc > 0 && $disc < 100)
        {
            $disc =~ s/^0+//g;
            $new =~ s/\s*[(\/|:,-]*\s*$//;
            $new .= " (disc $disc)";

            return $new;
        }
    }

    return $name;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Robert Kaye
Copyright (C) 2010 MetaBrainz Foundation

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
