package Mojolicious::Command::generate::user;
use Mojo::Base 'Mojolicious::Command';

has description => 'Generate a new user for Moblo.';
has usage => 'APPLICATION generate user [USERNAME] [PASSWORD] [FULL NAME]';


sub run{
	my ( $self, $user, $password, $name ) = @_;

	die "Missing attributes" unless ($user && $password && $name);

	# Get the resultset
	my $users = $self->app->db->resultset('User');

	# Create the new record
	my $created = $users->create({
		username => $user,
		pw_hash => $self->app->bcrypt($password),
		fullname => $name,
	});

	say "Created user '$user' with id " . $created->id;
}

1;
