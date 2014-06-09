#encoding: utf-8
module Cc98
  class BoardIndex < Model
    # index_page 'http://www.cc98.org/customboard.asp' => []
    set_cookie aspsky: 'username=%E5%BF%83%E7%81%AB&usercookies=3&userid=480094&useranony=&userhidden=2&password=965eb72c92a549dd'
    css_many boards: "table.tableBorder1 a" do |node|
      board = { id: node["href"][/[\d]{1,5}/].to_i, name: node.text }
      ancestor = node.ancestors("div[id^=folder], div[id^=child]").first
      if ancestor
        board[:parent] = ancestor["id"][/[\d]{1,5}/].to_i
        board[:parent] = 0 if board[:parent] == board[:id]
      end
      board
    end

    def self.only
      self.last || (raise "No Board Index")
    end
  end

  class BoardShow < Model
    field :p, type: Integer, default: 1
    field :bid, type: Integer
    set_cookie aspsky: 'username=%E5%BF%83%E7%81%AB&usercookies=3&userid=480094&useranony=&userhidden=2&password=965eb72c92a549dd'
    css_one(max: "body>form:last td:first b:nth(2)"){|node| node.content.to_i }
    css_many(urls: '.tableborder1 tr > td:nth(2) > a'){|node| node["href"] }

    def page_valid?
      p <= max
    end
  end

  class PostShow < Model # http://www.cc98.org/dispbbs.asp?boardID=459&ID=4311917
    set_cookie aspsky: 'username=%E5%BF%83%E7%81%AB&usercookies=3&userid=480094&useranony=&userhidden=2&password=965eb72c92a549dd'
    css_one(content: "#ubbcode1"){|node| node.inner_html }
    css_one title: ".tablebody2 td > b"
    css_one(reader: "td[width='70%'] > b"){|node| node.content.strip.to_i}
    css_one(reply: "#topicPagesNavigation > b"){|node| node.content.strip.to_i}
    css_one(pid: "a[href^='reannounce.asp']"){|node| node["href"].match(/reannounce.asp\?BoardID=[\d]{1,5}&id=([\d]{1,10})/)[1].to_i}
    css_one(board: "a[href^='reannounce.asp']"){|node| node["href"].match(/reannounce.asp\?BoardID=([\d]{1,5})&id=[\d]{1,10}/)[1].to_i}
    css_one(user_id: "td.tablebody1[width='175'] a"){|node| m = node["href"].match(/userid=([\d]{1,10})/); m ? m[1] : nil }
    css_one(gender: "img[src$='Male.gif']"){|node| node["src"][/(FeMale|Male)/].downcase }
    css_one pubtime: "td.tablebody1[width='175']"
  end

  class UserIndex < Model
    index_page 'http://www.cc98.org/toplist.asp?page=*&orders=7' => [1..6344]
    css_many(users: 'table.tableborder1 tr[style]') do |node|
      tds = node.css("td")
      {
        name: tds[0].inner_one('a'), 
        id: tds[0].inner_one('a'){|n| n["href"][/[\d]{1,10}/]}.to_i,
        email: tds[1].inner_one('a'){|n| m = n["href"].match(/mailto:([\S]+)/); m && m[1]},
        qq: tds[2].inner_one('a'){|n| n && n["href"][/[\d]{4,12}/]},
        url: tds[3].inner_one('a'){|n| n && n["href"]},
        created: tds[5].content,
        threads: tds[7].content.to_i,
        assets: tds[8].content.to_i
      }.clear_nil
    end
  end

  class UserShow < Model
    css_one(user: 'table.tableborder1') do |node|
      trs = node.css("tr")
      info1 = trs[1].inner_one("td:nth(2)"){|n| n.source.gsub(/： ([\s\S]*?)<br\/>/).map{|a| $1}}
      info2 = trs[3].inner_one("td"){|n| n.source.gsub(/： ([\s\S]*?)<br\/>/).map{|a| $1}}.map{|td| td.include?('未填') ? nil : td}
      {
        id: node.inner_one(".tablebody2 a"){|n| n["href"][/[\d]{1,10}/].to_i },
        logined: info1[10],
        gender: info2[0],
        birthday: info2[1],
        email: info2[3],
        qq: info2[4],
        msn: info2[5],
        url: info2[6]
      }.clear_nil
    end
  end
end
