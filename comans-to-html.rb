#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rexml/document'
require 'date'

require File.join(File.dirname($0), 'comans.rb')

doc = REXML::Document.new(<<XHTML)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
  <title>#{TITLE}</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <style type="text/css">
table {
  width: 100%;
  border-collapse: collapse;
  border: thin solid black;
  font-size: small;
}
caption {
  caption-side: top;
  text-align: left;
}
tr {
  page-break-inside: avoid;
}
th {
  border: thin solid black;
}
td {
  border: thin solid black;
}
td.short, td.number {
  white-space: nowrap;
}
td.number {
  text-align: right;
}
td.warn {
  background: yellow;
}
  </style>
</head>
<body>
<table>
  <caption>
    *1：番号がないものは丸括弧内に標題．
    *2：「継続」の逆引．
    *3：#{COMMENTER_CAPTION}．
    *4：継続するコメントの番号，継続せず完了であれば「済」，未判断であれば「未」．
  </caption>
  <thead>
    <tr>
      <th rowspan="2">番号</th>
      <th colspan="3">コメント対象 #{COMMENT_OBJECT}</th>
      <th rowspan="2">従前 *2</th>
      <th colspan="3">#{COMMENTER} コメント</th>
      <th colspan="2">#{ANSWERER} 回答</th>
      <th rowspan="2">継続 *4</th>
    </tr>
    <tr>
      <th>提出日</th>
      <th>#{COMMENT_OBJECT_SHORT}番号 *1</th>
      <th>版</th>
      <th>日付</th>
      <th>コメント者 *3</th>
      <th>コメント</th>
      <th>日付</th>
      <th>回答</th>
    </tr>
  </thead>
  <!-- <tfoot>
    <tr>
      <td colspan="11">
      </td>
    </tr>
  </tfoot> -->
  <tbody>
  </tbody>
</table>
</body>
</html>
XHTML

tbody = REXML::XPath.match(doc, '/html/body/table/tbody')[0]

def put_date(td_element, date_str, invalid_date = nil)
  begin
    td_element.text = Date.parse(date_str || '').strftime("%Y-\n%m-%d")
  rescue ArgumentError
    warn "Could not parse date #{date_str}"
    td_element.text = invalid_date || NO_DATE
    unless invalid_date
      td_element.add_attribute('class', [td_element.attribute('class'), 'warn'].join(' '))
    end
  end
end

ca = CommentAnswer.new($stdin, nil, :relations => true)

ca.each do |comment_id, cids, line|

  unless comment_id
    next
  end

  for i in (ca.last_comment_id + 1)...comment_id
    tr = tbody.add_element('tr')
    tr.add_element('td', 'class' => 'number').text = i
    tr.add_element('td', 'colspan' => 10, 'class' => 'warn').text = SKIPPED_ID
  end

  tr = tbody.add_element('tr')
  tr.add_element('td', 'class' => 'number').text = comment_id

  # document to be commented

  put_date(tr.add_element('td', 'class' => ''), line[1])
  tr.add_element('td', 'class' => '').text = line[2]
  tr.add_element('td', 'class' => 'short').text =
    if ! line[3] or line[3].empty?
      EMPTY_REVISION
    else
      line[3]
    end

  # continued from

  continued_from_others = false
  tr.add_element('td').text =
    if ca.relations.has_key?(comment_id)
      continued_from_others = true
      ca.relations.delete(comment_id).join(', ')
    else
      NO_PREVIOUS
    end

  # comment

  put_date(tr.add_element('td', 'class' => ''), line[4], continued_from_others ? NO_DATE_WO_PREVIOUS : nil)
  if ! line[5] or line[5].length < 5
    tr.add_element('td', 'class' => 'short')
  else
    tr.add_element('td')
  end.text = line[5]
  tr.add_element('td').text = line[6]

  # answer

  no_answer_needed = NO_DATE_FOR_NO_ANSWER_NEEDED == line[7] and NO_ANSWER_NEEDED == line[8] and ACCEPTED == line[9]
  not_answered_yet = ((! line[7] or line[7].empty?) and
    (! line[8] or line[8].empty?))
  if no_answer_needed
    tr.add_element('td', 'colspan' => 2, 'class' => 'short',
                   'style' => 'width: 33%;').text = OUT_NO_ANSWER_NEEDED
  elsif not_answered_yet
    tr.add_element('td', 'colspan' => 2, 'class' => 'short warn',
                   'style' => 'width: 33%;').text = NOT_ANSWERED_YET
  else
    put_date(tr.add_element('td', 'class' => ''), line[7])
    td_answer = tr.add_element('td')
    td_answer.text = line[8]
  end

  # continued to

  continued = line[9]
  td_contd = tr.add_element('td')
  if ! continued or continued.empty?
    unless not_answered_yet or no_answer_needed
      td_contd.text = NOT_ANSWERED_YET
      td_contd.add_attribute('class', [td_contd.attribute('class'), 'warn'].join(' '))
    end
  elsif ACCEPTED == continued
    td_contd.text = continued
  elsif cids
    td_contd.text = cids.join(', ')
  end

end

doc.write($stdout, 2)

ca.close

ca.relations.each do |s, p|
  warn "Comment relation break: #{p.join(', ')} to #{s}"
end
