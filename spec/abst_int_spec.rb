require "spec_helper"

describe AbstInt do
  let(:ai2)     { AbstInt.new * 2 }
  let(:ai3)     { AbstInt.new * 3 }
  let(:ai6)     { ai2 * ai3 }
  let(:ai2_o)   { (AbstInt.new * 2).object }
  let(:ai3_o)   { (AbstInt.new * 3).object }
  let(:ai6_o)   { (ai2 * ai3).object }
  let(:ai6_1)   { (ai6 + 1).object }
  let(:ai6__1)  { (ai6 - 1).object }
  let(:ai6_2)   { (ai3 + ai3).object }

  it { expect(ai2   % 2).to eq 0 }
  it { expect(ai3   % 3).to eq 0 }
  it { expect(ai6   % 2).to eq 0 }
  it { expect(ai6   % 3).to eq 0 }
  it { expect(ai6   % 6).to eq 0 }
  it { expect(ai6_1 % 2).to eq 1 }
  it { expect(ai6_1 % 3).to eq 1 }
  it { expect(ai6_1 % 6).to eq 1 }
  it { expect(ai6__1 % 2).to eq 1 }
  it { expect(ai6__1 % 3).to eq 2 }
  it { expect(ai6__1 % 6).to eq 5 }
  it { expect(ai6_2 % 6).to eq 0 }

  describe "#to_s" do
    it { expect(ai6.to_s).to match /6x/ }
  end

  describe "#/" do
    it { expect{AbstInt.new / 2}.to raise_error }
  end
end