package Moblo;
use Mojo::Base 'Mojolicious';
use Moblo::Schema;
use Mojolicious::Plugin::Bcrypt;
use Data::Dumper;



# This method will run once at server start
sub startup {
  my $self = shift;

  my $schema = Moblo::Schema->connect('dbi:SQLite:moblo.db');
  #warn Dumper($schema);
  $self->helper(db => sub { return $schema; });
  $self->plugin('bcrypt');
  # Documentation browser under "/perldoc"
  #$self->plugin('PODRenderer');

  # Allows to set the signing key as an array,
  # where the first key will be used for all new sessions
  # and the other keys are still used for validation, but not for new sessions
  #$self->plugin('bcrypt');
  $self->secrets(['This secret is used for new sessionsLeYTmFPhw3q',
  				'This secret is used _only_ for validation QrPTZhWJmqCjyGZmguK']);
  
  # The cookie name
  $self->app->sessions->cookie_name('moblo');

  # Expiration reduced to 10 Minute
  $self->app->sessions->default_expiration('600');

  # Default layout
  $self->defaults(layout => 'base');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  #$r->get('/index')->to( template => 'main/index');
  $r->get('/')->to('Main#index');

  # Rute puse de mine
  # View posts (no login) 
  #$r->get('/', [id => qr/\d+/ ])->name('show_post')->to('Post#show');

  $r->get('/post/:id', [id => qr/\d+/])->name('show_post')->to('Post#show');
  $r->get('/register')->name('register_form')->to(template => 'register/register_form');
  $r->post('/register')->name('do_register')->to('Register#on_user_register');
  #$r->get('/login')->name('login_form')->to(template => 'login/login_form');
  $r->get('/login')->name('login_form')->to(template => 'login/login_form');
  #$r->post('/login')->name('do_login')->to('Login#on_user_login');
  $r->post('/login')->name('do_login')->to('Login#on_user_login');

  my $authorized = $r->under('/admin')->to('Login#is_logged_in');
  	 $authorized->get('/')->name('restricted_area')->to(template => 'admin/overview');
  	 
  	 $authorized->get('/create')->name('create_post')->to(template => 'admin/create_post');
  	 $authorized->post('/create')->name('publish_post')->to('Post#create');
  	  
  	 $authorized->get('/delete/:id', [id => qr/\d+/])->name('delete_post')->to(template => 'admin/delete_post_confirm');
  	  #on POST, we delete the post.
  	 $authorized->post('/delete/:id', [id => qr/\d+/])->name('delete_post_confirmed')->to('Post#delete'); 
  	 # Create comments
  	 $authorized->get('/post/:id/comments', [id => qr/\d+/])->name('create_comment')->to(template => 'post/create_comment');
  	 $authorized->post('/post/:id/comments', [id => qr/\d+/])->name('create_new_comment')->to('Post#comment');

     # route four updating a post 
     $authorized->get('/post/:id/edit', [id => qr/\d+/])->name('edit_post')->to(template =>'post/edit_post');
     $authorized->post('/post/:id/edit', [id => qr/\d+/])->name('edit_old_post')->to('Post#edit_post');
    
     # delete coments
     $authorized->get('comment/:id/delete', [id => qr/\d+/])->name('delete_comment')->to(template => 'admin/delete_comment_confirm'); 
     $authorized->post('comment/:id/delete', [id => qr/\d+/])->name('delete_comment_confirm')->to('Post#delete_comment');

     # route for updating a comment
     $authorized->get('comment/:id/edit', [id => qr/\d+/])->name('edit_comment')->to(template =>'post/edit_comment');
     $authorized->post('comment/:id/edit', [id => qr/\d+/])->name('edit_old_comment')->to('Post#edit_comment');

  	 $r->route('/logout')->name('do_logout')->to(cb => sub{
  	 	my $self = shift;

  	 	$self->session(expires => 1 );

  	 	$self->redirect_to('/');
  	 });
}

1;
