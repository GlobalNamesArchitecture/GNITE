# -*- encoding: binary -*-

module Unicorn
# This middleware is used to ensure input is buffered to memory
# or disk (depending on size) before the application is dispatched
# by entirely consuming it (from TeeInput) beforehand.
#
# Usage (in config.ru):
#
#     require 'unicorn/preread_input'
#     if defined?(Unicorn)
#       use Unicorn::PrereadInput
#     end
#     run YourApp.new
class PrereadInput
  def initialize(app)
    @app = app
  end

  def call(env)
    buf = ""
    input = env["rack.input"]
    if buf = input.read(16384)
      true while input.read(16384, buf)
      input.rewind
    end
    @app.call(env)
  end
end
end
