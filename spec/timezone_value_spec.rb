# frozen_string_literal: true

RSpec.describe TimezoneValue do
  require "rails_values/rspec/whole_value_role"

  def cast(*args)
    described_class.cast(*args)
  end

  describe "Behaves like a rails value" do
    let(:regular_value) { "UTC" }
    let(:regular_value2) { "Africa/Johannesburg" }
    let(:blank_value) { nil }
    let(:exceptional_value) { "BLAHBLAH" }

    context "when regular value" do
      subject { cast("Africa/Johannesburg") }

      it_behaves_like "Whole Value"
      it { is_expected.to be_regular }
      it { is_expected.not_to be_exceptional }
      it { is_expected.not_to be_blank }
    end

    context "when blank value" do
      subject { cast(blank_value) }

      it_behaves_like "Whole Value"

      it { is_expected.not_to be_regular }
      it { is_expected.not_to be_exceptional }
      it { is_expected.to be_blank }

      it "blank has same API as regular" do
        missing_methods = cast(regular_value).public_methods - subject.public_methods
        expect(missing_methods).to be_blank
      end
    end

    context "when exceptional value" do
      subject { cast(exceptional_value) }

      it_behaves_like "Whole Value"

      it { is_expected.not_to be_regular }
      it { is_expected.to be_exceptional }
      it { is_expected.not_to be_blank }

      it "returns exceptional if only path" do
        record = SimpleModel.new
        subject.exceptional_errors(record.errors, :email, {})
        expect(record.errors.full_messages)
          .to contain_exactly("Email has a invalid value of #{exceptional_value}")
      end

      it "blank has same API as regular" do
        missing_methods = cast(regular_value).public_methods - subject.public_methods
        expect(missing_methods).to be_blank
      end
    end

    describe "Equality" do
      it "same regular value is equal" do
        first_cast = cast(regular_value)
        second_cast = cast(regular_value)
        expect(first_cast).to eq(second_cast)
        expect(first_cast).to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 1)
      end

      it "same regular value is equal if casted multiple times" do
        first_cast = cast(regular_value)
        second_cast = cast(cast(regular_value))
        expect(first_cast).to eq(second_cast)
        expect(first_cast).to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 1)
      end

      it "different regular value are not equal" do
        first_cast = cast(regular_value)
        second_cast = cast(regular_value2)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end

      it "regular values can be compared against strings" do
        first_cast = cast(regular_value)
        expect(first_cast).to eq(regular_value)
        expect(first_cast).to eql(regular_value)
        expect(first_cast).not_to eq(regular_value2)
        expect(first_cast).not_to eql(regular_value2)
        expect([first_cast, regular_value].uniq).to have_attributes(size: 2)
      end

      it "regular values can be compared against blank" do
        first_cast = cast(regular_value)
        second_cast = cast(blank_value)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end

      it "regular values can be compared against exceptional" do
        first_cast = cast(regular_value)
        second_cast = cast(exceptional_value)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end

      it "exceptional values can be compared blank exceptional" do
        first_cast = cast(blank_value)
        second_cast = cast(exceptional_value)
        expect(first_cast).not_to eq(second_cast)
        expect(first_cast).not_to eql(second_cast)
        expect([first_cast, second_cast].uniq).to have_attributes(size: 2)
      end
    end
  end

  describe "Examples" do
    it "works" do
      value = cast("Europe/Sarajevo")
      expect(value.to_s).to eq("Europe/Sarajevo")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "works with Asia/Calcutta" do
      value = cast("Asia/Calcutta")
      expect(value.to_s).to eq("Asia/Calcutta")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "works with Asia/Saigon" do
      value = cast("Asia/Saigon")
      expect(value.to_s).to eq("Asia/Saigon")
      expect(value).to be_present
      expect(value).to be_regular
      expect(value).not_to be_exceptional
    end

    it "works if blank casted multiple times" do
      value = cast(cast(nil))
      expect(value.to_s).to eq("")
      expect(value).to be_blank
      expect(value).not_to be_regular
      expect(value).not_to be_exceptional
    end

    it "works if exceptional value casted multiple times" do
      value = cast(cast("{}"))
      expect(value.to_s).to eq("{}")
      expect(value).not_to be_blank
      expect(value).not_to be_regular
      expect(value).to be_exceptional
    end
  end

  it "expects all codes to be unique" do
    codes = described_class.all.map(&:code).sort

    expect(codes).to match_array(codes.uniq)
  end

  it "expects all identifiers to be unique" do
    identifiers = described_class.all.map(&:identifier).sort

    expect(identifiers).to match_array(identifiers.uniq)
  end
end
