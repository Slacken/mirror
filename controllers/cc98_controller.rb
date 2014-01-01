
class Cc98Controller < Controller
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

  def show
    urls = Cc98::UserIndex.distinct("users.id").map{|id| "http://www.cc98.org/dispuser.asp?id=#{id}"}
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

  def makeup
    ids = Cc98::UserIndex.distinct("users.id") - Cc98::UserShow.distinct("user.id")
    urls = ids.map{|id| "http://www.cc98.org/dispuser.asp?id=#{id}"}
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

  def clean
    puts "hello world"
  end
end
