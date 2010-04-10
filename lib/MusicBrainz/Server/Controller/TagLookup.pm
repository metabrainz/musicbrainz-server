package MusicBrainz::Server::Controller::TagLookup;

use strict;
use warnings;
use base 'MusicBrainz::Server::Controller';
use MusicBrainz::Server::Form::TagLookup;

sub _quote_for_lucene
{
    my $phrase = shift;

    $phrase =~ s/"/\\"/g;

    return '"'.$phrase.'"';
}

sub _parse_filename
{
   my ($filename) = @_;
   my (@parts);

   my $data = {};

   return $data unless $filename;

   if ($filename =~ s/^(\d+)\.//)
   {
       $data->{tracknum} = $1;
   }

   for(;;)
   {
       if ($filename =~ s/^([^-]*)-//)
       {
            $_ = $1;
            s/^\s*(.*?)\s*$/$1/;

            push @parts, $_ if (defined $_ and $_ ne '');
        }
        else
        {
            $_ = $filename;
            s/^(.*?)\..*$/$1/;
            s/^\s*(.*?)\s*$/$1/;
            push @parts, $_;
            last;
        }
   }
   if (scalar(@parts) == 4)
   {
        $data->{artist} ||= $parts[0];
        $data->{album} ||= $parts[1];
        if ($parts[2] =~ /^\d+$/)
        {
            $data->{tracknum} ||= $parts[2];
        }
        $data->{track} ||= $parts[3];
   }
   elsif (scalar(@parts) == 3)
   {
        $data->{artist} ||= $parts[0];
        if ($parts[1] =~ /^\d+$/)
        {
            $data->{tracknum} ||= $parts[1];
        }
        else
        {
            $data->{album} ||= $parts[1];
        }
        $data->{track} ||= $parts[2];
   }
   elsif (scalar(@parts) == 2)
   {
        $data->{artist} ||= $parts[0];
        $data->{track} ||= $parts[1];
   }
   elsif (scalar(@parts) == 1)
   {
        $data->{track} ||= $parts[0];
   }

   return $data;
}

sub puid : Private
{
    my ($self, $c) = @_;

    my $puid = $c->stash->{form}->field('puid')->value();
    my @releases = $c->model('Release')->find_by_puid($puid);

    $c->model('ArtistCredit')->load(@releases);
    $c->model('Medium')->load_for_releases(@releases);
    $c->model('Script')->load(@releases);
    $c->model('Language')->load(@releases);

    my @results = map { { entity => $_ } } @releases;

    $c->stash->{results} = \@results;
}

sub external : Private
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    my @terms;
    my $parsed = _parse_filename($form->field('filename')->value());
    my $mapping = { artist => 'artist', track => 'track', release => 'release',
                    dur => 'duration', tnum => 'tracknum' };

    while (my ($term, $field) = each %$mapping)
    {
        if ($form->field($field)->value())
        {
            push @terms, "$term: "._quote_for_lucene($form->field($field)->value());
        }
        elsif ($parsed->{$field})
        {
            push @terms, "$term: "._quote_for_lucene($parsed->{$field})
        }
    }

    my $type = "release";
    my $query = join (" ", @terms);
    my $limit = 25;
    my $page   = $c->request->query_params->{page} || 1;
    my $adv = 1;

    my $ret = $c->model('Search')->external_search($c, $type, $query, $limit, $page, $adv);
    if (exists $ret->{error})
    {
        if ($ret->{code} == 400 || $ret->{code} == 404)
        {
            $c->stash->{results} = [];
            return;
        }

        $c->detach ('/error_500');
    }

    $c->stash->{pager}    = $ret->{pager};
    $c->stash->{offset}   = $ret->{offset};
    $c->stash->{results}  = $ret->{results};
}


sub index : Path('')
{
    my ($self, $c) = @_;

    my $form = $c->form( query_form => 'TagLookup' );
    $c->stash->{form} = $form;

    return unless $form->submitted_and_valid( $c->req->query_params );

    $c->stash->{template} = 'taglookup/results-release.tt';

    $c->detach('puid') if ($form->field('puid')->value());
    $c->detach('external');
}

1;

=head1 LICENSE

Copyright (C) 2010 MetaBrainz Foundation

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
