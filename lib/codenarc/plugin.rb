require "nokogiri"

module Danger
  # Shows errors and warnings from codenarc
  # You'll need [codenarc](http://codenarc.sourceforge.net/) installed and
  # generating a XML report file to use this plugin. This plugin does not run
  # codenarc for you.
  #
  # @example Showing summary
  #
  #     danger-codenarc.report 'CodeNarcXmlReport.xml'
  #
  #
  # @see  IntrepidPursuits/danger-codenarc
  # @tags codenarc, groovy
  #
  class DangerCodenarc < Plugin
    # The project root, which will be used to make the paths relative.
    # Defaults to `pwd`.
    # @return   [String] project_root value
    # attr_accessor :project_root
    def project_root
      root = @project_root || Dir.pwd
      root += "/" unless root.end_with? "/"
      root
    end

    # Defines if the test summary will be sticky or not.
    # Defaults to `false`.
    # @return   [Boolean] sticky
    # attr_accessor :sticky_summary
    def sticky_summary
      @sticky_summary || false
    end

    # Reads a puppet-lint summary file and reports it.
    #
    # @param    [String] file_path Path for puppet-lint report.
    # @return   [void]
    def report(file_path)
      raise "Summary file not found" unless File.file?(file_path)

      run_summary(file_path)
    end

    private

    def run_summary(report_file)
      doc = Nokogiri::XML(File.open(report_file))

      # Create Summary
      pkg_summary = doc.xpath("//PackageSummary")[0]
      tf = pkg_summary.attr("totalFiles")
      fwv = pkg_summary.attr("filesWithViolations")
      p1_count = pkg_summary.attr("priority1")
      p2_count = pkg_summary.attr("priority2")
      p3_count = pkg_summary.attr("priority3")
      summary = "CodeNarc scanned #{tf} files. Found #{fwv} files with violations. #{p1_count} P1 violations, #{p2_count} violations, and #{p3_count} P3 violations"
      message(summary, sticky: sticky_summary)

      # Iterate Packages
      doc.xpath("//Package").each do |pack_el|
        pack_el.xpath("File").each do |file_el|
          file_el.xpath("Violation").each do |violation|
            package_path = pack_el.attr("path")
            filename = file_el.attr("name")
            line_num = violation.attr("lineNumber")
            priority = violation.attr("priority")
            rule = violation.attr("ruleName")
            is_err = (priority == 1)

            violation_text = violation.xpath("Message")[0].text
            source_line = violation.xpath("SourceLine")[0].text
            violation_message = "#{package_path}/#{filename}#L#{line_num} - P#{priority} [#{rule}] - #{violation_text}\n'#{source_line}'"

            if is_err
              fail(violation_message, sticky: false)
            else
              warn(violation_message, sticky: false)
            end
          end
        end
      end
    end
  end
end
