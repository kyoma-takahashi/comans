#!/usr/bin/ruby

=begin

This reads the comments and answers in a CSV from the standard input
and writes the processed XML for MS-Excel to the standard output.

=end

require 'rexml/document'
require 'date'

require File.join(File.dirname($0), 'comans.rb')

doc = REXML::Document.new(<<XLSXML)
<?xml version="1.0" encoding="UTF-8"?><?mso-application progid="Excel.Sheet"?>
 <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 <Styles>
  <Style ss:ID="shorttext">
   <Alignment ss:Vertical="Center"/>
   <Font ss:FontName="Monaco" ss:Size="10" ss:Color="#000000"/>
  </Style>
  <Style ss:ID="text">
   <Alignment ss:Vertical="Center" ss:WrapText="1"/>
   <Font ss:FontName="Monaco" ss:Size="10" ss:Color="#000000"/>
  </Style>
  <Style ss:ID="warn">
   <Alignment ss:Vertical="Center"/>
   <Font ss:FontName="Monaco" ss:Size="10" ss:Color="#000000"/>
   <Interior ss:Color="#FFFF80" ss:Pattern="Solid"/>
  </Style>
  <Style ss:ID="number">
   <Alignment ss:Vertical="Center"/>
   <Font ss:FontName="Monaco" ss:Size="10" ss:Color="#000000"/>
  </Style>
  <Style ss:ID="date">
   <Alignment ss:Vertical="Center" ss:WrapText="1"/>
   <Font ss:FontName="Monaco" ss:Size="10" ss:Color="#000000"/>
   <!-- <NumberFormat ss:Format="yyyy\-mm\-dd;@"/> -->
  </Style>
  <Style ss:ID="header">
   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
   <Font ss:FontName="Helvetica" ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
  </Style>
 </Styles>
 <Worksheet ss:Name="#{TITLE}">
  <Names>
   <NamedRange ss:Name="Print_Titles" ss:RefersTo="=R2:R3"/>
   <NamedRange ss:Name="Print_Area" ss:RefersTo="=C1:C11"/>
  </Names>
  <Table>
   <Column ss:Index="1" ss:StyleID="number" ss:Width="19"/>
   <Column ss:StyleID="date" ss:Width="38"/>
   <Column ss:StyleID="text" ss:Width="81"/>
   <Column ss:StyleID="shorttext" ss:Width="32"/>
   <Column ss:StyleID="text" ss:Width="49"/>
   <Column ss:StyleID="date" ss:Width="38"/>
   <Column ss:StyleID="shorttext" ss:Width="34"/>
   <Column ss:StyleID="text" ss:Width="250"/>
   <Column ss:StyleID="date" ss:Width="38"/>
   <Column ss:StyleID="text" ss:Width="250"/>
   <Column ss:StyleID="text" ss:Width="45"/>
   <Row ss:Height="#{EXCEL_TABLE_CAPTION_ROW_HEIGHT}">
    <Cell ss:MergeAcross="10" ss:StyleID="text"><Data ss:Type="String"></Data></Cell>
   </Row>
#{EXCEL_TABLE_COLHEAD_ROWS.chomp}
  </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Layout x:Orientation="Landscape"/>
    <Header x:Data="&amp;L&amp;A&amp;R&amp;D &amp;T&#10;&amp;P/&amp;N"/>
   </PageSetup>
   <FitToPage/>
   <Print>
    <FitHeight>100</FitHeight>
    <Gridlines/>
   </Print>
   <FreezePanes/>
   <SplitHorizontal>3</SplitHorizontal>
   <TopRowBottomPane>3</TopRowBottomPane>
   <ActivePane>2</ActivePane>
  </WorksheetOptions>
  <!-- 
  <AutoFilter x:Range="R3C1:R3C11"
   xmlns="urn:schemas-microsoft-com:office:excel">
  </AutoFilter>
   -->
 </Worksheet>
</Workbook>
XLSXML

tbody = REXML::XPath.match(doc, '/Workbook/Worksheet/Table')[0]

REXML::XPath.match(tbody, './Row[1]/Cell/Data')[0].text = TABLE_CAPTION

