module PostsHelper
    def post_body 
      if params["type"] == "delete"
        "You want to delete #{@post.body}"
      elsif params["type"] == "show"
        @post.body
      end
    end
end