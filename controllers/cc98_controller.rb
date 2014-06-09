require 'uri'

class Cc98Controller < Controller
  # 
  def makeup
    boards = Cc98::BoardIndex.only.boards.select{|b| b['open']}
    had = Cc98::BoardShow.distinct(:bid)
  end

  # user index
  def index
    index = Index.new('http://www.cc98.org/toplist.asp?page=*&orders=7', [1..6344])
    index.process do |page|
      if page
        ui = Cc98::UserIndex.new
        ui.page = page
        ui.save! ? (print '.') : (print '-')
      else
        print "*"
      end
    end
  end
  # get boards indexes
  def board
    url = 'http://www.cc98.org/customboard.asp'
    bi = Cc98::BoardIndex.new
    bi.fetch(url)
    raise "cannot fetch #{url}" unless bi.save!
    puts "Got #{bi.boards.count} boards"
    
    boards = Cc98::BoardIndex.only.boards
    parents = boards.map{|b| b["parent"] }.uniq
    boards.reject{|b| parents.include?(b["id"])}.each do |b|
      bs = Cc98::BoardShow.new(bid: b["id"], p: 1)
      begin
        bs.fetch("http://www.cc98.org/list.asp?boardid=#{b["id"]}&page=1")
        raise "Not valid board" unless bs.page_valid?
      rescue StandardError => e
        puts e.message + "(http://www.cc98.org/list.asp?boardid=#{b["id"]}&page=1)"
      else
        bs.save!
        index = Index.new("http://www.cc98.org/list.asp?boardid=#{b["id"]}&page=*", [2..(bs.max)])
        index.process(bs.header_config) do |page|
          args = Hash[URI(page.url).query.split("&").map{|s| s.split("=")}]
          bss = Cc98::BoardShow.new(bid: args["boardid"], p: args["page"])
          bss.page = page
          bss.save! ? (print '.') : (print '-')
        end
      end
    end
  end

  def postindex
    bids = Cc98::BoardShow.distinct(:bid)
    bi = Cc98::BoardIndex.only
    bi.boards = bi.boards.map{|b| b["open"] = (bids.include?(b["id"])); b }
    bi.save!
    bids.each do |id|
      urls = Cc98::BoardShow.where(bid: id).distinct(:urls).map{|u| "http://www.cc98.org/#{u}"}
      Index.process(urls, Cc98::BoardShow.header_config) do |page|
        ps = Cc98::PostShow.new
        ps.page = page
        ps.save! ? (print '.') : (print '-')
      end
    end
  end

  # fetch post
  def post
    url = "http://www.cc98.org/dispbbs.asp?boardid=152&id=4311675"
    ps = Cc98::PostShow.new # add known params
    ps.fetch(url)
    puts ps.inspect
  end
  # fetch all user show page
  def show
    urls = (Cc98::UserIndex.distinct("users.id") - Cc98::UserShow.distinct("user.id")).map{|id| "http://www.cc98.org/dispuser.asp?id=#{id}"}
    Index.process(urls) do |page|
      if page
        us = Cc98::UserShow.new
        us.page = page
        us.save! ? (print '.') : (print '-')
      else
        print "*"
      end
    end
  end
  
end
