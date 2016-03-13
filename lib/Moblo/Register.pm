package Moblo::Register;
use Mojo::Base 'Mojolicious::Controller';

sub on_user_register{
	my $self = shift;
	my $username = $self->param('username');
	my $fullname = $self->param('fullname');
	my $password = $self->param('password');

	$self->db->resultset('User')->create({
		pw_hash  => $self->bcrypt($password), #$password,
		username => $username,
		fullname => $fullname,

});

	$self->flash( user_saved => 1);
	$self->redirect_to('/');
}

1;	