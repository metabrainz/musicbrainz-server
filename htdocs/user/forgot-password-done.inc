%# vi: set ts=2 sw=2 ft=mason :
% my $user = shift;
<& /comp/sidebar, title => "Password Sent!" &>

<center>

	<p class="notice">
		Password sent to the e-mail address registered for this account.
	</p>

	<& /comp/tablebegin, title=>'Moderator Login' &>
	<& /comp/loginbox &>
	<& /comp/tableend &>

</center>

<& /comp/footer &>
