require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerCodenarc do
    it "should be a plugin" do
      expect(Danger::DangerCodenarc.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.codenarc
      end

      it "Counts p2 and p3 as warnings" do
        report_path = File.expand_path('../support/example.xml', __FILE__)
        @my_plugin.report(report_path)
        expect(@dangerfile.status_report[:warnings].size).to eq(78)
      end

      it "Counts p1 as errors" do
        report_path = File.expand_path('../support/example.xml', __FILE__)
        @my_plugin.report(report_path)
        expect(@dangerfile.status_report[:errors].size).to eq(0)
      end
    end
  end
end
