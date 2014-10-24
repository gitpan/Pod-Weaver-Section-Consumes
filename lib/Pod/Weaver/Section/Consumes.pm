package Pod::Weaver::Section::Consumes;
{
  $Pod::Weaver::Section::Consumes::VERSION = '0.007';
}

use strict;
use warnings;


# ABSTRACT: Add a list of roles to your POD.

use Moose;
use Module::Load;
with 'Pod::Weaver::Role::Section';

use aliased 'Pod::Elemental::Element::Nested';
use aliased 'Pod::Elemental::Element::Pod5::Command';

sub weave_section { 
    my ( $self, $doc, $input ) = @_;

    my $file = $input->{filename};
    return unless $file =~ m{^lib/};

    my $module = $file;
    $module =~ s{^lib/}{};    # assume modules live under lib
    $module =~ s{/}{::}g;
    $module =~ s/\.pm//;

    unshift @INC, './lib';    # assume we want modules from the CWD

    load $module;

    return unless $module->can( 'meta' );

    my @roles = grep { $_->name ne $module } $self->_get_roles( $module );
    return unless @roles;

    my @pod = (
        Command->new( { 
            command   => 'over',
            content   => 4
        } ),

        ( map { 
            Command->new( {
                command    => 'item',
                content    => sprintf '* L<%s>', $_->name
            } ),
        } @roles ),

        Command->new( { 
            command   => 'back',
            content   => ''
        } )
    );        

    push @{ $doc->children },
        Nested->new( { 
            type      => 'command',
            command   => 'head1',
            content   => 'CONSUMES',
            children  => \@pod
        } );

    shift @INC;

}

sub _get_roles { 
    my ( $self, $module ) = @_;

    my @roles = $module->meta->calculate_all_roles;

    return @roles;
}


1;



__END__
=pod

=head1 NAME

Pod::Weaver::Section::Consumes - Add a list of roles to your POD.

=head1 VERSION

version 0.007

=head1 SYNOPSIS

In your C<weaver.ini>:

    [Consumes]

=head1 DESCRIPTION

This L<Pod::Weaver> section plugin creates a "CONSUMES" section in your POD
which will contain a list of all the roles consumed by your class. It accomplishes
this by attempting to compile your class and interrogating its metaclass object.

Classes which do not have a C<meta> method will be skipped.

=head1 AUTHOR

Mike Friedman <friedo@friedo.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Mike Friedman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

