require 'spec_helper'

describe 'R10K' do
  let(:subject) { Class.new { extend Helpers } }
  let(:repo) { 'https://example.com/repo.git' }

  before(:each) do
    allow(subject).to receive_message_chain(:logger, :debug)
    allow(subject).to receive_message_chain(:logger, :info)
    allow(subject).to receive(:control_repo).and_return(repo)
    allow(subject).to receive(:control_repo).and_return(repo)
    allow(subject).to receive(:r10k_config_file)
      .and_return('/tmp/tests/r10k_test')
  end

  it 'should return valid R10K template' do
    expect(subject.r10k_template).to match('sources')
  end

  it 'should parse R10K template' do
    expect(subject.r10k_config).to match(repo)
  end

  it 'should write R10K configration' do
    subject.write_r10k_config
    expect(File.read('/tmp/tests/r10k_test')).to match(repo)
  end

  it 'should check R10K configration' do
    subject.check_r10k_config
  end

  it 'should deploy R10K' do
    allow(File).to receive(:write)
    allow(subject).to receive(:`)
    expect(subject.run_r10k_deploy).to be_nil
  end
end
