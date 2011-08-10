package StringScanner;

use strict;

use overload '@{}' => 'to_a';

sub new()
{
	my $class = shift;
	my ($string) = @_;

	my $self = {
		'_eos'     => 0,
		'_matches' => [ ],
		'_string'  => $string,
	};

	return bless $self, $class;
}

sub eos()
{
	my $self = shift;

	return $self->{'_eos'};
}

sub scan()
{
	my $self = shift;
	my ($pattern) = @_;

	if (length($self->{'_string'}) > 0 && $self->{'_string'} =~ $pattern) {
		$self->{'_matches'} = [ $1, $2, $3, $4, $5, $6, $7, $8, $9 ];
		# Remove everything up to and including the matching part of the string
		$self->{'_string'}  = substr($self->{'_string'}, $+[0]);

		return 1;
	} else {
		$self->{'_eos'} = 1;

		return 0;
	}
}

sub to_a()
{
	my $self = shift;

	return $self->{'_matches'};
}

1;
