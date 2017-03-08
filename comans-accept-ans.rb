#!/usr/bin/ruby

require File.join(File.dirname($0), 'comans.rb')

comment_ids_to_accept = ARGV.collect do |i|
  i.to_i
end

ca = CommentAnswer.new()

ca.each do |comment_id, cids, line|

  # answer

  if comment_ids_to_accept.include?(comment_id)
    if ACCEPTED == line[9]
      warn "Already accepted: [#{comment_id}]"
    elsif line[7] and ! line[7].empty? and
        line[8] and ! line[8].empty? and
        (! line[9] or line[9].empty?)
      line[9] = ACCEPTED
    else
      warn "Empty answer or rejected already. Not accepted: [#{comment_id}]"
    end
    comment_ids_to_accept.delete(comment_id)
  end

  line

end

ca.close

comment_ids_to_accept.each do |i|
  warn "No such comment: [#{i}]"
end
