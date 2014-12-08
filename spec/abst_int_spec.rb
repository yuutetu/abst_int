require "spec_helper"
require "pry"

describe AbstInt do
  let(:ai2)   { (AbstInt.new * 2).object }
  let(:ai3)   { (AbstInt.new * 3).object }
  let(:ai6)   { (ai2 * ai3).object }
  let(:ai6_1)   { ai6 + 1 }
  let(:ai6__1)  { ai6 - 1 }
  let(:ai6_2)   { ai3 + ai3 }
  let(:ai6_3)   { ((AbstInt.new * 3) & (AbstInt.new * 5)).object }
  let(:ai6_4)   { (AbstInt.new * 3 + 1).not.object }

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
  it { expect(ai6_3 % 3).to eq 0 }
  it { expect(ai6_3 % 5).to eq 0 }
  it { expect(ai6_4 % 3).not_to eq 1 }

  describe "#to_s" do
    it { expect(ai6.to_s).to match /6x/ }
  end

  describe "#/" do
    it { expect{AbstInt.new / 2}.to raise_error }
  end
end