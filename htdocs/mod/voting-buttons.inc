<%args>
$mod
</%args>
<%perl>

my $show_novote = UserPreference::get("vote_show_novote");
my $default = (UserPreference::get("vote_abs_default") ? "abs" : "novote");
my $modid = $mod->GetId;

for ("Yes=yes", "No=no", "Abst=abs", "No&nbsp;Vote=novote")
{
	my ($display, $key) = split /=/;
	next if $key eq "novote" and not $show_novote;
	my $checked = (($key eq $default) ? " checked" : "");
	$m->out(qq[<label for="rowid$modid-$key">$display</label>&nbsp;<input type="radio" name="rowid$modid" id="rowid$modid-$key" value="$key"$checked>&nbsp;]);
}

</%perl>
