package Pkg::Dry;

require Exporter;
@ISA = 'Exporter';
@EXPORT_OK = 'readpipe';

sub readpipe {
    print @_, "\n";
}
