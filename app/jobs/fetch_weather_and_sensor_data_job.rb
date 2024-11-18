class FetchWeatherAndSensorDataJob < ApplicationJob
  queue_as :default

  def perform(esp32_urls)
    # Buscando os dados climáticos
    weather_data = fetch_weather_data
    # Buscando os dados dos sensores
    sensor_data = fetch_sensor_data(esp32_urls)

    # Verifique se os dados dos sensores foram recuperados corretamente
    if sensor_data[:temperature].nil? || sensor_data[:humidity].nil?
      Rails.logger.error "Dados do sensor não encontrados ou inválidos: #{sensor_data.inspect}"
    else
      Rails.logger.info "Dados do sensor recebidos: #{sensor_data.inspect}"
    end

    # Salvando os dados no banco
    EnvironmentData.create!(
      esp_temperature: sensor_data[:temperature],
      esp_humidity: sensor_data[:humidity],
      weather_temperature: weather_data[:temperature],
      weather_humidity: weather_data[:humidity]
    )
  end

  private

  def fetch_weather_data
    api_key = ENV['OPENWEATHER_API_KEY']
    city = 'Sao Paulo' # Defina sua cidade fixa
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{api_key}&units=metric"

    response = HTTParty.get(url)
    return {} unless response.code == 200

    data = response.parsed_response
    {
      temperature: data['main']['temp'],
      humidity: data['main']['humidity']
    }
  rescue StandardError => e
    Rails.logger.error "Erro ao buscar dados do OpenWeather: #{e.message}"
    {}
  end

  def fetch_sensor_data(urls)
    urls = ['http://192.168.15.8/dados']

    data = {}
    urls.each do |url|
      begin
        response = HTTParty.get(url)
        sensor_data = response.parsed_response
        # Logar a resposta para verificar o formato dos dados
        Rails.logger.info "Resposta do sensor: #{sensor_data.inspect}"
        
        # Verifique se os dados estão no formato esperado
        if sensor_data['temperatura'].nil? || sensor_data['umidade'].nil?
          Rails.logger.error "Dados do sensor incompletos: #{sensor_data.inspect}"
          return { temperature: nil, humidity: nil }
        end
        
        return {
          temperature: sensor_data['temperatura'],
          humidity: sensor_data['umidade']
        }
      rescue => e
        Rails.logger.error "Erro ao buscar dados do ESP32: #{e.message}"
        return { temperature: nil, humidity: nil }
      end
    end
  end  
end
