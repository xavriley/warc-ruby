require 'pathname'

module Warc
  def self.open_stream(path)
    fh = ::File.new(path,'r+')
    if Pathname.new(path).extname == '.gz'
      Stream::Gzip.new(fh)
    else
      Stream::Plain.new(fh)
    end
  end

  class Stream
    include Enumerable
    attr_reader :parser
    def initialize(fh)
      fh = case fh
      when ::File 
        file_handle = fh
      when String
        ::File.new(fh,'a+')
      end
      @file_handle=fh
      @parser = ::Warc::Parser.new
    end

    def each(offset=0,&block)
      @file_handle.seek(offset,::IO::SEEK_SET)
      loop do
        offset = @file_handle.tell
        rec = self.read_record
        if rec
          rec.offset = offset
          if block_given?
            block.call(rec)
          else
            yield rec
          end
        else
          break
        end
      end
    end
    
    def record(offset=0)
      @file_handle.seek(offset,::IO::SEEK_SET)
      self.read_record
    end
    
    def close
      @file_handle.close
    end
      
    def read_record
      raise StandardError
    end
      
    def write_record(record)
      raise StandardError
    end
  end
end
