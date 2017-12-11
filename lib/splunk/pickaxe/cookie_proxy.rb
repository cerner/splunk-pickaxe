# frozen_string_literal: true

module Splunk
  module Pickaxe
    class CookieProxy < Net::HTTP
      @@cookies ||= nil

      def request(req, body = nil, &block)  # :yield: +response+
        if @@cookies 
          req['Cookie'] = @@cookies
        end
        r = super(req,body,&block)
        c = r.to_hash['set-cookie']
        if c 
          @@cookies = c.collect{|ea|ea[/^.*?;/]}.join
        end
        return r
      end
    end
  end
end
