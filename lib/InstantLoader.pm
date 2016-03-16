package InstantLoader;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use File::Spec;
use File::Temp qw/tempdir/;
use File::Path qw/remove_tree/;

my $TMPINC;
BEGIN { $TMPINC = tempdir(CLEANUP => 1) }
END   { remove_tree $TMPINC if defined $TMPINC }

use lib "$TMPINC/lib/perl5";

sub import {
    my ($class, @packages) = @_;
    my $caller = caller;

    my $pid = fork;
    if ($pid == 0) {
        open STDOUT, '>', File::Spec->devnull() or die $!;
        exec 'cpanm', '-n', '-q', '--skip-satisfied', -L => $TMPINC, @packages;
    }
    wait;

    my $code = join ';', map { "use $_" } @packages;
    eval sprintf q{
        package %s;
        %s;
        1;
    }, $caller, $code;
}

1;
__END__

=encoding utf-8

=head1 NAME

InstantLoader - It's new $module

=head1 SYNOPSIS

    use InstantLoader qw/List::UtilsBy/; # install and load List::UtilsBy at runtime
    import List::UtilsBy qw/nsort_by/;

    my ($foo, $bar, $baz) = map { $_->[1] } nsort_by { $_->[0] } ([1, 'bar'], [0, 'foo'], [2, 'baz']);

=head1 DESCRIPTION

InstantLoader is ...

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

