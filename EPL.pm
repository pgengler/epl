package EPL;

use strict;

use EPL::Compiler;
use EPL::Compiler::Scanner;

EPL::Compiler::Scanner::default_scanner('TrimScanner');
EPL::Compiler::Scanner::regist_scanner('SimpleScanner', undef, 0);
EPL::Compiler::Scanner::regist_scanner('SimpleScanner2', undef, 0);
EPL::Compiler::Scanner::regist_scanner('ExplicitScanner', '-', 0);

sub new()
{
	my $class = shift;
	my ($str, $trim_mode, $eoutvar) = @_;

	$eoutvar ||= '$_eplout';

	my $compiler = new EPL::Compiler($trim_mode);
	set_eoutvar($compiler, $eoutvar);

	my $self = {
		'_filename'   => undef,
		'_src'        => $compiler->compile($str),
	};

	return bless $self, $class;
}

sub src()
{
	my $self = shift;

	return $self->{'_src'};
}

sub filename()
{
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_filename'} = shift;
	}

	return $self->{'_filename'};
}


sub set_eoutvar($;$)
{
	my ($compiler, $eoutvar) = @_;
	$eoutvar ||= '$_eplout';

	$compiler->put_cmd("$eoutvar.=");
	$compiler->insert_cmd("$eoutvar.=");

	my $cmd = [ ];
	push @$cmd, "our $eoutvar = ''";

	$compiler->pre_cmd($cmd);

	$cmd = [ ];
	push @$cmd, $eoutvar;

	$compiler->post_cmd($cmd);
}

sub run()
{
	my $self = shift;
	my ($binding) = @_;

	print $self->result($binding);
}

sub result()
{
	my $self = shift;
	my ($binding) = @_;

	my $boundVars = $binding->variables();
	{
		no strict;
		foreach my $var (keys %$boundVars) {
			if (ref($boundVars->{ $var }) eq 'SCALAR') {
				$$var = ${ $boundVars->{ $var } };
			} else {
				$$var = $boundVars->{ $var };
			}
		}

		my $result = eval $self->{'_src'};
		if ($@) {
			die $@;
		}
		return $result;
	}
}

1;
