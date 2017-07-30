# use this class as middleware to modify responses
class ResponseModifier
  def initialize(app = nil)
    @app = app || -> _ { [404, {}, []] }
  end

  # runs every time a request comes through
  def call(env)
    status, headers, response = @app.call(env)

    # filter by route so that we don't have any unexpected behaviour
    if env["PATH_INFO"] != "/"
      # don't modify response
      return [status, headers, [response.body.to_s]]
    end

    # modify response
    new_response = self.class.addScript(response.body.to_s)

    # also must reset the Content-Length header if changing body
    headers['Content-Length'] = new_response.length.to_s
    [status, headers, [new_response]]
  end

  # example of how to inject javascript into the page
  def self.addScript bodyString
    bodyString = bodyString.gsub("</body>", '<script>console.log("inject javascript")</script></body>')
    bodyString
  end
end
