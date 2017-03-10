#!/usr/bin/ruby

require 'csv'

require File.join(File.dirname($0), 'comans-conf.rb')

class CommentAnswer

  attr_reader :relations, :last_comment_id

  def initialize(source = $stdin, destination = $stdout, options = {})
    @source = CSV.new(source, :headers => false, :skip_blanks => true)
    @dest = if destination
              CSV.new(destination, :headers => false)
            else
              File.open(IO::NULL, 'w')
            end

    if options[:relations]
      @relations = {} # key, continued comment id; value, an array of source comment ids
    end
  end

  def each

    @last_comment_id = 0

    @source.each do |line|

      if line.size > 10
        warn "too many columns in #{line}"
      end

      comment_id = if COMMENT_ID_TO_COMMENT_OUT == line[0]
                     warn "commented out: #{line}"
                     nil
                   else
                     line[0].to_i
                   end

      if comment_id
        if @last_comment_id == comment_id
          warn "comment id duplicated: #{@last_comment_id}"
        end
        if @last_comment_id > comment_id
          warn "comment id decrease: #{@last_comment_id}"
        end
        @last_comment_id = comment_id
      end

      continued = line[9]
      unless ! continued or continued.empty? or ACCEPTED == continued
        if continued =~ /^\d+(,\s*\d+)*$/
          if @relations
            continued_comment_ids = continued.split(/,\s*/).collect{|i| i.to_i}
            continued_comment_ids.each do |i|
              @relations[i] ||= []
              @relations[i] << comment_id
            end
          end
        else
          warn "Could not parse #{continued}"
        end
      end

      @dest << yield(comment_id, continued_comment_ids, line)

    end

  end

  def close
    @dest.close
    @source.close
  end

end
