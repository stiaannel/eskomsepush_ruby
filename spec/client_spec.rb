# frozen_string_literal: true

require "faraday"
require "json"
require "ostruct"

RSpec.describe EskomSePush::Client do
  let(:token) { "valid_token" }
  let(:client) { EskomSePush::Client.new(token) }

  context "initialization" do
    it "raises an error when initialized without a token" do
      expect { EskomSePush::Client.new(nil) }.to raise_error(EskomSePush::EskomSePushError::InvalidTokenError)
    end

    it "sets up a Faraday connection with the provided token" do
      expect(client.instance_variable_get(:@connection)).to be_a(Faraday::Connection)
      expect(client.instance_variable_get(:@connection).headers["token"]).to eq(token)
    end
  end

  context "API requests" do
    let(:response) do
      instance_double(Faraday::Response, status: 200, body: '{"allowance":{"count":39,"limit":50,"type":"daily"}}')
    end

    before do
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
    end

    describe "#quota" do
      it "returns the quota information" do
        quota = client.quota
        expect(quota).to be_an(OpenStruct)
        expect(quota.allowance.count).to eq(39)
        expect(quota.allowance.limit).to eq(50)
      end
    end

    describe "#status" do
      it "returns the current status of Eskom Loadshedding" do
        allow(response).to receive(:body).and_return('{"status":"Active"}')
        status = client.status
        expect(status.status).to eq("Active")
      end
    end

    describe "#areas_search" do
      it "raises an error if text is nil" do
        expect { client.areas_search(nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns the search results for areas" do
        allow(response).to receive(:body).and_return('{"areas":[{"id":"1","name":"Area1"}]}')
        results = client.areas_search("Stellenbosch")
        expect(results.areas.first.id).to eq("1")
      end
    end

    describe "#area_information" do
      it "raises an error if area_id is nil" do
        expect { client.area_information(nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns the information for the specified area" do
        allow(response).to receive(:body).and_return('{"id":"1","name":"Area1"}')
        info = client.area_information("1")
        expect(info.id).to eq("1")
        expect(info.name).to eq("Area1")
      end
    end

    describe "#areas_nearby" do
      it "raises an error if latitude or longitude is nil" do
        expect { client.areas_nearby(nil, "18.0") }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
        expect { client.areas_nearby("-33.9", nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns a list of nearby areas" do
        allow(response).to receive(:body).and_return('{"areas":[{"count":-1,"id":"eskde-10-magaliessigext17cityofjohannesburggauteng","name":"Magaliessig Ext 17 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"},{"count":-1,"id":"eskde-10-magaliessigext1cityofjohannesburggauteng","name":"Magaliessig Ext 1 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"},{"count":-1,"id":"eskde-10-magaliessigext24cityofjohannesburggauteng","name":"Magaliessig Ext 24 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"},{"count":-1,"id":"eskde-10-magaliessigext28cityofjohannesburggauteng","name":"Magaliessig Ext 28 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"}]}')
        nearby_areas = client.areas_nearby("-33.9", "18.0")
        expect(nearby_areas.areas.first.name).to eq("Magaliessig Ext 17 (10)")
        expect(nearby_areas.areas.first.region).to eq("Eskom Direct, City of Johannesburg, Gauteng")
        expect(nearby_areas.areas.first.count).to eq(-1)
        expect(nearby_areas.areas.first.id).to eq("eskde-10-magaliessigext17cityofjohannesburggauteng")
      end
    end

    describe "#topics_nearby" do
      it "raises an error if latitude or longitude is nil" do
        expect { client.topics_nearby(nil, "18.0") }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
        expect { client.topics_nearby("-33.9", nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns a list of nearby topics" do
        allow(response).to receive(:body).and_return('{"topics":[{"active":"2022-08-08T13:02:04.776000+02:00","body":"Is anyone else still off in Parkhurst? According to the city power Twitter page electricity has been restored but we’re out on 11th","category":"electricity","distance":4.83,"followers":1,"timestamp":"2022-08-08T13:02:04.776000+02:00"},{"active":"2022-08-08T10:08:32.229000+02:00","body":"Anyone selling laptops","category":"information","distance":3.48,"followers":3,"timestamp":"2022-08-07T10:43:25.319000+02:00"},{"active":"2022-08-08T10:02:52.791000+02:00","body":"Hi , if anyone is in need of a dog sitter / baby sitter I am very flexible and able to travel. I live around the  area \nContact me on  x \nMy name is ","category":"information","distance":1.8,"followers":3,"timestamp":"2022-08-08T09:48:02.819000+02:00"}]}')
        nearby_topics = client.topics_nearby("-33.9", "18.0")
        expect(nearby_topics.topics.first.body).to eq("Is anyone else still off in Parkhurst? According to the city power Twitter page electricity has been restored but we’re out on 11th")
        expect(nearby_topics.topics.first.category).to eq("electricity")
      end
    end
  end

  context "error handling" do
    let(:response) { instance_double(Faraday::Response, body: '{"error":"something went wrong"}') }

    it "raises appropriate error for status code 400" do
      allow(response).to receive(:status).and_return(400)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
    end

    it "raises appropriate error for status code 403" do
      allow(response).to receive(:status).and_return(403)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::AuthenticationError)
      expect { client.quota }.to raise_error("Authentication Error, check your credentials.")
    end

    it "raises appropriate error for status code 404" do
      allow(response).to receive(:status).and_return(404)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::NotFoundError)
      expect { client.quota }.to raise_error("The resource you requested was not found.")
    end

    it "raises appropriate error for status code 408" do
      allow(response).to receive(:status).and_return(408)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::RequestTimeoutError)
      expect { client.quota }.to raise_error("The request you sent timed out.")
    end

    it "raises appropriate error for status code 429" do
      allow(response).to receive(:status).and_return(429)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::RateLimitError)
      expect { client.quota }.to raise_error("You have exceeded your API quota/allowance.")
    end

    it "raises appropriate error for status code 500" do
      allow(response).to receive(:status).and_return(500)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::ServerError)
      expect { client.quota }.to raise_error("The SePush API returned a server error.")
    end

    it "raises unexpected error for other status codes" do
      allow(response).to receive(:status).and_return(999)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::UnexpectedError)
      expect { client.quota }.to raise_error("Something went wrong while parsing your response data.")
    end
  end
end
