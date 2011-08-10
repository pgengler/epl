package EPL::Compiler::Buffer;

use strict;

sub new()
{
	my $class = shift;
	my ($compiler) = @_;

	my $self = {
		'_compiler' => $compiler,
		'_line'     => [ ],
		'_script'   => '',
	};

	bless $self, $class;

	foreach my $x (@{ $self->{'_compiler'}->pre_cmd }) {
		$self->push($x);
	}

	return $self;
}

sub push()
{
	my $self = shift;
	my ($token) = @_;

	push @{ $self->{'_line'} }, $token;
}

sub script()
{
	my $self = shift;

	return $self->{'_script'};
}

sub cr()
{
	my $self = shift;

	$self->{'_script'} .= join('; ', @{ $self->{'_line'} });
	$self->{'_line'}    = [ ];
	$self->{'_script'} .= "\n";
}

sub close()
{
	my $self = shift;

	return unless $self->{'_line'};

	foreach my $x (@{ $self->{'_compiler'}->post_cmd }) {
		$self->push($x);
	}
	$self->{'_script'} .= join('; ', @{ $self->{'_line'} });
	undef $self->{'_line'};
}

1;
