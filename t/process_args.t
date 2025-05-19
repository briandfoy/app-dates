use v5.36;

use Test::More;

my $class = 'App::dates';
my $method = 'process_args';

subtest 'sanity' => sub {
	use_ok $class;
	can_ok $class, $method;
	} or BAIL_OUT "Could not compile $class";


my $today_dt = DateTime->now( time_zone => 'local' );
my $today_ymd = $today_dt->ymd('-');

my $max_date  = $today_dt->clone->subtract( days => $class->max_days )->ymd('-');
diag( "max date is $max_date" );

my @good_table = (
	[  'both dates' => [ '2025-01-01', '2025-04-20' ], [ '2025-01-01', '2025-04-20' ] ],
	[  '. arg'      => [ '.',          '2025-04-20' ], [ $today_ymd,   '2025-04-20' ] ],
	[  '. arg only' => [ '.',                       ], [ $today_ymd,    $max_date   ] ],
	[  'no args'    => [                            ], [ $today_ymd,    $max_date   ] ],

	[  '-, date'       => [ '-3',  '2025-02-03' ], [ $today_dt->clone->add(      days =>  3 )->ymd('-'), '2025-02-03' ] ],
	[  '+, date'       => [ '+11', '2025-11-29' ], [ $today_dt->clone->subtract( days => 11 )->ymd('-'), '2025-11-29' ] ],
	[  'no sign, date' => [ '13',  '2025-12-26' ], [ $today_dt->clone->subtract( days => 13 )->ymd('-'), '2025-12-26' ] ],

	[  'date, -'       => [ '2025-02-03',  '-5' ], [ '2025-02-03', '2025-02-08' ] ],
	[  'date, +'       => [ '2025-11-29',  '+7' ], [ '2025-11-29', '2025-11-22' ] ],
	[  'date, no sign' => [ '2025-12-26',   '7' ], [ '2025-12-26', '2025-12-19' ] ],

	);

subtest 'good args' => sub {
	foreach my $row ( @good_table ) {
		my( $label, $args, $expected ) = $row->@*;

		subtest $label => sub {
			my( $start, $end ) = $class->$method( $args->@* );

			is_deeply [ $start, $end ], $expected;
			};
		}
	};

done_testing();
