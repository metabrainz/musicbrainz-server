<%args>
$mod
$vote => undef
$inline=>0
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

for ("Yes=yes", "No=no", "Abst=abs", "No&nbsp;Vote=novote")
{
	my ($display, $key) = split /=/;
	next if $key eq "novote" and not $show_novote;

   if (!$inline)
   {
       my $checked = (($key eq $default) ? " checked" : "");
       $m->out(qq[<label for="rowid$modid-$key">$display</label>&nbsp;<input type="radio" name="rowid$modid" id="rowid$modid-$key" value="$key"$checked>&nbsp;]);
   }
   else
   {
       $m->out(qq[<input type="submit" name="rowid$modid" value="$key">&nbsp;]);
   }
}

</%perl>
