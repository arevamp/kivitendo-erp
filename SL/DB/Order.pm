package SL::DB::Order;

use utf8;
use strict;

use Carp;
use DateTime;
use List::Util qw(max);

use SL::DB::MetaSetup::Order;
use SL::DB::Manager::Order;
use SL::DB::Invoice;
use SL::DB::Helper::FlattenToForm;
use SL::DB::Helper::LinkedRecords;
use SL::DB::Helper::PriceTaxCalculator;
use SL::DB::Helper::PriceUpdater;
use SL::DB::Helper::TransNumberGenerator;
use SL::RecordLinks;

__PACKAGE__->meta->add_relationship(
  orderitems => {
    type         => 'one to many',
    class        => 'SL::DB::OrderItem',
    column_map   => { id => 'trans_id' },
    manager_args => {
      with_objects => [ 'part' ]
    }
  },
  periodic_invoices_config => {
    type                   => 'one to one',
    class                  => 'SL::DB::PeriodicInvoicesConfig',
    column_map             => { id => 'oe_id' },
  },
  periodic_invoices        => {
    type                   => 'one to many',
    class                  => 'SL::DB::PeriodicInvoice',
    column_map             => { id => 'oe_id' },
  },
  payment_term => {
    type       => 'one to one',
    class      => 'SL::DB::PaymentTerm',
    column_map => { payment_id => 'id' },
  },
  contact      => {
    type       => 'one to one',
    class      => 'SL::DB::Contact',
    column_map => { cp_id => 'cp_id' },
  },
  shipto       => {
    type       => 'one to one',
    class      => 'SL::DB::Shipto',
    column_map => { shipto_id => 'shipto_id' },
  },
  department   => {
    type       => 'one to one',
    class      => 'SL::DB::Department',
    column_map => { department_id => 'id' },
  },
  language     => {
    type       => 'one to one',
    class      => 'SL::DB::Language',
    column_map => { language_id => 'id' },
  },
);

__PACKAGE__->meta->initialize;

# methods

sub items { goto &orderitems; }

sub type {
  my $self = shift;

  return 'sales_order'       if $self->customer_id && ! $self->quotation;
  return 'purchase_order'    if $self->vendor_id   && ! $self->quotation;
  return 'sales_quotation'   if $self->customer_id &&   $self->quotation;
  return 'request_quotation' if $self->vendor_id   &&   $self->quotation;

  return;
}

sub is_type {
  return shift->type eq shift;
}

sub invoices {
  my $self   = shift;
  my %params = @_;

  if ($self->quotation) {
    return [];
  } else {
    return SL::DB::Manager::Invoice->get_all(
      query => [
        ordnumber => $self->ordnumber,
        @{ $params{query} || [] },
      ]
    );
  }
}

sub abschlag_invoices {
  return shift()->invoices(query => [ abschlag => 1 ]);
}

sub end_invoice {
  return shift()->invoices(query => [ abschlag => 0 ]);
}

sub convert_to_invoice {
  my ($self, %params) = @_;

  croak("Conversion to invoices is only supported for sales records") unless $self->customer_id;

  my $invoice;
  if (!$self->db->do_transaction(sub {
    $invoice = SL::DB::Invoice->new_from($self)->post(%params) || die;
    $self->link_to_record($invoice);
    $self->update_attributes(closed => 1);
    # die;
  })) {
    return undef;
  }

  return $invoice;
}

1;

__END__

=head1 NAME

SL::DB::Order - Order Datenbank Objekt.

=head1 FUNCTIONS

=head2 type

Returns one of the following string types:

=over 4

=item saes_order

=item purchase_order

=item sales_quotation

=item request_quotation

=back

=head2 is_type TYPE

Rreturns true if the order is of the given type.

=item C<convert_to_invoice %params>

Creates a new invoice with C<$self> as the basis by calling
L<SL::DB::Invoice::new_from>. That invoice is posted, and C<$self> is
linked to the new invoice via L<SL::DB::RecordLink>. C<$self>'s
C<closed> attribute is set to C<true>, and C<$self> is saved.

The arguments in C<%params> are passed to L<SL::DB::Invoice::post>.

Returns the new invoice instance on success and C<undef> on
failure. The whole process is run inside a transaction. On failure
nothing is created or changed in the database.

At the moment only sales quotations and sales orders can be converted.

=item C<create_sales_process>

Creates and saves a new sales process. Can only be called for sales
orders.

The newly created process will be linked bidirectionally to both
C<$self> and to all sales quotations that are linked to C<$self>.

Returns the newly created process instance.

=back

=head1 BUGS

Nothing here yet.

=head1 AUTHOR

Sven Schöling <s.schoeling@linet-services.de>

=cut
