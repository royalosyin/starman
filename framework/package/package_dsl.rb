module STARMAN
  module PackageDSL
    def self.included base
      base.extend self
    end

    [:homepage, :url, :mirror, :sha256, :version, :filename, :group_master].each do |attr|
      class_eval <<-EOT
        def #{attr} val = nil
          latest.#{attr} val
        end
      EOT
    end

    [:label, :has_label?, :language].each do |attr|
      class_eval <<-EOT
        def #{attr} *val
          latest.#{attr} *val
        end
      EOT
    end

    [:languages, :options].each do |attr|
      class_eval <<-EOT
        def #{attr}
          latest.#{attr}
        end
      EOT
    end

    def revision val = nil, options = {}
      latest.revision val, options
    end

    def belongs_to val
      latest.group_master val
    end

    def create_option_helpers name, spec
      option_spec = self.send(spec).options[name.to_sym]
      case option_spec.type
      when :boolean
        class_eval <<-EOT
          def self.#{name.to_s.gsub('-', '_')}?
            #{spec}.options[:'#{name}'].value
          end
          def #{name.to_s.gsub('-', '_')}?
            #{spec}.options[:'#{name}'].value
          end
        EOT
      when :string
        class_eval <<-EOT
          def self.#{name.to_s.gsub('-', '_')}
            #{spec}.options[:'#{name}'].value
          end
          def #{name.to_s.gsub('-', '_')}
            #{spec}.options[:'#{name}'].value
          end
        EOT
      when :package
        if name =~ /^use-/
          class_eval <<-EOT
            def self.#{name.to_s.gsub('use-', '')}
              #{spec}.options[:'#{name}'].value || #{spec}.options[:'#{name}'].default
            end
            def #{name.to_s.gsub('use-', '')}
              #{spec}.options[:'#{name}'].value || #{spec}.options[:'#{name}'].default
            end
          EOT
        else
          CLI.report_error "When package option is a package, the option name should be 'use_*'!"
        end
      else
        CLI.report_error "Package option #{CLI.red name} is invalid!"
      end
    end

    def option val, options = {}
      latest.option val, options
      # Only allow latest spec can have options.
      create_option_helpers val, :latest
    end

    def has_patch
      data = ''
      start = false
      File.open("#{ENV['STARMAN_ROOT']}/packages/#{package_name}.rb", 'r').each do |line|
        if line =~ /__END__/
          start = true
          next
        end
        data << line if start
      end
      latest.patch data
    end

    def depends_on val, options = {}
      latest.depends_on val, options
    end

    def latest
      if eval "not defined? @@#{package_name}_latest"
        eval "@@#{package_name}_latest ||= PackageSpec.new"
        eval <<-EOT
          @@#{package_name}_latest.options.each do |option_name, option_options|
            create_option_helpers option_name, :latest
          end
        EOT
      end
      eval "@@#{package_name}_latest"
    end

    # To support multiple versions of package, but the history versions should
    # be limited.
    def history &block
      eval "@@#{package_name}_history ||= {}"
      return eval "@@#{package_name}_history" if not block_given?
      spec = PackageSpec.new
      spec.instance_eval(&block)
      eval "@@#{package_name}_history[spec.version.to_s] = spec"
    end

    # Clean the internal data for reevaluating class definition, especially when
    # setting options like 'with-mpi' or 'with-cxx'.
    def clean package_name
      eval "@@#{package_name}_latest.clean if defined? @@#{package_name}_latest"
      eval <<-EOT
        if defined? @@#{package_name}_history
          @@#{package_name}_history.each do |spec|
            spec.clean
          end
        end
      EOT
    end
  end
end