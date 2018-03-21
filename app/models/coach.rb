class Coach < ApplicationRecord
    has_many :users
    has_many :appointments
end
