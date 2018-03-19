#!/usr/bin/ruby
# -*- coding: utf-8 -*-

## Edit the followings to control the processed HTML.

NO_DATE = '(未記入)'
SKIPPED_ID = '(欠番)'
EMPTY_REVISION = '(空)'
NO_PREVIOUS = '-'
NO_DATE_WO_PREVIOUS = '-'
OUT_NO_ANSWER_NEEDED = '(回答不要)'
NOT_ANSWERED_YET = '(未回答)'
NOT_DECIDED_YET = '未'
OUT_ACCEPTED = '済'

TITLE = 'コメントと回答'

TABLE_CAPTION = <<EOF
    *1：番号がないものは丸括弧内に標題．
    *2：「継続」の逆引．
    *3：(コメント者についての注)．
    *4：継続するコメントの番号，継続せず完了であれば「#{OUT_ACCEPTED}」，未判断であれば「#{NOT_DECIDED_YET}」．
EOF
EXCEL_TABLE_CAPTION_ROW_HEIGHT = 42

TABLE_THEAD = <<EOF
   <tr>
      <th rowspan="2">番号</th>
      <th colspan="3">対象文書</th>
      <th rowspan="2">従前 *2</th>
      <th colspan="3">コメント</th>
      <th colspan="2">回答</th>
      <th rowspan="2">継続 *4</th>
    </tr>
    <tr>
      <th>日付</th>
      <th>文書番号 *1</th>
      <th>版</th>
      <th>日付</th>
      <th>コメント者 *3</th>
      <th>コメント</th>
      <th>日付</th>
      <th>回答</th>
    </tr>
EOF

EXCEL_TABLE_COLHEAD_ROWS = <<EOF
   <Row>
    <Cell ss:MergeDown="1" ss:StyleID="header"><Data ss:Type="String">番号</Data></Cell>
    <Cell ss:MergeAcross="2" ss:StyleID="header"><Data ss:Type="String">対象文書</Data></Cell>
    <Cell ss:MergeAcross="3" ss:StyleID="header"><Data ss:Type="String">コメント</Data></Cell>
    <Cell ss:MergeAcross="1" ss:StyleID="header"><Data ss:Type="String">回答</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String"></Data></Cell>
   </Row>
   <Row>
    <Cell ss:Index="2" ss:StyleID="header"><Data ss:Type="String">日付</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">文書番号 *1</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">版</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">従前 *2</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">日付</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">コメント者 *3</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">コメント</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">日付</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">回答</Data></Cell>
    <Cell ss:StyleID="header"><Data ss:Type="String">継続 *4</Data></Cell>
   </Row>
EOF

## Edit the followings to control how to read the source CSV.

COMMENT_ID_TO_COMMENT_OUT = '?'
NO_DATE_FOR_NO_ANSWER_NEEDED = '-'
NO_ANSWER_NEEDED = '不要'
ACCEPTED = '済'

##
