%# vi: set ts=2 sw=2 ft=mason :
% my $user = shift;
<& /comp/sidebar, title => "Password Sent!" &>

<center>

	<p class="notice">
		Password sent to the e-mail address registered for this account.
	</p>

	<div class="TitledBox" style="width: 20em">
		<div class="TitledBoxTitle">Login</div>
		<& /comp/loginbox &>
	</div>

</center>

<& /comp/footer &>
