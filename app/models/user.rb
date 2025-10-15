class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, presence: true
  validates :postal_code, presence: true,
            format: { with: /\A\d{7}\z/ },
            length: { is: 7 }

  has_many :diaries, dependent: :destroy
  has_many :weathers, dependent: :destroy

  before_save :set_coordinates_from_postal_code

  private

  def set_coordinates_from_postal_code
    return unless postal_code_changed? && postal_code.present?

    location_data = GeocodingService.geocode(postal_code)
    if location_data
      self.latitude = location_data[:latitude]
      self.longitude = location_data[:longitude]
      self.city = location_data[:city]
      self.town = location_data[:town]
    else
      errors.add(:postal_code, "無効な郵便番号です")
      throw(:abort)
    end
  end
end
