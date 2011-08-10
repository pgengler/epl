package EPL::Compiler::Scanner;

use strict;

our $_scanner_map = { };
our $_default_scanner;

sub regist_scanner($$$)
{
	my ($class, $trim_mode, $percent) = @_;
	$trim_mode ||= '';
	$percent   ||= '';

	$_scanner_map->{ $trim_mode, $percent } = $class;
}


sub default_scanner($)
{
	my ($class) = @_;

	$_default_scanner = $class;
}

sub make_scanner($$$)
{
	my ($src, $trim_mode, $percent) = @_;
	$trim_mode ||= '';
	$percent   ||= '';

	my $class = $_scanner_map->{ $trim_mode, $percent } || $_default_scanner;

	my $file = sprintf('EPL/Compiler/%s.pm', $class);
	$class = sprintf('EPL::Compiler::%s', $class);

	require $file;

	return new $class($src, $trim_mode, $percent);
}

sub new()
{
	my $class = shift;
	my ($src, $trim_mode, $percent) = @_;

	my $self = {
		'_src'  => $src,
		'_stag' => undef,
	};

	return bless $self, $class;
}

sub stag()
{
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_stag'} = shift;
	}

	return $self->{'_stag'};
}

sub scan();


1;
