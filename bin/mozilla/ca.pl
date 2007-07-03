#=====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#
#=====================================================================
# SQL-Ledger Accounting
# Copyright (C) 2001
#
#  Author: Dieter Simader
#   Email: dsimader@sql-ledger.org
#     Web: http://www.sql-ledger.org
#
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#======================================================================
#
# module for Chart of Accounts, Income Statement and Balance Sheet
# search and edit transactions posted by the GL, AR and AP
#
#======================================================================

use POSIX qw(strftime);

use SL::CA;
use SL::ReportGenerator;

require "bin/mozilla/reportgenerator.pl";

1;

# end of main

# this is for our long dates
# $locale->text('January')
# $locale->text('February')
# $locale->text('March')
# $locale->text('April')
# $locale->text('May ')
# $locale->text('June')
# $locale->text('July')
# $locale->text('August')
# $locale->text('September')
# $locale->text('October')
# $locale->text('November')
# $locale->text('December')

# this is for our short month
# $locale->text('Jan')
# $locale->text('Feb')
# $locale->text('Mar')
# $locale->text('Apr')
# $locale->text('May')
# $locale->text('Jun')
# $locale->text('Jul')
# $locale->text('Aug')
# $locale->text('Sep')
# $locale->text('Oct')
# $locale->text('Nov')
# $locale->text('Dec')

sub chart_of_accounts {
  $lxdebug->enter_sub();

  $form->{title} = $locale->text('Chart of Accounts');

  CA->all_accounts(\%myconfig, \%$form);

  my @columns     = qw(accno description debit credit);
  my %column_defs = (
    'accno'       => { 'text' => $locale->text('Account'), },
    'description' => { 'text' => $locale->text('Description'), },
    'debit'       => { 'text' => $locale->text('Debit'), },
    'credit'      => { 'text' => $locale->text('Credit'), },
  );

  my $report = SL::ReportGenerator->new(\%myconfig, $form);

  $report->set_options('output_format'         => 'HTML',
                       'title'                 => $form->{title},
                       'attachment_basename'   => $locale->text('chart_of_accounts') . strftime('_%Y%m%d', localtime time),
                       'std_column_visibility' => 1,
    );
  $report->set_options_from_form();

  $report->set_columns(%column_defs);
  $report->set_column_order(@columns);

  $report->set_export_options('chart_of_accounts');

  $report->set_sort_indicator($form->{sort}, 1);

  my %totals = ('debit' => 0, 'credit' => 0);

  foreach my $ca (@{ $form->{CA} }) {
    my $row = { };

    foreach (qw(debit credit)) {
      $totals{$_} += $ca->{$_} * 1;
      $ca->{$_}    = $form->format_amount(\%myconfig, $ca->{$_}, 2) if ($ca->{$_});
    }

    map { $row->{$_} = { 'data' => $ca->{$_} } } @columns;

    map { $row->{$_}->{align} = 'right'       } qw(debit credit);
    map { $row->{$_}->{class} = 'listheading' } @columns if ($ca->{charttype} eq "H");

    $row->{accno}->{link} = build_std_url('action=list', 'accno=' . E($ca->{accno}), 'description=' . E($ca->{description}));

    $report->add_data($row);
  }

  my $row = { map { $_ => { 'class' => 'listtotal', 'align' => 'right' } } @columns };
  map { $row->{$_}->{data} = $form->format_amount(\%myconfig, $totals{$_}, 2) } qw(debit credit);

  $report->add_separator();
  $report->add_data($row);

  $report->generate_with_headers();

  $lxdebug->leave_sub();
}

sub list {
  $lxdebug->enter_sub();

  $form->{title} = $locale->text('List Transactions');
  $form->{title} .= " - " . $locale->text('Account') . " $form->{accno}";

  # get departments
  $form->all_departments(\%myconfig);
  if (@{ $form->{all_departments} }) {
    $form->{selectdepartment} = "<option>\n";

    map {
      $form->{selectdepartment} .=
        "<option>$_->{description}--$_->{id}\n"
    } (@{ $form->{all_departments} });
  }

  $department = qq|
        <tr>
	  <th align=right nowrap>| . $locale->text('Department') . qq|</th>
	  <td colspan=3><select name=department>$form->{selectdepartment}</select></td>
	</tr>
| if $form->{selectdepartment};

  $form->header;

  $form->{description} =~ s/\"/&quot;/g;

  print qq|
<body>

<form method=post action=$form->{script}>

<input type=hidden name=accno value=$form->{accno}>
<input type=hidden name=description value="$form->{description}">
<input type=hidden name=sort value=transdate>
<input type=hidden name=eur value=$eur>
<input type=hidden name=accounttype value=$form->{accounttype}>

<table border=0 width=100%>
  <tr><th class=listtop>$form->{title}</th></tr>
  <tr height="5"></tr
  <tr valign=top>
    <td>
      <table>
        $department
	<tr>
	  <th align=right>| . $locale->text('From') . qq|</th>
	  <td><input name=fromdate size=11 title="$myconfig{dateformat}"></td>
	  <th align=right>| . $locale->text('To') . qq|</th>
	  <td><input name=todate size=11 title="$myconfig{dateformat}"></td>
	</tr>
	<tr>
	  <th align=right>| . $locale->text('Include in Report') . qq|</th>
	  <td colspan=3>
	  <input name=l_subtotal class=checkbox type=checkbox value=Y>&nbsp;|
    . $locale->text('Subtotal') . qq|</td>
	</tr>
      </table>
    </td>
  </tr>
  <tr><td><hr size=3 noshade></td></tr>
</table>

<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<br><input class=submit type=submit name=action value="|
    . $locale->text('List Transactions') . qq|">
</form>

</body>
</html>
|;

  $lxdebug->leave_sub();
}

