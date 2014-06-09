module HackerNews
  class Link < Model
    css_many links: "ul>li" do |node|
      l = node.inner_one(".storylink>a"){|n| n}
      link = {
        id: node.inner_one(".commentlink>a"){|n| n["href"].match(/item\?id=([\d]{1,8})/)[1].to_i},
        title: l.text,
        url: l["href"]
      }
      link
    end
  end
end