# frozen_string_literal: true

require "faraday"
require "json"
require "ostruct"

RSpec.describe EskomSePush::Client do
  let(:token) { "valid_token" }
  let(:client) { EskomSePush.client(token) }

  context "when initializing the client" do
    it "raises an InvalidTokenError when initialized without a token" do
      expect { EskomSePush.client(nil) }.to raise_error(EskomSePush::EskomSePushError::InvalidTokenError)
    end

    it "initializes a Faraday connection with the provided token" do
      expect(client.instance_variable_get(:@connection)).to be_a(Faraday::Connection)
      expect(client.instance_variable_get(:@connection).headers["token"]).to eq(token)
    end
  end

  context "when making API requests" do
    let(:response) do
      instance_double(Faraday::Response, status: 200, body: '{"allowance":{"count":39,"limit":50,"type":"daily"}}')
    end

    before do
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
    end

    describe "#quota" do
      it "returns quota information as an OpenStruct object" do
        quota = client.quota
        expect(quota).to be_an(OpenStruct)
        expect(quota.allowance.count).to eq(39)
        expect(quota.allowance.limit).to eq(50)
      end

      it "raises a BadRequestError when the request fails" do
        allow(response).to receive(:status).and_return(400)
        expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns correct allowance limits from the quota response" do
        allow(response).to receive(:body).and_return('{"allowance":{"count":39,"limit":50,"type":"daily"}}')
        quota = client.quota
        expect(quota.allowance.limit).to eq(50)
      end
    end

    describe "#status" do
      it "returns the current loadshedding status" do
        allow(response).to receive(:body).and_return('{"status":"Active"}')
        status = client.status
        expect(status.status).to eq("Active")
      end
    end

    describe "#areas_search" do
      it "raises a BadRequestError when search text is nil" do
        expect { client.areas_search(nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns matching areas when searching with valid text" do
        allow(response).to receive(:body).and_return('{"areas":[{"id":"stellenbosch_esko_direct","name":"Stellenbosch (1)"}]}')
        results = client.areas_search("Stellenbosch")
        expect(results.areas.first.id).to eq("stellenbosch_esko_direct")
        expect(results.areas.first.name).to eq("Stellenbosch (1)")
      end
    end

    describe "#area_information" do
      it "raises a BadRequestError when area_id is nil" do
        expect { client.area_information(nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns area details when provided with valid area_id" do
        allow(response).to receive(:body).and_return('{"id":"1","name":"Area1"}')
        info = client.area_information("1")
        expect(info.id).to eq("1")
        expect(info.name).to eq("Area1")
      end
    end

    describe "#areas_nearby" do
      it "raises a BadRequestError when latitude is nil" do
        expect { client.areas_nearby(nil, "18.0") }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "raises a BadRequestError when longitude is nil" do
        expect { client.areas_nearby("-33.9", nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "returns a list of areas near the provided coordinates" do
        allow(response).to receive(:body).and_return('{"areas":[{"count":-1,"id":"eskde-10-magaliessigext17cityofjohannesburggauteng","name":"Magaliessig Ext 17 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"},{"count":-1,"id":"eskde-10-magaliessigext1cityofjohannesburggauteng","name":"Magaliessig Ext 1 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"},{"count":-1,"id":"eskde-10-magaliessigext24cityofjohannesburggauteng","name":"Magaliessig Ext 24 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"},{"count":-1,"id":"eskde-10-magaliessigext28cityofjohannesburggauteng","name":"Magaliessig Ext 28 (10)","region":"Eskom Direct, City of Johannesburg, Gauteng"}]}')
        nearby_areas = client.areas_nearby("-33.9", "18.0")
        expect(nearby_areas.areas.first.name).to eq("Magaliessig Ext 17 (10)")
        expect(nearby_areas.areas.first.region).to eq("Eskom Direct, City of Johannesburg, Gauteng")
        expect(nearby_areas.areas.first.count).to eq(-1)
        expect(nearby_areas.areas.first.id).to eq("eskde-10-magaliessigext17cityofjohannesburggauteng")
        expect(nearby_areas.areas.size).to eq(4)
      end
    end

    describe "#topics_nearby" do
      it "raises a BadRequestError when latitude is nil" do
        expect { client.topics_nearby(nil, "18.0") }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "raises a BadRequestError when longitude is nil" do
        expect { client.topics_nearby("-33.9", nil) }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
      end

      it "raises a BadRequestError when longitude is nil" do
        allow(response).to receive(:body).and_return('{"topics":[{"active":"2022-08-08T13:02:04.776000+02:00","body":"Is anyone else still off in Parkhurst? According to the city power Twitter page electricity has been restored but we’re out on 11th","category":"electricity","distance":4.83,"followers":1,"timestamp":"2022-08-08T13:02:04.776000+02:00"},{"active":"2022-08-08T10:08:32.229000+02:00","body":"Anyone selling laptops","category":"information","distance":3.48,"followers":3,"timestamp":"2022-08-07T10:43:25.319000+02:00"},{"active":"2022-08-08T10:02:52.791000+02:00","body":"Hi , if anyone is in need of a dog sitter / baby sitter I am very flexible and able to travel. I live around the  area \nContact me on  x \nMy name is ","category":"information","distance":1.8,"followers":3,"timestamp":"2022-08-08T09:48:02.819000+02:00"}]}')
        nearby_topics = client.topics_nearby("-33.9", "18.0")
        expect(nearby_topics.topics.first.body).to eq("Is anyone else still off in Parkhurst? According to the city power Twitter page electricity has been restored but we’re out on 11th")
        expect(nearby_topics.topics.first.category).to eq("electricity")
      end
    end
  end

  context "when handling API errors" do
    let(:response) { instance_double(Faraday::Response, body: '{"error":"something went wrong"}') }

    it "raises BadRequestError for HTTP status 400" do
      allow(response).to receive(:status).and_return(400)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::BadRequestError)
    end

    it "raises AuthenticationError with message for HTTP status 403" do
      allow(response).to receive(:status).and_return(403)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::AuthenticationError)
      expect { client.quota }.to raise_error("Authentication Error, check your credentials.")
    end

    it "raises NotFoundError with message for HTTP status 404" do
      allow(response).to receive(:status).and_return(404)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::NotFoundError)
      expect { client.quota }.to raise_error("The resource you requested was not found.")
    end

    it "raises RequestTimeoutError with message for HTTP status 408" do
      allow(response).to receive(:status).and_return(408)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::RequestTimeoutError)
      expect { client.quota }.to raise_error("The request you sent timed out.")
    end

    it "raises RateLimitError with message for HTTP status 429" do
      allow(response).to receive(:status).and_return(429)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::RateLimitError)
      expect { client.quota }.to raise_error("You have exceeded your API quota/allowance.")
    end

    it "raises ServerError with message for HTTP status 500" do
      allow(response).to receive(:status).and_return(500)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::ServerError)
      expect { client.quota }.to raise_error("The SePush API returned a server error.")
    end

    it "raises UnexpectedError with message for unknown HTTP status codes" do
      allow(response).to receive(:status).and_return(999)
      allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(response)
      expect { client.quota }.to raise_error(EskomSePush::EskomSePushError::UnexpectedError)
      expect { client.quota }.to raise_error("Something went wrong while parsing your response data.")
    end
  end
end
