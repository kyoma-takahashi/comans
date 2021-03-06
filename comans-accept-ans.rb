#!/usr/bin/ruby

=begin

This reads the comments and answers in a CSV from the standard input,
accepts some answer(s), and writes the processed CSV to the standard
output. The comment ID(s) are to be given as the arguments, to accept
the answers for the IDs.

=end

require File.join(File.dirname($0), 'comans.rb')

def abort_usage
  abort 'Arguments: comment_id [...]'
end

comment_ids_to_accept = ARGV.collect do |i|
  i.to_i
end
abort_usage if comment_ids_to_accept.empty?

ca = CommentAnswer.new()

ca.each do |comment_id, cids, line|

  # answer

  if comment_ids_to_accept.include?(comment_id)
    if ACCEPTED == line[9]
      warn "Already accepted: [#{comment_id}]"
    elsif line[8] and ! line[8].empty? and
        (! line[9] or line[9].empty?)
      line[9] = ACCEPTED
      if ! line[7] or line[7].empty?
        warn "Empty answer date. Accepted: [#{comment_id}]"
      end
    else
      warn "Empty answer or rejected already. Not accepted: [#{comment_id}]"
    end
    comment_ids_to_accept.delete(comment_id)
  end

  if ACCEPTED == line[9]
    line[9] = OUT_ACCEPTED
  end

  line

end

ca.close

comment_ids_to_accept.each do |i|
  warn "No such comment: [#{i}]"
end
