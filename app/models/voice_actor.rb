require 'net/http'
require 'openssl'
require 'json'
require 'securerandom'
require 'open-uri'

class VoiceActor < ApplicationRecord
  has_many :voice_histories
  has_many :extra_voices

  def count
    self.voice_histories.sum(:count)
  end
  # @return [VoiceHistory|ExtraVoice]
  def to_speech(text)
    voice_data = find_preload(text)
    if(voice_data)
      return voice_data
    end
    case actor_type
    when 'Voiceroid_daemon'
      return voiceroid_daemon(text)
    when 'Coefont'
      return coefont(text)
    when 'Voicevox'
      return voicevox(text)
    end
  end

  private

  # @param text [String]
  # @return [NilClass|ExtraVoice|VoiceHistory]
  def find_preload(text)
    voice_data = ExtraVoice.find_by(voice_actor: self, matching: text)
    if(voice_data.nil?)
      voice_data = VoiceHistory.find_by(voice_actor: self, matching: text)
    end
    return nil if voice_data.nil?
    voice_data
  end

  # @param text [String]
  def voiceroid_daemon(text)
    uri = URI.parse(url)
    params = { 'Text' => text, 'Speaker' => { 'Speed' => 1.2 } }
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'
    req.body = params.to_json
    voice = Net::HTTP.start(uri.hostname, uri.port) { |http|
      http.request(req)
    }
    file_uuid = SecureRandom.uuid
    open("tmp/#{file_uuid}.wav",'wb') { |f| f.write(voice.body) }
    vh = VoiceHistory.new
    vh.voice_actor = self
    vh.voice.attach(io: File.open("tmp/#{file_uuid}.wav"), filename: "#{file_uuid}.wav")
    vh.matching = text
    vh.save
    vh
  end

  # @param text [String]
  def coefont(text)
    uri = URI.parse('https://api.coefont.cloud/v1/text2speech')
    params = { coefont: uuid, text: text}
    utc = Time.now.to_i
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'
    req['Accept'] = 'application/json'
    req['Authorization'] = ENV.fetch('COEFONT_AUTHENTICATION')
    req['X-Coefont-Date'] = "#{utc}"
    req['X-Coefont-Content'] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), ENV.fetch('COEFONT_SECRET'), "#{utc}#{params.to_json}")
    req.body = params.to_json
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)
    uri = URI.parse(res['location'])
    file_uuid = SecureRandom.uuid

    req = Net::HTTP::Get.new(uri)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    res = http.request(req)
    open("tmp/#{file_uuid}.wav", 'wb'){|f|
      f.write(res.body)
    }
    vh = VoiceHistory.new
    vh.voice_actor = self
    vh.voice.attach(io: File.open("tmp/#{file_uuid}.wav"), filename: "#{file_uuid}.wav")
    vh.matching = text
    vh.save
    File.delete("tmp/#{file_uuid}.wav")
    vh
  end

  # @param text [String]
  def voicevox(text)
    uri = URI.parse("#{url}synthesis?speaker=#{uuid}")
    audio_query = voicevox_get_query(text)
    audio_query = voicevox_change_status(audio_query)
    http = Net::HTTP.new(uri.hostname, uri.port)
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'
    req.body = audio_query
    res = http.request(req)
    file_uuid = SecureRandom.uuid

    open("tmp/#{file_uuid}.wav", 'wb'){|f|
      f.write(res.body)
    }
    vh = VoiceHistory.new
    vh.voice_actor = self
    vh.voice.attach(io: File.open("tmp/#{file_uuid}.wav"), filename: "#{file_uuid}.wav")
    vh.matching = text
    vh.save
    File.delete("tmp/#{file_uuid}.wav")
    vh
  end

  def voicevox_get_query(text)
    uri = URI.parse("#{url}audio_query")
    q = {}
    q['speaker'] = uuid
    q['text']=text
    uri.query = URI.encode_www_form(q)
    http = Net::HTTP.new(uri.hostname, uri.port)

    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/x-www-form-urlencoded'
    res = http.request(req)
    res.body
  end

  def voicevox_change_status(json)
    js = JSON.parse(json)
    js["speedScale"] = 1.2
    js.to_json
  end
end
