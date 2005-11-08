%# vi: set ts=2 sw=2 ft=mason :
<%args>
$seq
$year => ''
$month => ''
$day => ''
$country => ''
$has_error => 0
</%args>
<%perl>
$country = UserPreference::get('default_country') if $country eq '';
my $countries_menu = $m->comp("/edit/albumreleases/countries-menu.inc");
my $countries_menu_2 = [ [ "", "[select a country]" ], @$countries_menu ];
</%perl>

% if ( $has_error ) {
	<td><span style="color: red">*</span></td>
% } else {
	<td></td>
% }
	<td>
		<input type="text" name="y-<% $seq %>" size="4" maxlength="4"
			style="text-align: center" value="<% $year %>">
	</td>
	<td>
		<input type="text" name="m-<% $seq %>" size="2" maxlength="2"
			style="text-align: center" value="<% $month %>">
	</td>
	<td>
		<input type="text" name="d-<% $seq %>" size="2" maxlength="2"
			style="text-align: center" value="<% $day %>">
	</td>
	<td>
		<select name="country-<% $seq %>">
			<& /comp/options, $countries_menu_2, $country &>
		</select>
	</td>
