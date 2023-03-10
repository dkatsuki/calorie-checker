class ChatGpt

  def initialize
    @client = OpenAI::Client.new
    @default_parameters = self.get_default_parameters
  end

  def get_default_parameters
    {
      model: "gpt-3.5-turbo",
      messages: [
        { role: "user", content: "ピーマンのレシピおしえて"},
        { role: "assistant", content: "いやです"},
        { role: "user", content: "おねがい"},
      ],
      temperature: 0.7,
    }
  end



  def request
    response = @client.chat(parameters: @default_parameters)
  end
end