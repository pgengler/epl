package EPL::Compiler;

use strict;
use feature ':5.10';

use EPL::Compiler::Buffer;
use EPL::Compiler::Scanner;

sub content_dump($)
{
	my ($string) = @_;

	my $n = 0;
	while ($string =~ /\n/g) {
		$n++;
	}

	if ($n > 0) {
		dump_str($string) . ("\n" x $n);
	} else {
		dump_str($string);
	}
}

sub dump_str($)
{
	my ($string) = @_;

	$string =~ s/"/\\"/g;
	$string =~ s/\\/\\\\/g;
	$string =~ s/\f/\\f/g;
	$string =~ s/\n/\\n/g;
	$string =~ s/\r/\\r/g;
	$string =~ s/\t/\\t/g;
	$string =~ s/(\P{Print})/sprintf('\x%02X', $1)/e;

	$string = '"'.$string.'"';

	return $string;
}

sub compile()
{
	my $self = shift;
	my ($string) = @_;

	my $out = new EPL::Compiler::Buffer($self);

	my $content = '';
	my $scanner = $self->make_scanner($string);

	$scanner->scan(sub { my $token = shift;
		return if not defined $token;
		return if $token eq '';

		if (not defined $scanner->stag) {
			given ($token) {

				when (UNIVERSAL::isa($_, 'EPL::Compiler::PercentLine')) {
					$out->push(sprintf('%s %s', $self->{'_put_cmd'}, content_dump($content))) if length($content) > 0;
					$content = '';
					$out->push($token);
					$out->cr;
				}

				when ("\r") {
					$out->cr;
				}

				when ([ '<%', '<%=', '<%#' ]) {
					$scanner->stag($token);
					$out->push(sprintf('%s %s', $self->{'_put_cmd'}, content_dump($content))) if length($content) > 0;
					$content = '';
				}

				when ("\n") {
					$content .= "\n";
					$out->push(sprintf('%s %s', $self->{'_put_cmd'}, content_dump($content)));
					$content = '';
				}

				when ('<%%') {
					$content .= '<%';
				}

				default {
					$content .= $token;
				}
			}
		} else {
			if ($token eq '%>') {
				given ($scanner->stag) {

					when ('<%') {
						if (substr($content, -1) eq "\n") {
							chop $content;
							$out->push($content);
							$out->cr;
						} else {
							$out->push($content);
						}
					}

					when ('<%=') {
						$out->push(sprintf('%s(%s)', $self->{'_insert_cmd'}, $content));
					}

					when ('<%#') {
#						$out->push(sprintf('# %s', content_dump($content)));
					}
				}
				$scanner->stag(undef);
				$content = '';
			} elsif ($token eq '%%>') {
				$content .= '%>';
			} else {
				$content .= $token;
			}
		}
	});

	$out->push(sprintf('%s %s', $self->{'_put_cmd'}, content_dump($content))) if length($content) > 0;
	$out->close;
	$out->script;
}

sub prepare_trim_mode($)
{
	my ($mode) = @_;
	$mode ||= '';

	if ($mode eq '1') {
		return [ 0, '>' ];
	} elsif ($mode eq '2') {
		return [ 0, '<>' ];
	} elsif ($mode eq '0') {
		return [ 0, undef ];
	} elsif ($mode =~ /./) {
		my $perc = $mode =~ /%/;
		if ($mode =~ /-/) {
			return [ $perc, '-' ];
		} elsif ($mode =~ /<>/) {
			return [ $perc, '<>' ];
		} elsif ($mode =~ />/) {
			return [ $perc, '>' ];
		} else {
			return [ $perc, undef ];
		}
	} else {
		return [ 0, undef ];
	}
}

sub make_scanner()
{
	my $self = shift;
	my ($src) = @_;

	return EPL::Compiler::Scanner::make_scanner($src, $self->{'_trim_mode'}, $self->{'_percent'});
}

sub new()
{
	my $class = shift;
	my ($trim_mode) = @_;

	my $percent;
	($percent, $trim_mode) = @{ prepare_trim_mode($trim_mode) };

	my $self = {
		'_insert_cmd' => 'print',
		'_percent'    => $percent,
		'_pre_cmd'    => [ ],
		'_post_cmd'   => [ ],
		'_put_cmd'    => 'print',
		'_trim_mode'  => $trim_mode,
	};

	return bless $self, $class;
}

sub percent()
{
	my $self = shift;

	return $self->{'_percent'};
}

sub trim_mode()
{
	my $self = shift;

	return $self->{'_trim_mode'};
}

sub put_cmd()
{
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_put_cmd'} = shift;
	}

	return $self->{'_put_cmd'};
}

sub insert_cmd()
{
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_insert_cmd'} = shift;
	}

	return $self->{'_insert_cmd'};
}

sub pre_cmd()
{
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_pre_cmd'} = shift;
	}

	return $self->{'_pre_cmd'};
}

sub post_cmd()
{
	my $self = shift;

	if (scalar(@_) > 0) {
		$self->{'_post_cmd'} = shift;
	}

	return $self->{'_post_cmd'};
}

1;
