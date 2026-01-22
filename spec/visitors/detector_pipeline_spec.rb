require 'spec_helper'
require 'tmpdir'

RSpec.describe RubyCodeParser::DetectorPipeline do
  let(:type_strategy) { instance_double('TypeStrategy', infer_type: 'T.untyped') }
  let(:builder) { RubyCodeParser::SemanticModelBuilder.new(type_strategy: type_strategy) }
  let(:parser) { RubyCodeParser::ParserService.new }
  let(:project_ast) { parser.parse_paths('test_code/sample.rb') }
  let(:semantic_model) { builder.build(project_ast) }
  let(:tmp_path) { File.join(Dir.mktmpdir, 'candidates.json') }

  it 'produces SRP candidates for the sample GodClass' do
    pipeline = described_class.new(
      detectors: [RubyCodeParser::Detectors::SRPDetector.new(name: :srp)],
      output_path: tmp_path
    )

    candidates = pipeline.run(semantic_model)

    expect(candidates.map(&:type)).to include(:srp)
    expect(File).to exist(tmp_path)
  end
end