package Moblo::Post;
use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use Data::Dumper;
use diagnostics;

sub create{
	my $self = shift;
	my $title = $self->param('title');
	my $content = $self->param('content');
	my $user = $self->_user_from_session;

	$self->db->resultset('Post')->create({
		title => $title,
		content => $content,
		author => $self->session('username'),

		#aici e cred ca e buba !!!. In tutorial era sintaxa: author_id => $user->id 
		#care crapa
		author_id => $user->id,
		date_published => DateTime->now->iso8601,
	});

	my $a = $self->session('username') ;
	my $b = $self->session('id');#$self->_user_from_session;
	warn "|author|";

	warn "the user is:|$a|";
	warn "the user id is|$b|";
	#warn $self->session('id');
	 $self->flash(post_saved => 1);
	 $self->redirect_to('restricted_area');
	 warn "|$content|";
}

sub delete{
	my $self = shift;
	my $posts = $self->db->resultset('Post');
	$self->app->log->info($self->stash('id'));
	$posts->search({ id => $self->stash('id') })->delete;
	$self->flash(post_deleted => '1');
	$self->redirect_to('restricted_area');
}

sub delete_comment{
	my $self = shift;
	my $comment = $self->db->resultset('Comment');
	$self->app->log->info($self->stash('id'));
	$comment->search({ id => $self->stash('id')})->delete;
	$self->flash(comment_deleted => '1');
	$self->redirect_to('restricted_area');
}

sub show{
	my $self = shift;
	my $post = $self->_post_from_stash;
	my $user = $self->_user_from_session;
	warn "|$post|";

	if(defined $post){
		$self->render(post => $post, logged_in => defined($user), user => $user);
	} else {
		$self->render_not_found;

	}
}

	#warn $self->session('id');
sub comment{
	my $self = shift;

	# Retrieve dbic objects
	my $post = $self->_post_from_stash;
	my $user = $self->_user_from_session;
	

	$post->create_related('comments',{
		user_id => $user->id,
		content => $self->param('content'),
		created_at => DateTime->now,
		post_id => $post->id,
		
		
	});

	my $test_comment =  $post->id;
	warn "the post id is :|$test_comment|";

	$self->app->log->info($self->stash('id'));
	#$post->search({ id => $self->stash('id') });
	$self->redirect_to('restricted_area');

}

sub edit_post{
	my $self = shift;
	my $post = $self->_post_from_stash;
	my $title = $self->param('title');
	my $content = $self->param('content');
	
	warn "The edited title is |$title|\n";
	warn "The edited content is |$content|\n";

	#my $content = $self->param('content');
	 $post->update({
		title => $title,
		content => $content,
	});

	 $self->flash(post_edited => 1);
	 $self->redirect_to('restricted_area');
}

sub edit_comment{
	my $self = shift;
	my $comment = $self->db->resultset('Comment')->find($self->stash('id'));
	my $comment_param = $self->param('content');

	$comment->update({
		content => $comment_param,
	});
	$self->flash(comment_edited => 1);
	$self->redirect_to('restricted_area');
}

# This should be a helper.
sub _user_from_session{
	my $self = shift;

	if( $self->session('logged_in'))
	{
		my $user_id = $self->db->resultset('User')->find($self->session('user_id')); 
		return $user_id;
		

		warn "the value of __user_from_session|$user_id|";
	}	
	
}

sub _post_from_stash{
	my $self = shift;
	return $self->db->resultset('Post')->find($self->stash('id'));
}

1;
