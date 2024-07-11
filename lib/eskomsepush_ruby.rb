# frozen_string_literal: true

require_relative "eskomsepush/version"
require_relative "eskomsepush/client"

# EskomSePush API Wrapper Rubygem
#
# This is a Rubygem that wraps the EskomSePush API. It allows you to easily integrate the
# EskomSePush API into your Ruby applications.
#
# == Usage:
#   require 'eskomsepush_ruby'
#   esp = EskomSePush::Client.new("{{token}}")
#   esp.get_quota
module EskomSePush; end
