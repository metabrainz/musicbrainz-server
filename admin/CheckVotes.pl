#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use lib "../cgi-bin";
use DBI;
use MusicBrainz;
use Moderation;
use Tie::STDERR \&handle_output;

my $email = shift;

sub handle_output
{
   my ($text) = @_;

   if ($text =~ /CheckModsError:/)
   {
       if (defined $email && $email ne '')
       {
           open MAIL, "|mail -s 'ModBot Error' $email"
              or die "Cannot open mail program\n";

           print MAIL "During moderation/vote eval an error occurred:\n$text\n";
           close MAIL;
           print "Sent mail to $email\n";
       }
       else
       {
           print "An error occurred:\n$text\n";
       }
   }
   else
   {
       print "No errors.\n$text\n";
   }
}

my $mb = MusicBrainz->new();

$mb->Login();
$mod = Moderation->new($mb->{DBH});
$mod->CheckModerations();
$mb->Logout();
