#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
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

use strict;
use warnings;

package MusicBrainz::Server::ModBot;

# Originally this was part of "Moderation.pm", but I feel it's large and
# complex enough to move into a file of its own.

# Go through the Moderation table and evaluate open Moderations

sub CheckModerations
{
   my ($this) = @_;
   my ($sql, $query, $rowid, @row, $status, $dep_status, $mod); 
   my (%mods, $now, $key);

   if (&DBDefs::DB_READ_ONLY)
   {
	   print "ModBot bailing out because DB_READ_ONLY is set\n";
	   return;
   }

   require Moderation;
   my $basemod = Moderation->new($this->{DBH});

   $sql = Sql->new($this->{DBH});
   $query = qq|select id from Moderation where status = | . 
               &ModDefs::STATUS_OPEN . qq| or status = | .
               &ModDefs::STATUS_TOBEDELETED . qq| order by Moderation.id|;
   return if (!$sql->Select($query));

   $now = time();
   while(@row = $sql->NextRow())
   {
       $mod = $basemod->CreateFromId($row[0]);
       if (!defined $mod)
       {
           print STDERR "Cannot create moderation $row[0]. This " .
                        "moderation will remain open.\n";
           next;
       }

       # Save the loaded modules for later
       $mod->{__eval__} = $mod->GetStatus();
       $mods{$row[0]} = $mod;

       print STDERR "\nEvaluate Mod: " . $mod->GetId() . "\n";

       # See if this mod has been marked for deletion
       if ($mod->GetStatus() == &ModDefs::STATUS_TOBEDELETED)
       {
           # Change the status to deleted. 
           print STDERR "EvalChange: $mod->{id} to be deleted\n";
           $mod->{__eval__} = &ModDefs::STATUS_DELETED;
           next;
       }

       # See if a KeyValue mod is pending for this.
       if ($this->CheckModificationForFailedDependencies($mod, \%mods) == 0)
       {
           print STDERR "EvalChange: kv dep failed\n";
           # If the prereq. change failed, close this modification
           $mod->{__eval__} = &ModDefs::STATUS_FAILEDPREREQ;
           next;
       }

       # Check to see if this change has another change that it depends on
       if (defined $mod->GetDepMod() && $mod->GetDepMod() > 0)
       {
           my $depmod;

           # Get the status of the dependent change. Since all open mods
           # have been loaded (or in this case, all preceding mods have
           # already been loaded) check to see if the dep mod around.
           # If not, its been closed. If so, check its status directly.
           $depmod = $mods{$mod->GetDepMod()};
           if (defined $depmod)
           {
              print STDERR "DepMod status: " . $depmod->{__eval__} . "\n";
              # We have the dependant change in memory
              if ($depmod->{__eval__} == &ModDefs::STATUS_OPEN ||
                  $depmod->{__eval__} == &ModDefs::STATUS_EVALNOCHANGE)
              {
                  print STDERR "EvalChange: Memory dep still open\n";

                  # If the prereq. change is still open, skip this change 
                  $mod->{__eval__} = &ModDefs::STATUS_EVALNOCHANGE;
                  next;
              }
              elsif ($depmod->{__eval__} != &ModDefs::STATUS_APPLIED)
              {
                  print STDERR "EvalChange: Memory dep failed\n";
                  $mod->{__eval__} = &ModDefs::STATUS_FAILEDPREREQ;
                  next;
              }
           }
           else
           {
              # If we can't find it, we need to load the status by hand.
              $dep_status = $this->GetModerationStatus($mod->GetDepMod());
              if ($dep_status != &ModDefs::STATUS_APPLIED)
              {
                  print STDERR "EvalChange: Disk dep failed\n";
                  # The depedent moderation had failed. Fail this one.
                  $mod->{__eval__} = &ModDefs::STATUS_FAILEDPREREQ;
                  next;
              }
           }
       }

       # Has the vote period expired and there have been votes?
       if ($mod->GetExpired() &&
          ($mod->GetYesVotes() > 0 || $mod->GetNoVotes() > 0))
       {
           # Are there more yes votes than no votes?
           if ($mod->GetYesVotes() <= $mod->GetNoVotes())
           {
               #print STDERR "EvalChange: expire and voted down\n";
               $mod->{__eval__} = &ModDefs::STATUS_FAILEDVOTE;
               next;
           }
           print STDERR "EvalChange: expire and approved\n";
           $mod->{__eval__} = &ModDefs::STATUS_APPLIED;
           next;
       }

       # Are the number of required unanimous votes present?
       if ($mod->GetYesVotes() >= &DBDefs::NUM_UNANIMOUS_VOTES && 
           $mod->GetNoVotes() == 0)
       {
           print STDERR "EvalChange: unanimous yes\n";
           # A unanimous yes. 
           $mod->{__eval__} = &ModDefs::STATUS_APPLIED;
           next;
       }

       if ($mod->GetNoVotes() >= &DBDefs::NUM_UNANIMOUS_VOTES && 
           $mod->GetYesVotes() == 0)
       {
           print STDERR "EvalChange: unanimous no\n";
           # A unanimous no.
           $mod->{__eval__} = &ModDefs::STATUS_FAILEDVOTE;
           next;
       }
       print STDERR "EvalChange: no change\n";

       # No condition for this moderation triggered. Leave it alone
       $mod->{__eval__} = &ModDefs::STATUS_EVALNOCHANGE;
   }
   $sql->Finish;

   foreach $key (reverse sort { $a <=> $b} keys %mods)
   {
       print STDERR "Check mod: $key\n";
       $mod = $mods{$key};
       next if ($mod->{__eval__} == &ModDefs::STATUS_EVALNOCHANGE);

       if ($mod->{__eval__} == &ModDefs::STATUS_APPLIED)
       {
           print STDERR "Mod " . $mod->GetId() . " applied\n";
           eval
           {
               my $status;

               $sql->Begin;

               $status = $mod->ApprovedAction;
               $mod->SetStatus($status);
               $mod->CreditModerator($mod->GetModerator(), 1, 0);
               $mod->CloseModeration($status);

               $sql->Commit;
           };
           if ($@)
           {
               my $err = $@;
               $sql->Rollback;

               print STDERR "CheckModsError: Moderation commit failed -- mod " . 
                            $mod->GetId . " will remain open.\n($err)\n";
           }
       }
       elsif ($mod->{__eval__} == &ModDefs::STATUS_DELETED)
       {
           print STDERR "Mod " . $mod->GetId() . " deleted\n";
           eval
           {
               $sql->Begin;

               $mod->SetStatus(&ModDefs::STATUS_DELETED);
               $mod->DeniedAction;
               $mod->CloseModeration($mod->{__eval__});

               $sql->Commit;
           };
           if ($@)
           {
               my $err = $@;
               $sql->Rollback;

               print STDERR "CheckModsError: Moderation commit failed -- mod " . 
                            $mod->GetId . " will remain open.\n($err)\n";
           }
       }
       else
       {
           print STDERR "Mod " . $mod->GetId() . " denied\n";
           eval
           {
               $sql->Begin;

               $mod->DeniedAction;
               $mod->CreditModerator($mod->GetModerator, 0, 1);
               $mod->CloseModeration($mod->{__eval__});

               $sql->Commit;
           };
           if ($@)
           {
               my $err = $@;
               $sql->Rollback;

               print STDERR "CheckModsError: Moderation commit failed -- mod " . 
                            $mod->GetId . " will remain open.\n($err)\n";
           }
       }
   }
}

