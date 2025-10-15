class GeocodingService
  # 郵便番号から緯度・経度・市町村名を取得する
  def self.geocode(postal_code)
    new.geocode(postal_code)
  end

  def geocode(postal_code)
    uri = URI("https://geoapi.heartrails.com/api/json?method=searchByPostal&postal=#{postal_code}")
    begin
      response = Net::HTTP.get_response(uri)
      return nil unless response.code == "200"

      data = JSON.parse(response.body)
      parse_location_data(data)
    rescue => e
      Rails.logger.error "郵便番号 #{postal_code} の座標取得に失敗しました: #{e.message}"
      nil
    end
  end

  private
  # APIのレスポンスから必要な情報を抽出する
  def parse_location_data(data)
    if data["response"] && data["response"]["location"] && data["response"]["location"].any?
      location = data["response"]["location"].first
      {
        latitude: location["y"].to_f,
        longitude: location["x"].to_f,
        city: location["city"],
        town: location["town"]
      }
    else
      nil
    end
  end
end
