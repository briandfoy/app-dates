use v5.36;

use Test::More;

my $class = 'App::dates';
my $method = 'list_dates';

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, $method;
	} or BAIL_OUT "Could not compile $class";

subtest 'list_dates' => sub {
	subtest 'descending' => sub {
		my $expected = [qw(
			2025-05-17
			2025-05-16
			2025-05-15
			2025-05-14
			2025-05-13
			)];
		my $dates = $class->$method( '2025-05-17', '2025-05-13' );
		is_deeply $dates, $expected
		};

	subtest 'ascending' => sub {
		my $expected = [qw(
			2017-03-01
			2017-03-02
			2017-03-03
			2017-03-04
			2017-03-05
			)];
		my $dates = $class->$method( '2017-03-01', '2017-03-05' );
		is_deeply $dates, $expected
		};

	subtest 'leap year' => sub {
		my $expected = [qw(
			2016-03-01
			2016-02-29
			2016-02-28
			2016-02-27
			)];
		my $dates = $class->$method( '2016-03-01', '2016-02-27' );
		is_deeply $dates, $expected
		};

	subtest 'gregorian' => sub {
		my $expected = [qw(
			1582-10-03
			1582-10-04
			1582-10-15
			1582-10-16
			)];
		my $dates = $class->$method( '1582-10-03', '1582-10-16' );
		is_deeply $dates, $expected
		};
	};

done_testing();
