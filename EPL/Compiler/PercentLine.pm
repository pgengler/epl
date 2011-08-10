package EPL::Compiler::PercentLine;

use strict;

sub new()
{
	my $class = shift;
	my ($value) = @_;

	my $self = {
		'_value' => $value,
	};

	return bless $self, $class;
}

sub value()
{
	my $self = shift;

	return $self->{'_value'};
}

sub isEmpty()
{
	my $self = shift;

	return not defined $self->{'_value'};
}

1;
