# frozen_string_literal: true

class ApplicationCrawler < Vessel::Cargo
  delay 4..6
  threads max: 1
  middleware "Debug"
end
