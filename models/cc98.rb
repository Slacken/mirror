#encoding: utf-8
module Cc98
  class Post < Model
    css_one content: "table.tablebody2"
  end

  class UserIndex < Model
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
