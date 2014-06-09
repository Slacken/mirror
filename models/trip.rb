module Trip
  class Item < Model
    index_page 'http://z.qyer.com/index.php?action=list&page=*' => [1..20]
    css_many items: ".lmProductList>li" do |node|
      item = {
        id: node["data-id"].to_i,
        title: node.inner_one(".title"),
        image: node.inner_one(".pic img"){|n| n["src"]},
        price: node.inner_one(".price em").to_i
      }
      item
    end
  end

  class Destination < Model
    one_page 'http://breadtrip.com/hot_destinations/?start=0&count=1600'
    css_many destinations: 'a' do |node| # 760
      destination = {
        url: Request.full_url(node["href"], 'http://breadtrip.com/'),
        image: node.inner_one(".photo"){|n| n["style"].match(/url\('([\S]*?)'\)/)[1]},
        name: node.inner_one(".ellipsis_text"),
        liker: node.inner_one(".wished")[/\d{1,6}/].to_i
      }
      destination
    end
  end

  class DestinationShow < Model
    css_many trips: '.cover-trip>li' do |node|
      trip = {
        title: node.inner_one("dt.one-row-ellipsis>b"),
        cover: node.inner_one(".cover-trip-pic>ol>li"){|n| n["style"].match(/url\(([\S]*?)\)/)[1]}
      }
      trip
    end
  end
end