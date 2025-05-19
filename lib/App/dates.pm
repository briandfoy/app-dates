package App::dates;
use v5.36;

=head1 NAME

App::dates - list the dates between two endpoints

=head1 SYNOPSIS

Everything between two explicit dates:

	% dates 2025-05-17 2025-05-01

Everything between a date and an offset:

	% dates 2025-05-17 5
	% dates 2025-05-17 +5
	% dates 2025-05-17 -7

Use C<.> to mean today:

	% dates . 2025-05-10
	% dates . +8
	% dates . 5

As a module:

	use App::dates;

	my $dates =

=head1 DESCRIPTION

=cut

use DateTime;

__PACKAGE__->run(@ARGV) unless caller;

=over 4

=item * iso2dt( YYYY-MM-DD )

Turn a ISO-8601 address (YYYY-MM-DD) into a L<DateTime> object.

=cut

sub iso2dt ( $date ) {
	DateTime->new(
		map { $_->@* } List::Util::zip [qw(year month day)], [split /-/, $date]
		)
	}

=item * list_dates( START_DATE [,END_DATE|OFFSET] )

Return an array reference of dates between C<START_DATE> and C<END_DATE>.
Start date is either an ISO-8601 date (YYYY-MM-DD) or a literal dot,
C<.>, to represent the current date.

The second argument is either an ISO-8601 date, or an offset that is an
integer. A postive number (with a possible C<+> as in C<+5>) indicates
dates in the future and a negative integer indicates dates in the past.

=cut

sub list_dates ( $class, $start, $end ) {
	state $rc = require List::Util;
	my $dt = iso2dt($start);

	my $future = $end gt $start;
	my $method = $future ? 'add' : 'subtract';

	my @dates;
	NEXT_DATE: while(1) {
		push @dates, $dt->ymd('-');
		last if $dt->ymd('-') eq $end;

		DATE: {
			$dt->$method( days => 1 )->ymd('-');
			redo DATE if $class->not_a_date( $dt->ymd('-') );
			};
		}

	return \@dates;
	}

=item * max_days()

The maximum number of days to return in any situation. This number is
used when there is no end date or offset, or when the end date is very
far away. This keeps the program from running away to list every date
ever.

=cut

sub max_days ($class) { 10 }

=item * not_a_date( YYYY-MM-DD )

Returns true if the date that DateTime returns is not actually a date
in the Gregorian calendar. So far, that's 1582-10-05 to 1582-10-14.

=cut

sub not_a_date ( $class, $date ) {
	state $bogus = {
		map { $_ => 1 } qw(
			1582-10-05
			1582-10-06
			1582-10-07
			1582-10-08
			1582-10-09
			1582-10-10
			1582-10-11
			1582-10-12
			1582-10-13
			1582-10-14
			)
		};

	return exists $bogus->{$date};
	}

=item * process_args(ARGS)

Convert the arguments to the start and end dates to list.

=cut

sub process_args ( $class, @args ) {
	my $MaxDays = max_days();

	my $start = do {
		no warnings qw(uninitialized);
		$args[0] = undef if $args[0] eq '.';

		if( ! defined $args[0] or $args[0] eq '.') {
			say STDERR "In dot";
			my $t = DateTime->now->ymd('-');
			say $t;
			$t;
			}
		elsif( $args[0] =~ m/\A (\d+) - (\d\d) - (\d\d) \z/ax ) {
			Datetime->new(
				year  => $1,
				month => $2,
				day   => $3,
				)->ymd('-');
			}
		elsif ( $args[0] =~ m/\A ([+-]?)(\d+) \z/ax ){
			my $sign = $1 eq '-' ? -1 : 1;
			say STDERR "sign is $sign";
			my $offset = $2;
			my $max  = $sign * ($offset > $MaxDays ? $MaxDays : $offset);
			my $method = $sign < 0 ? 'add' : 'subtract';
			say STDERR "method is $method";
			DateTime->now->$method( days => $max )->ymd('-');
			}
		else {
			die "Bad start date. Must be one of YYYY-MM-DD, . (today), of +-N (offset)";
			}
		};

	my $end = do {
		$args[1] = $MaxDays unless defined $args[1];

		if( $args[1] =~ m/\A (\d+) - (\d\d) - (\d\d) \z/ax ) {
			Datetime->new(
				year  => $1,
				month => $2,
				day   => $3,
				)->ymd('-');
			}
		elsif ( $args[1] =~ m/\A (\d+) \z/ax ){
			my $max = $1 > $MaxDays ? $MaxDays : $1;
			iso2dt($start)->subtract( days => $max - 1 )->ymd('-');
			}
		else {
			die "Bad end date. Must be one of YYYY-MM-DD or N (offset)";
			}
		};
	say "START: $start END: $end";

	($start, $end);
	}

=item * run( ARGS )

=cut

sub run ( $class, @args ) {
	say join "\n", $class->list_dates(
		$class->process_args(@args)
		)->@*;
	}

=back

=cut

__PACKAGE__

