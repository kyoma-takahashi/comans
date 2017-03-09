#!/usr/bin/ruby

=begin

This reads the comments and answers in a CSV from the standard input,
merges the answers, and writes the processed CSV to the standard
output. The answers are to be given in a CSV file. The answer file
path and the date of the answers are to be given as the arguments. An
answer file has two columns of the comment IDs and answer texts.

=end

require File.join(File.dirname($0), 'comans.rb')

def abort_usage
  abort 'Arguments: answered_date answers_file'
end

answer_date = ARGV.shift
abort_usage() unless answer_date
answer_file = ARGV.shift
abort_usage() unless answer_file
answer = Hash[*CSV.read(answer_file, :headers => false).collect do |row|
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
