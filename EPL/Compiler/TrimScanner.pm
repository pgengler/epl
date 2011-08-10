package EPL::Compiler::TrimScanner;

use strict;

use EPL::Compiler::PercentLine;

use parent 'EPL::Compiler::Scanner';

sub new()
{
	my $class = shift;
	my ($src, $trim_mode, $percent) = @_;

	my $self = $class->SUPER::new($src, $trim_mode, $percent);
	bless $self, $class;

	$self->{'_trim_mode'} = $trim_mode;
	$self->{'_percent'}   = $percent;

	if ($trim_mode eq '>') {
		$self->{'_scan_line'} = sub { $self->trim_line1 };
	} elsif ($trim_mode eq '<>') {
		$self->{'_scan_line'} = sub { $self->trim_line2 };
	} elsif ($trim_mode eq '-') {
		$self->{'_scan_line'} = sub { $self->explicit_trim_line };
	} else {
		$self->{'_scan_line'} = sub { $self->scan_line };
	}

	return $self;
}

sub scan()
{
	my $self = shift;
	my ($block) = @_;

	undef $self->{'_stag'};

	if ($self->{'_percent'}) {
		foreach my $line (@{ $self->{'_src'} }) {
			$self->percent_line($line, $block);
		}
	} else {
		$self->{'_scan_line'}->($self->{'_src'}, $block);
	}

	return undef;
}
      
sub percent_line()
{
	my $self = shift;
	my ($line, $block) = @_;

	if ($self->{'_stag'} || $line->[0] ne '%') {
		return $self->{'_scan_line'}->($line, $block);
	}

	$line->[0] = '';
	if ($line->[0] eq '%') {
		$self->{'_scan_line'}->($line, $block);
	} else {
		my $localLine = $line;
		chomp $localLine;
		$block->(new EPL::Compiler::PercentLine($localLine));
	}
}

sub scan_line($$)
{
	my $self = shift;
	my ($line, $block) = @_;

	while ($line =~ /(.*?)(<%%|%%>|<%=|<%#|<%|%>|\n|\z)/sg) {
		my @tokens = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

		foreach my $token (@tokens) {
			next if !defined $token || length($token) == 0;

			$block->($token);
		}
	}
}

sub trim_line1($$)
{
	my $self = shift;
	my ($line, $block) = @_;

	while ($line =~ /(.*?)(<%%|%%>|<%=|<%#|<%|%>\n|%>|\n|\z)/sg) {
		my @tokens = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

		foreach my $token (@tokens) {
			next if length($token) == 0;

			if ($token eq "\%>\n") {
				$block->('%>');
				$block->("\r");
			} else {
				$block->($token);
			}
		}
	}
}

sub trim_line2($$)
{
	my $self = shift;
	my ($line, $block) = @_;
	my $head;

	while ($line =~ /(.*?)(<%%|%%>|<%=|<%#|<%|%>\n|%>|\n|\z)/sg) {
		my @tokens = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

		foreach my $token (@tokens) {
			next if length($token) == 0;
			$head = $token unless $head;

			if ($token eq "\%>\n") {
				$block->('%>');
				if (is_epl_stag($head)) {
					$block->("\r");
				} else {
					$block->("\n");
				}
				undef $head;
			} else {
				$block->($token);
				undef $head if $token eq "\n";
			}
		}
	}
}


sub explicit_line_trim()
{
	my $self = shift;
	my ($line, $block) = @_;

	while ($line =~ /(.*?)(^[ \t]*<%\-|<%\-|<%%|%%>|<%=|<%#|<%|-%>\n|-%>|%>|\z)/sg) {
		my @tokens = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

		foreach my $token (@tokens) {
			next if length($token) == 0;

			if (!defined $self->{'_stag'} || $token =~ /[ \t]*<%-/) {
				$block->('<%');
			} elsif ($self->{'_stag'} && $token eq "-\%>\n") {
				$block->('%>');
				$block->("\r");
			} elsif ($self->{'_stag'} && $token eq '-%>') {
				$block->('%>');
			} else {
				$block->($token);
			}
		}
	}
}

my @_EPL_STAG = qw/ <%= <%# <% /;

sub is_epl_stag($)
{
	my ($s) = @_;
	foreach my $stag (@_EPL_STAG) {
		return 1 if $stag eq $s;
	}
	return 0;
}

1;
