#!/usr/bin/ruby

require File.join(File.dirname($0), 'comans.rb')

answer_date = ARGV.shift
answer = Hash[*CSV.read(ARGV.shift, :headers => false).collect do |row|
                [row.shift.to_i, *row]
              end.flatten]

ca = CommentAnswer.new()

ca.each do |comment_id, cids, line|

  # answer

  if ((! line[7] or line[7].empty?) and
      (! line[8] or line[8].empty?))
    if comment_id and answer.has_key?(comment_id)
      line[7] = answer_date
      line[8] = answer[comment_id]
      answer.delete(comment_id)
#     elsif ca.relations[comment_id] and
#         sid = ca.relations[comment_id].find {|sid| answer.has_key?(sid)}
#       line[7] = answer_date
#       line[8] = answer[sid]
#       answer.delete(sid)
    end
  elsif line[8] and ! line[8].empty? and
      comment_id and answer.has_key?(comment_id) and
      answer[comment_id] == line[8]
    answer.delete(comment_id)
  end

  line

end

ca.close

answer.each do |i, a|
  warn "Not merged: [#{i}] #{a}"
end
