#!/usr/local/bin/perl -w
use strict;

use lib 't';
use Test::More tests => 7;

use Acme::use::strict::with::pride;

ok(1); # If we made it this far, we're ok.

my $debug = tie *STDERR, 'TieOut';

is (eval "require Bad; 2", 2, "Should be able to use Bad");
is ($@, "", "without an error");

like ($debug->read,
  qr!^Use of uninitialized value in addition \(\+\) at t/Bad.pm line \d+\.$!,
      "Is the error properly mangled");

is (eval "use Naughty; 2", undef, "Should not be able to use Naughty");
like ($@, qr!Global symbol "\$what_am_i" requires explicit package name at t/Naughty.pm line \d+.!,
      "Is the error properly mangled");

is ($debug->read, '', "eval should have caught the error");

undef $debug;
untie *STDERR;

package TieOut;

sub TIEHANDLE {
    my $class = shift;
    bless(\( my $ref = ''), $class);
}

sub PRINT {
    my $self = shift;
    $$self .= join('', @_);
}

sub read {
    my $self = shift;
    return substr($$self, 0, length($$self), '');
}
