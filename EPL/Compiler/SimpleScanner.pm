package EPL::Compiler::SimpleScanner;

use strict;

use base 'EPL::Compiler::Scanner';

sub scan()
{
	my $self = shift;
	my ($block) = @_;

	while ($self->{'_src'} =~ /(.*?)(<%%|%%>|<%=|<%#|<%|%>|\n|\z)/sg) {
		my @tokens = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

		foreach my $token (@tokens) {
			next if length($token) == 0;
			$block->($token);
		}
	}
}    

1;
