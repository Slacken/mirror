require 'uri'

class Cc98Controller < Controller
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
    
    boards = Cc98::BoardIndex.last.boards
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
  # 
  def makeup
    ids = [284, 352, 58, 214, 371, 255, 57, 374, 362, 217, 193, 158, 67, 285, 241, 246, 247, 319, 320, 321, 341, 377, 344, 351, 469, 623, 277, 437, 330, 254, 190, 129, 222, 60, 216, 206, 195, 194, 187, 176, 166, 165, 72, 250, 297, 310, 334, 335, 347, 369, 355, 358, 361, 385, 393, 438, 431, 436, 519, 520, 558, 561, 566, 573, 576, 587, 434, 213, 617, 618, 628, 303, 713, 227, 225, 219, 215, 210, 209, 287, 253, 305, 322, 332, 333, 336, 337, 340, 350, 373, 354, 359, 382, 395, 396, 397, 439, 470, 462, 262, 474, 476, 477, 478, 479, 488, 490, 495, 496, 497, 487, 467, 468, 471, 472, 475, 481, 482, 480, 483, 484, 485, 486, 489, 491, 492, 493, 498, 502, 503, 504, 505, 506, 507, 511, 550, 596, 625, 642, 610, 611, 612, 613, 245, 435, 286, 605, 249, 606, 607, 608, 620]
    ids.each do |id|
      bs = Cc98::BoardShow.new(bid: id, p: 1)
      begin
        bs.fetch("http://www.cc98.org/list.asp?boardid=#{id}&page=1")
        raise "Not valid board" unless bs.page_valid?
      rescue StandardError => e
        puts e.message + "(http://www.cc98.org/list.asp?boardid=#{id}&page=1)"
      else
        bs.save!
        index = Index.new("http://www.cc98.org/list.asp?boardid=#{id}&page=*", [2..(bs.max)])
        index.process(bs.header_config) do |page|
          args = Hash[URI(page.url).query.split("&").map{|s| s.split("=")}]
          bss = Cc98::BoardShow.new(bid: args["boardid"], p: args["page"])
          bss.page = page
          bss.save! ? (print '.') : (print '-')
        end
      end
    end
  end
end
