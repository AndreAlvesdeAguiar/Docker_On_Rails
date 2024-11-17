class DashboardController < ApplicationController
  def index
    @sensor_data = fetch_sensor_data
    @weather_data = fetch_weather_data('Sao Paulo')

    respond_to do |format|
      format.html  # Renderiza a view HTML normalmente
      format.turbo_stream  # Renderiza Turbo Stream para atualizações em tempo real
    end
  end

  private

  def fetch_weather_data(city)
    require 'cgi'
    # Codificar o nome da cidade para garantir que caracteres especiais sejam tratados
    encoded_city = CGI.escape(city)
    api_key = ENV['OPENWEATHER_API_KEY']
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{encoded_city}&appid=#{api_key}&units=metric"

    # Fazer a requisição com HTTParty
    response = HTTParty.get(url)

    if response.code == 200
      # Extrair dados da resposta e retornar as informações necessárias
      data = response.parsed_response
      {
        temperature: data['main']['temp'],
        humidity: data['main']['humidity']
      }
    else
      Rails.logger.error "Erro da API OpenWeather para #{city}: #{response['message']}"
      {}
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao fazer requisição para OpenWeather: #{e.message}"
    {}
  end

  def fetch_sensor_data
    urls = ['http://192.168.15.8/dados']

    data = {}
    urls.each do |url|
      begin
        response = HTTParty.get(url)
        sensor_data = response.parsed_response
        data[url] = sensor_data
      rescue => e
        Rails.logger.error "Erro ao obter dados de #{url}: #{e.message}"
        data[url] = {}
      end
    end

    data
  end
end



