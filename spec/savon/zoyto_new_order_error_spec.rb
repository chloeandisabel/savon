require "spec_helper"

describe Savon::ZoytoNewOrderError do
  let(:zoyto_new_order_error) { Savon::ZoytoNewOrderError.new new_response(:body => Fixture.response(:zoyto_new_order_error)), nori }

  let(:nori) { Nori.new(:strip_namespaces => true, :convert_tags_to => lambda { |tag| tag.snakecase.to_sym }) }
  let(:nori_no_convert) { Nori.new(:strip_namespaces => true, :convert_tags_to => nil) }

  it "inherits from Savon::Error" do
    expect(Savon::ZoytoNewOrderError.ancestors).to include(Savon::Error)
  end

  describe "#http" do
    it "returns the HTTPI::Response" do
      expect(zoyto_new_order_error.http).to be_an(HTTPI::Response)
    end
  end

  describe ".present? on getOrderStatusResponse" do
    it "returns false if the HTTP response contains getOrderStatus" do
      http = new_response(:body => Fixture.response(:zoyto_get_order_status_response))
      Savon::ZoytoNewOrderError.present? http
      expect(Savon::ZoytoNewOrderError.present? http).to be_false
    end
  end

  describe ".present?" do
    it "returns true if the HTTP response contains a Zoyto Error" do
      http = new_response(:body => Fixture.response(:zoyto_new_order_error))
      Savon::ZoytoNewOrderError.present? http
      expect(Savon::ZoytoNewOrderError.present? http).to be_true
    end
  end

  describe ".success?" do
    it "returns false on Zotyo new order request failure" do
      response = { :code => 200, :headers => {}, :body => Fixture.response(:zoyto_new_order_error) }
      http = HTTPI::Response.new response[:code], response[:headers], response[:body]
      global = Savon::GlobalOptions.new
      global[:raise_errors] = false
      response = Savon::Response.new(http, global, Savon::LocalOptions.new)
      expect(response.success?).to be_false
    end
  end


  describe ".new" do
    it "should raise a Savon::ZoytoNewOrderError in case of a Zoyto new order failure" do
      lambda {
        response = { :code => 200, :headers => {}, :body => Fixture.response(:zoyto_new_order_error) }
        http = HTTPI::Response.new response[:code], response[:headers], response[:body]
        response = Savon::Response.new(http, Savon::GlobalOptions.new, Savon::LocalOptions.new)
      }.should raise_error(Savon::ZoytoNewOrderError)
    end
  end

  [:message, :to_s].each do |method|
    describe "##{method}" do
      it "returns a Zoyto Error message" do
        expect(zoyto_new_order_error.send method).to eq("(203) Invalid request. (3514)")
      end
    end
  end

  describe "#to_hash" do
    it "returns the SOAP response as a Hash unless a SOAP fault is present" do
      expect(zoyto_new_order_error.to_hash[:new_orders_response][:new_orders_result][:result_code]).to eq("203")
    end
  end

  def new_response(options = {})
    defaults = { :code => 500, :headers => {}, :body => Fixture.response(:zoyto_new_order_error) }
    response = defaults.merge options

    HTTPI::Response.new response[:code], response[:headers], response[:body]
  end

end
