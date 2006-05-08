<%perl>
	# -----------------------------------------------------------------------------
	#                               Musicbrainz.org
	#                        Copyright (c) 2001 Robert Kaye
	# -----------------------------------------------------------------------------
	#  This software is provided "as is", without warranty of any kind, express or
	#  implied, including  but not limited  to the warranties of  merchantability,
	#  fitness for a particular purpose and noninfringement. In no event shall the
	#  authors or  copyright  holders be  liable for any claim,  damages or  other
	#  liability, whether  in an  action of  contract, tort  or otherwise, arising
	#  from,  out of  or in  connection with  the software or  the  use  or  other
	#  dealings in the software.
	#
	#  GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
	#  Permits anyone the right to use and modify the software without limitations
	#  as long as proper  credits are given  and the original  and modified source
	#  code are included. Requires  that the final product, software derivate from
	#  the original  source or any  software  utilizing a GPL  component, such  as
	#  this, is also licensed under the GPL license.
	# -----------------------------------------------------------------------------
	#
	# Summary:
	# -----------------------------------------------------------------------------
	# This include renders the voting buttons.
	#
	# $URL$
	# $Id$
	#
</%perl>
<%args>
	$mod
	$vote => undef
	$inline => 0
	$labelnextline => 1
</%args>
<%perl>

	my $show_novote = (!$inline and UserPreference::get("vote_show_novote"));
	my $default = (UserPreference::get("vote_abs_default") ? "abs" : "novote");

	if (defined $vote)
	{
		# Allow $vote to specify the default vote, either as a word
		# ("yes") or a constant (VOTE_YES).
		my %v = (
			yes	=> &ModDefs::VOTE_YES,
			no	=> &ModDefs::VOTE_NO,
			'abs'	=> &ModDefs::VOTE_ABS,
		);

		%v = (%v, reverse %v);

		$default = $v{$vote} if defined $v{$vote};
	}

	my $modid = $mod->GetId;

	if (!$inline)
	{
		my $n = ($show_novote ? 4 : 3);
		$m->out(qq!<table class="votechoice votechoice$n"><tr>!);
	}

	for ("Yes=yes", "No=no", "Abs=abs", "No&nbsp;Vote=novote")
	{
		my ($display, $key) = split /=/;
		next if ($key eq "novote" and not $show_novote);

		if (!$inline)
		{
			my $checked = (($key eq $default) ? 'checked="checked"' : "");

			$m->out(qq!<td>!);
			$m->out(qq!<label for="rowid$modid-$key">!);
			$m->out(qq!<input type="radio" name="rowid$modid" id="rowid$modid-$key" value="$key" $checked ondblclick="this.form.submit()" />!);

			# add a <br/> if the label should be on the next line, else nothing.
			$m->out(qq!<br />!) if ($labelnextline);

			$m->out(qq!$display</label></td>!);
		}
		else
		{
			$m->out(qq!<input type="submit" name="rowid$modid" value="$key" />&nbsp;!);
		}
	}

	if (!$inline)
	{
		$m->out(qq!</tr></table>!);
	}

</%perl>
