package EPL::Util;

use strict;

use parent 'Exporter';

our @EXPORT = qw/ h html_escape u url_encode /;

sub html_escape($)
{
	my ($string) = @_;

	$string =~ s/&/&amp;/g;
	$string =~ s/"/&quot;/g;
	$string =~ s/>/&gt;/g;
	$string =~ s/</&lt;/g;

	return $string;
}
sub h($)
{
	return html_escape(shift);
}

sub url_encode($)
{
	my ($string) = @_;

	$string =~ s/[^a-zA-Z0-9_\-.]/sprintf("%%%02X", $&.unpack("C")[0])/e;

	return $string;
}

sub u($)
{
	return url_encode(shift);
}


1;

