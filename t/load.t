my @classes = qw(
	App::dates
	);

use Test::More;

foreach my $class ( @classes ) {
	BAIL_OUT( "$class did not compile\n" ) unless use_ok( $class );
	}

done_testing();