# Check a given moderation for any dependecies that may have not been met
sub CheckModificationForFailedDependencies
{
   my ($this, $mod, $modhash) = @_;
   my ($sql, $status, $i, $depmod); 

   $sql = Sql->new($this->{DBH});
   for($i = 0;; $i++)
   {
       # FIXME this regex looks too slack for my liking
       if ($mod->GetNew() =~ m/Dep$i=(.*)/m)
       {
           #print STDERR "Mod: " . $mod->GetId() . " depmod: $1\n";
           $depmod = $modhash->{$1};
           if (defined $depmod)
           {
              $status = $depmod->{__eval__};
           }
           else
           {
              ($status) = $sql->GetSingleRow("Moderation", ["status"], ["id", $1]);
           }
           if (!defined $status || 
               $status == &ModDefs::STATUS_FAILEDVOTE ||
               $status == &ModDefs::STATUS_FAILEDDEP ||
               $status == &ModDefs::STATUS_DELETED)
           {
              return 0;
           }
       }
       else
       {
           last;
       }
   }
    
   return 1;
}

sub GetModerationStatus
{
 	my ($this, $id) = @_;
	my $sql = Sql->new($this->{DBH});

	my $status = $sql->SelectSingleValue(
		"SELECT status FROM moderation WHERE id = ?",
		$id,
	);

	defined($status) ? $status : &ModDefs::STATUS_ERROR;
}

1;
# eof ModBot.pm
