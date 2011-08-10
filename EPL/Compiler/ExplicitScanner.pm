package EPL::Compiler::ExplicitScanner;

use strict;

use StringScanner;

use base 'EPL::Compiler::Scanner';

sub scan()
{
	my $self = shift;
	my ($block) = @_;

	my $stag_reg = qr/(.*?)(^[ \t]*<%-|<%%|<%=|<%#|<%-|<%|\z)/s;
	my $etag_reg = qr /(.*?)(%%>|-%>|%>|\z)/s;

	my $scanner = new StringScanner($self->{'_src'});

	while (!$scanner->eos()) {
		$scanner->scan($self->{'_stag'} ? $etag_reg : $stag_reg);

		$block->($scanner->[0]);

		my $elem = $scanner->[1];

		if ($elem =~ /[ \t]*<%-/) {
			$block->('<%');
		} elsif ($elem eq '-%>') {
			$block->('%>');
			$block->("\r") if $scanner->scan(qr/(\n|\z)/)
		} else {
			$block->($elem);
		}
	}
}

1;
