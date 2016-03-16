# NAME

InstantLoader - It's new $module

# SYNOPSIS

    use InstantLoader qw/List::UtilsBy/; # install and load List::UtilsBy at runtime
    import List::UtilsBy qw/nsort_by/;

    my ($foo, $bar, $baz) = map { $_->[1] } nsort_by { $_->[0] } ([1, 'bar'], [0, 'foo'], [2, 'baz']);

# DESCRIPTION

InstantLoader is ...

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura &lt;karupa@cpan.org>
