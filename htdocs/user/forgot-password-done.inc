%# vi: set ts=4 sw=2 ft=mason :
% 	my $user = shift;

<& /comp/sidebar-notitle, pagetitle => "Password Sent" &>

<& /comp/tablebegin, title => "Password Sent" &>
	Password sent to the e-mail address registered for this account.
<& /comp/tableend &>

<& /comp/tablebegin, title => "Login" &>
	<& /comp/loginbox &>
<& /comp/tableend &>

<& /comp/footer &>