def put_date(td_element, date_str, invalid_date = nil)
  begin
    dateval = Date.parse(date_str || '').strftime("%Y-&#13;%m-%d")
    td_element.add_element('Data', 'ss:Type' => 'String').text =
      REXML::Text.new(dateval, false, nil, true)
  rescue ArgumentError
    warn "Could not parse date #{date_str}"
    td_element.add_element('Data', 'ss:Type' => 'String').text = invalid_date || NO_DATE
    unless invalid_date
      td_element.add_attribute('ss:StyleID', 'warn')
    end
  end
end

def put_text(cell_element, text)
  cell_data = cell_element.add_element('Data', 'ss:Type' => 'String')
  cell_data.text = text
  cell_data_text = cell_data.get_text.to_s
  cell_data.text = nil
  cell_data.text = REXML::Text.new(cell_data_text.gsub('&apos;', "'"),
                                   cell_data.whitespace, nil, true)
end

ca = CommentAnswer.new($stdin, nil, :relations => true)

ca.each do |comment_id, cids, line|

  unless comment_id
    next
  end

  for i in (ca.last_comment_id + 1)...comment_id
    tr = tbody.add_element('Row')
    tr.add_element('Cell').add_element('Data', 'ss:Type' => 'Number').text = i
    tr.add_element('Cell', 'ss:MergeAcross' => 9, 'ss:StyleID' => 'warn').
        add_element('Data', 'ss:Type' => 'String').text = SKIPPED_ID
  end

  tr = tbody.add_element('Row')
  tr.add_element('Cell').
    add_element('Data', 'ss:Type' => 'Number').text = comment_id

  # document to be commented

  put_date(tr.add_element('Cell'), line[1])
  tr.add_element('Cell').add_element('Data', 'ss:Type' => 'String').text = line[2]
  tr.add_element('Cell').add_element('Data', 'ss:Type' => 'String').text =
    if ! line[3] or line[3].empty?
      EMPTY_REVISION
    else
      line[3]
    end

  # continued from

  continued_from_others = false
  tr.add_element('Cell').
    add_element('Data', 'ss:Type' => 'String').text =
    if ca.relations.has_key?(comment_id)
      continued_from_others = true
      ca.relations.delete(comment_id).join(', ')
    else
      NO_PREVIOUS
    end

  # comment

  put_date(tr.add_element('Cell'), line[4], continued_from_others ? NO_DATE_WO_PREVIOUS : nil)
  tr.add_element('Cell').add_element('Data', 'ss:Type' => 'String').text = line[5]
  put_text(tr.add_element('Cell'), line[6])

  # answer

  no_answer_needed = NO_DATE_FOR_NO_ANSWER_NEEDED == line[7] and NO_ANSWER_NEEDED == line[8] and ACCEPTED == line[9]
  not_answered_yet = ((! line[7] or line[7].empty?) and
    (! line[8] or line[8].empty?))
  if no_answer_needed
    tr.add_element('Cell', 'ss:MergeAcross' => 1).
      add_element('Data', 'ss:Type' => 'String').text = OUT_NO_ANSWER_NEEDED
  elsif not_answered_yet
    tr.add_element('Cell', 'ss:MergeAcross' => 1, 'ss:StyleID' => 'warn').
      add_element('Data', 'ss:Type' => 'String').text = NOT_ANSWERED_YET
  else
    put_date(tr.add_element('Cell'), line[7])
    put_text(tr.add_element('Cell'), line[8])
  end

  # continued to

  continued = line[9]
  td_contd = tr.add_element('Cell')
  td_contd_data = td_contd.add_element('Data', 'ss:Type' => 'String')
  if ! continued or continued.empty?
    unless not_answered_yet or no_answer_needed
      td_contd_data.text = NOT_DECIDED_YET
      td_contd.add_attribute('ss:StyleID', 'warn')
    end
  elsif ACCEPTED == continued
    td_contd_data.text = OUT_ACCEPTED
  elsif cids
    td_contd_data.text = cids.join(', ')
  end

end

doc.write($stdout, -1, true)

ca.close

ca.relations.each do |s, p|
  warn "Comment relation break: #{p.join(', ')} to #{s}"
end
