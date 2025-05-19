use v5.36;

use v5.36;

use Test::More;

my $class = 'App::dates';
my $method = 'list_dates';

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, $method;
	} or BAIL_OUT "Could not compile $class";

done_testing();
