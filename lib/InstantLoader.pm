package InstantLoader;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use File::Spec;
use File::Temp qw/tempdir/;
use File::Path qw/remove_tree/;
use App::cpanminus;
use POSIX qw/WUNTRACED/;

use constant VERBOSE => $ENV{VERBOSE_INSTANT_LOAD};

my $TMPINC;
BEGIN { $TMPINC = tempdir(CLEANUP => 1) }
END   { remove_tree $TMPINC if defined $TMPINC }

use lib "$TMPINC/lib/perl5";

sub import {
    my ($class, @packages) = @_;
    my $caller = caller;

    my $self = $class->_new($caller);
    $self->_install(@packages);
    $self->_load(@packages);
}

sub _new {
    my ($class, $target) = @_;
    return bless { target => $target } => $class;
}

sub _filter_not_installed {
    my @not_installed_modules;
    for my $module (@_) {
        my $path = File::Spec->catfile(split /(?:\'|::)/, $module . '.pm');
        next if exists $INC{$path}; ## loaded

        my $found;
        for my $dir (@INC) {
            next unless -d $dir;

            my $fullpath = File::Spec->catfile($dir, $path);
            if (-f $fullpath) {
                $found = 1;
                last;
            }
        }
        push @not_installed_modules => $module unless $found;
    }
    return @not_installed_modules;
}

sub _install {
    my $self = shift;
    my @packages = _filter_not_installed(@_);
    return $self unless @packages;

    my $pid = fork;
    die $! unless defined $pid;
    if ($pid == 0) {
        local $ENV{PERL5LIB} = join ':', @INC;
        warn "INSTALL: [@packages] to $TMPINC" if VERBOSE;
        open STDOUT, '>', File::Spec->devnull() or die $!;
        exec 'cpanm', '-n', '-q', -L => $TMPINC, @packages;
    }
    waitpid $pid, WUNTRACED;

    return $self;
}

sub _load {
    my ($self, @packages) = @_;

    my $code = join ';', map { "use $_" } @packages;
    my $success = eval sprintf q{
        package %s;
        %s;
        1;
    }, $self->{target}, $code;
    die $@ if $@;
    return $success;
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

