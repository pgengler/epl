package EPL::Compiler::SimpleScanner2;

use strict;

use StringScanner;

use parent 'EPL::Compiler::Scanner';

sub scan()
{
	my $self = shift;
	my ($block) = @_;

	my $stag_reg = qr/(.*?)(<%%|<%=|<%#|<%|\z)/s;
	my $etag_reg = qr/(.*?)(%%>|%>|\z)/s;

	my $scanner = new StringScanner($self->{'_src'});

	while (!$scanner->eos()) {
		$scanner->scan($self->{'_stag'} ? $etag_reg : $stag_reg);
		my @matches = @$scanner;
		$block->($matches[0]);
		$block->($matches[1]);
	}
}

1;
