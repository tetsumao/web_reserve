require "rails_helper"

RSpec.describe WebReservationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/web_reservations").to route_to("web_reservations#index")
    end

    it "routes to #new" do
      expect(get: "/web_reservations/new").to route_to("web_reservations#new")
    end

    it "routes to #show" do
      expect(get: "/web_reservations/1").to route_to("web_reservations#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/web_reservations/1/edit").to route_to("web_reservations#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/web_reservations").to route_to("web_reservations#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/web_reservations/1").to route_to("web_reservations#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/web_reservations/1").to route_to("web_reservations#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/web_reservations/1").to route_to("web_reservations#destroy", id: "1")
    end
  end
end
