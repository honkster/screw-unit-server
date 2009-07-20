module JsTestCore
  module Resources
    class SpecFile < ::JsTestCore::Resources::File
      map "/specs"

      get "/?" do
        do_get
      end

      get "*" do
        do_get
      end

      protected

      def do_get
        if ::File.exists?(absolute_path)
          if ::File.directory?(absolute_path)
            spec_files = ::Dir["#{absolute_path}/**/*_spec.js"].map do |file|
              ["#{relative_path}#{file.gsub(absolute_path, "")}"]
            end
            get_generated_spec(absolute_path, spec_files)
          else
            super
          end
        elsif ::File.exists?("#{absolute_path}.js")
          get_generated_spec("#{absolute_path}.js", ["#{relative_path}.js"])
        else
          pass
        end
      end

      def get_generated_spec(real_path, spec_files)
        html = render_spec(spec_files)
        headers = {
          'Content-Type' => "text/html",
          'Last-Modified' => ::File.mtime(real_path).rfc822
        }
        [200, headers, html]
      end

      def render_spec(spec_files)
        JsTestCore.suite_representation_class.new(:spec_files => spec_files).to_s
      end

      def absolute_path
        @absolute_path ||= ::File.expand_path("#{spec_path}#{relative_path.gsub(%r{^/specs}, "")}")
      end
    end
  end
end