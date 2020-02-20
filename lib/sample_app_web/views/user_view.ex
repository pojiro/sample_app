defmodule SampleAppWeb.UserView do
  use SampleAppWeb, :view

  # 引数で与えられたユーザーのGravatar画像を返す
  def gravatar_for(user, options \\ %{size: 80}) do
    gravatar_id = :crypto.hash(:md5, user.email) |> Base.encode16(case: :lower)
    size = options.size
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    img_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
