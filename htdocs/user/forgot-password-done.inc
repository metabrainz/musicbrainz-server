%# vi: set ts=4 sw=2 ft=mason :
% 	my $user = shift;

<& /comp/sidebar, noh1 => 1 &>

<& /comp/tablebegin, title => "Forgotten Password - Password Sent!" &>
	Password sent to the e-mail address registered for this account.
<& /comp/tableend &>

<& /comp/tablebegin, title => "Login", align => "center" &>
	<& /comp/loginbox &>
<& /comp/tableend &>

<& /comp/footer &>
