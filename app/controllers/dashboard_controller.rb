class DashboardController < ApplicationController
  def index
    @sensor_data = fetch_sensor_data

    respond_to do |format|
      format.html  # Renderiza a view HTML normalmente
      format.turbo_stream  # Renderiza Turbo Stream para atualizações em tempo real
    end
  end

  private

  def fetch_sensor_data
    urls = [
      'http://192.168.15.8/dados'
    ]

    data = {}

    urls.each do |url|
      begin
        response = Net::HTTP.get(URI(url))
        data[url] = JSON.parse(response)
      rescue => e
        Rails.logger.error "Erro ao obter dados de #{url}: #{e.message}"
      end
    end

    data
  end
end