sub list_transactions {
  $lxdebug->enter_sub();

  $form->{title} = $locale->text('Account') . " $form->{accno} - $form->{description}";

  CA->all_transactions(\%myconfig, \%$form);

  my @options;
  if ($form->{department}) {
    my ($department) = split /--/, $form->{department};
    push @options, $locale->text('Department') . " : $department";
  }
  if ($form->{projectnumber}) {
    push @options, $locale->text('Project Number') . " : $form->{projectnumber}<br>";
  }

  my $period;
  if ($form->{fromdate} || $form->{todate}) {
    my ($fromdate, $todate);

    if ($form->{fromdate}) {
      $fromdate = $locale->date(\%myconfig, $form->{fromdate}, 1);
    }
    if ($form->{todate}) {
      $todate = $locale->date(\%myconfig, $form->{todate}, 1);
    }

    $period = "$fromdate - $todate";

  } else {
    $period = $locale->date(\%myconfig, $form->current_date(\%myconfig), 1);
  }

  push @options, $period;

  my @columns     = qw(transdate reference description debit credit balance);
  my %column_defs = (
    'transdate'   => { 'text' => $locale->text('Date'), },
    'reference'   => { 'text' => $locale->text('Reference'), },
    'description' => { 'text' => $locale->text('Description'), },
    'debit'       => { 'text' => $locale->text('Debit'), },
    'credit'      => { 'text' => $locale->text('Credit'), },
    'balance'     => { 'text' => $locale->text('Balance'), },
  );
  my %column_alignment = map { $_ => 'right' } qw(debit credit balance);

  my @hidden_variables = qw(accno fromdate todate description accounttype l_heading l_subtotal department projectnumber project_id sort);

  my $link = build_std_url('action=list_transactions', grep { $form->{$_} } @hidden_variables);
  map { $column_defs{$_}->{link} = $link . "&sort=$_" } qw(transdate reference description);

  $form->{callback} = $link . '&sort=' . E($form->{sort});

  my $report = SL::ReportGenerator->new(\%myconfig, $form);

  $report->set_options('top_info_text'         => join("\n", @options),
                       'output_format'         => 'HTML',
                       'title'                 => $form->{title},
                       'attachment_basename'   => $locale->text('list_of_transactions') . strftime('_%Y%m%d', localtime time),
                       'std_column_visibility' => 1,
    );
  $report->set_options_from_form();

  $report->set_columns(%column_defs);
  $report->set_column_order(@columns);

  $report->set_export_options('list_transactions', @hidden_variables);

  $report->set_sort_indicator($form->{sort}, 1);

  $column_defs->{balance}->{visible} = $form->{accno} ? 1 : 0;

  my $ml = ($form->{category} =~ /(A|E)/) ? -1 : 1;

  if ($form->{accno} && $form->{balance}) {
    my $row = {
      'balance' => {
        'data'  => $form->format_amount(\%myconfig, $form->{balance} * $ml, 2),
        'align' => 'right',
      },
    };

    $report->add_data($row);
  }

  my $idx       = 0;
  my %totals    = ( 'debit' => 0, 'credit' => 0 );
  my %subtotals = ( 'debit' => 0, 'credit' => 0 );
  my ($previous_index, $row_set);

  foreach my $ca (@{ $form->{CA} }) {
    $form->{balance} += $ca->{amount};

    foreach (qw(debit credit)) {
      $subtotals{$_} += $ca->{$_};
      $totals{$_}    += $ca->{$_};
      $ca->{$_}       = $form->format_amount(\%myconfig, $ca->{$_}, 2) if ($ca->{$_} != 0);
    }

    $ca->{balance} = $form->format_amount(\%myconfig, $form->{balance} * $ml, 2);

    my $row = { };

    foreach (@columns) {
      $row->{$_} = {
        'data'  => $ca->{$_},
        'align' => $column_alignment{$_},
      };
    }

    if ($ca->{index} ne $previous_index) {
      $report->add_data($row_set) if ($row_set);

      $row_set         = [ ];
      $previous_index  = $ca->{index};

      $row->{reference}->{link} = build_std_url("script=$ca->{module}.pl", 'action=edit', 'id=' . E($ca->{id}), 'callback');

    } else {
      map { $row->{$_}->{data} = '' } qw(reference description);
      $row->{transdate}->{data} = '' if ($form->{sort} eq 'transdate');
    }

    push @{ $row_set }, $row;

    if (($form->{l_subtotal} eq 'Y')
        && (($idx == scalar @{ $form->{CA} } - 1)
            || ($ca->{$form->{sort}} ne $form->{CA}->[$idx + 1]->{$form->{sort}}))) {
      $report->add_data(create_subtotal_row(\%subtotals, \@columns, \%column_alignment, 'listsubtotal'));
    }

    $idx++;
  }

  $report->add_data($row_set) if ($row_set);

  $report->add_separator();

  my $row = create_subtotal_row(\%totals, \@columns, \%column_alignment, 'listtotal');
  $row->{balance}->{data} = $form->format_amount(\%myconfig, $form->{balance} * $ml, 2);
  $report->add_data($row);

  $report->generate_with_headers();

  $lxdebug->leave_sub();
}

sub create_subtotal_row {
  $lxdebug->enter_sub();

  my ($totals, $columns, $column_alignment, $class) = @_;

  my $row = { map { $_ => { 'data' => '', 'class' => $class, 'align' => $column_alignment->{$_}, } } @{ $columns } };

  map { $row->{$_}->{data} = $form->format_amount(\%myconfig, $totals->{$_}, 2) } qw(credit debit);

  map { $totals->{$_} = 0 } qw(debit credit);

  $lxdebug->leave_sub();

  return $row;
}
