use strict;
use warnings;

use Moblo::Schema;

my $schema = Moblo::Schema->connect('dbi:SQLite:moblo.db');
$schema->deploy();