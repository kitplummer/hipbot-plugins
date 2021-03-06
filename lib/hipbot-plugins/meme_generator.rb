module Hipbot
  module Plugins
    class MemeGenerator
      include Hipbot::Plugin

      attr_accessor :username, :password

      desc 'list available memes to generate'
      on /^memes/ do
        reply(Generator.memes.keys.sort.join(', '))
      end

      desc 'generates new meme eg. `meme allthethings Generate all the memes!`'
      on /^meme (\w+)\s+(.*)/ do |meme, text|
        generator = Generator.new(meme, text)
        query = {
          u: generator.image_url,
          tt: generator.upper_text,
          tb: generator.lower_text
        }
        encoded_query = query.respond_to?(:to_query) ? query.to_query : URI.encode_www_form(query)
        image_url = "http://v1.memecaptain.com/i?#{encoded_query}"
        reply(image_url)
      end

      class Generator
        attr_reader :upper_text, :lower_text, :meme
        def initialize meme, text
          @meme = meme
          assign_texts(text)
        end

        def image_url
          meme_name = self.class.memes.fetch(meme.to_s)
          "http://v1.memecaptain.com/#{meme_name}.png"
        end

        private

        def assign_texts text
          quotes_regexp = /"(.*)"\s+"(.*)"/
          matches = text.match(quotes_regexp)
          if matches
            assign_upper_and_lower_texts(matches[1], matches[2])
          else
            middle = text.length / 2
            middle += 1 while !(text[middle].nil? || text[middle] =~ /\s/)
            assign_upper_and_lower_texts(text[0..middle], text[middle+1..-1])
          end
        end

        def assign_upper_and_lower_texts upper_text, lower_text
          @upper_text = upper_text.to_s.strip
          @lower_text = lower_text.to_s.strip
        end

        def self.memes
          {
            "yuno" => "y_u_no",
            "idontalways" => "most_interesting",
            "allthethings" => "all_the_things",
            "yodawg" => "xzibit",
            "toodamnhigh" => "too_damn_high",
            "fry" => "fry"
          }
        end
      end
    end
  end
end
