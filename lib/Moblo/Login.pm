package Moblo::Login;
use Mojo::Base 'Mojolicious::Controller';

use Mojolicious::Plugin::Bcrypt;

#use MoboloDB;

# Mocked function to check the correctness
# of a username/password combination.

sub user_exists {

	#my  $self = shift;
	#warn $usernmae;
    my ( $self, $username, $password) = @_;
    #warn |$username|;


    

    # Determine if a user with 'username' exists
    my $user = $self->app->db->resultset('User')->search({ username => $username })->first;
   # warn $user;   

    # Validate password against hash, if any user found
    return (
        defined $user &&
        $self->bcrypt_validate( $password, $user->pw_hash )
    );
}

sub on_user_login {
    my $self = shift;

    # Grab the request parameters
    my $username = $self->param('username');
    my $password = $self->param('password');
    #my $user_id = $self->app->db->resultset('User')->find({ id => 'id' });
    

    if (my $check = $self->user_exists( $username, $password)) {
        #my $schema = $self->app->db->resultset('User'); 
        
        my $user = $self->app->db->resultset('User')->find({ username => $username
            });
        my $id = $user->id;
        my $pass = $user->pw_hash;

        warn "the pass is |$pass|";
        warn "the new id is|$id |";
            
        #my $user_id = $logged_user->id;
        $self->session(logged_in => 1);
        $self->session(username => $username);
        $self->session(user_id => $user->id);

        
        
        
        

        $self->redirect_to('restricted_area');
    } else {
        $self->render(text => 'Wrong username/password', status => 403);
	}
}			    


	 sub is_logged_in{

	 	my $self = shift;

	 	return 1 if $self->session('logged_in');

	 	
	 	$self->render(
	 		inline => "<h2>Forbidden</h2><p>You're not logged in. < /p>",
	 		status => 403,
	 	);	

	 }


1;
