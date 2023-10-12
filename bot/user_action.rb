# frozen_string_literal: true

def list_voice_actors
  uri = URI.parse('http://web:3000/voice_actors.json')
  req = Net::HTTP::Get.new(uri)
  http = Net::HTTP.new(uri.hostname, uri.port)
  res = http.request(req)
  json = JSON.parse(res.body)
  ans = []
  json.each do |item|
    ans << item['name']
  end
  ans.join("\n")
end

def change_voice_actor(args, event)
  uri = URI.parse("http://web:3000/users/#{event.author.id}")
  req = Net::HTTP::Patch.new(uri)
  http = Net::HTTP.new(uri.hostname, uri.port)
  req.content_type = 'application/json'
  req.body = "{ \"voice_actor\": \"#{args}\" }"
  res = http.request(req)

  json = JSON.parse(res.body)

end
