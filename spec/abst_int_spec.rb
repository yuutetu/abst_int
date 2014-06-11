require "spec_helper"

describe AbstInt do
  let(:ai2)   { AbstInt.new * 2 }
  let(:ai3)   { AbstInt.new * 3 }
  let(:ai6)   { ai2 * ai3 }
  let(:ai6_1) { ai6 + 1 }

  it { expect(ai2   % 2).to eq 0 }
  it { expect(ai3   % 3).to eq 0 }
  it { expect(ai6   % 2).to eq 0 }
  it { expect(ai6   % 3).to eq 0 }
  it { expect(ai6   % 6).to eq 0 }
  it { expect(ai6_1 % 2).to eq 1 }
  it { expect(ai6_1 % 3).to eq 1 }
  it { expect(ai6_1 % 6).to eq 1 }
end