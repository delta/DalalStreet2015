module Hiredis
  class Error < StandardError; end
  class ProtocolError < Error; end
  class ReplyError < Error; end
end
