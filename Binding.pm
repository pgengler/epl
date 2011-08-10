package Binding;

use strict;

use Devel::Caller qw/ caller_cv /;
use PadWalker qw/ peek_sub /;

sub new()
{
	my $class = shift;

	my $caller = caller_cv(1);
	my $vars   = peek_sub($caller);

	my $processedVars = _processVars($vars);

	my $self = {
		'_variables' => $processedVars,
	};

	return bless $self, $class;
}

sub _processVars($)
{
	my ($rawVars) = @_;

	my $processedVars = { };

	foreach my $varName (keys %$rawVars) {
		my $unprefixedVarName = $varName;
		$unprefixedVarName =~ s/^[\$\@\%]//;

		my $value = $rawVars->{ $varName };
		if (ref $value eq 'REF') {
			$value = $$value;
		}

		$processedVars->{ $unprefixedVarName } = $value;
	}

	return $processedVars;
}

sub variables()
{
	my $self = shift;

	return $self->{'_variables'};
}

1;
