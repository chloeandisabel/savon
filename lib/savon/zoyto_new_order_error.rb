require 'savon'

module Savon

  class ZoytoNewOrderError < Error

    def self.present?(http)
      body = http.body
      if body.include?("newOrdersResult") && body.include?("<result_code>")
        !body.include?("<result_code>200</result_code>")
      else
        false
      end
    end

    def initialize(http, nori)
      @http = http
      @nori = nori
    end

    attr_reader :http, :nori

    def to_s
      message_by_version
    end

    def to_hash
      parsed = nori.parse(@http.body)
      nori.find(parsed, 'Envelope', 'Body')
    end

    private

    def message_by_version
      if hash = nori.find(to_hash, 'new_orders_response', 'new_orders_result')
        if code = nori.find(hash, 'result_code')
          if text = nori.find(hash, 'error_message')
            "(#{code}) #{text}"
          else
            "(#{code})"
          end
        end
      end
    end

  end
end
