#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
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
                                                                               
package MusicBrainz;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use Apache::Registry;
use DBDefs;

sub new
{
    my $this = {};
    bless $this;
    return $this;
}  

sub Login
{
   my ($this, $quiet, $dsn) = @_;

   $dsn = DBDefs->DSN if (!defined $dsn);
   $this->{DBH} = DBI->connect($dsn,DBDefs->DB_USER,DBDefs->DB_PASSWD,
                               { RaiseError => 1, AutoCommit => 1 });
   return 0 if (!$this->{DBH});
   return 1;
}

sub Logout
{
   my ($this) = @_;

   $this->{DBH}->disconnect() if ($this->{DBH});
}

sub CheckArgs
{
   my ($this, $args);
   my ($i, $j, $err);

   $this = shift @_;
   for($i = 0; $i < scalar(@_); $i++)
   {
       if (!defined $args->{$_[$i]})
       {
           $err = "The page requires the following arguments: <b>";
           for($j = 0; $j < scalar(@_); $j++)
           {
               $err .= "$_[$j] ";
           }
           $err .= "</b>";
           PrintError($this, $err);
           Logout($this);
           Footer($this);
           exit(0);
       }
   }
}

1;
