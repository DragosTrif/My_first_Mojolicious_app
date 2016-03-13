use strict;
use warnings;

use MyDatabase 'db_handle';

my $dbh = db_handle('moblo.db');
my $posts =<<"SQL";

CREATE TABLE IF NOT EXISTS posts(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	author TEXT,
	title  TEXT,
	content TEXT,
	date_published VARCHAR(30)
	

);
SQL
$dbh->do($posts);


