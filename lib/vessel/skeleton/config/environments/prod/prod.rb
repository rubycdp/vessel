# frozen_string_literal: true

class ApplicationCrawler < Vessel::Cargo
  delay 4..6
  thread max: 1
  middleware "Debug"
end
