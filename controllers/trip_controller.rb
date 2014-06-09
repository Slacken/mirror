class TripController < Controller
  def item
    Trip::Item.fetch_all!
    puts Trip::Item.index.urls.to_s
    puts Trip::Item.count
    # qyitem.save
  end

  def destination
    Trip::Destination.fetch!
    puts Trip::Destination.last.inspect
  end

  def noteindex
    infos = Hash[Trip::Destination.last.destinations.map{|i| [i["name"], i["url"]]}]
    ["泰国", "芬兰", "冰岛", "瑞士", "英国", "希腊", "广州", "深圳", "桂林", "三亚", "重庆", "成都", "雅安", "安顺", "昆明", "曲靖", "大理", "丽江", "拉萨", "昌都", "日喀则", "那曲", "林芝", "西安", "张掖", "酒泉", "西宁", "玉树", "吐鲁番", "昌吉", "台湾", "香港", "日本", "中国", "北京", "天津", "张家口", "承德", "赤峰", "兴安盟", "锡林郭勒盟", "阿拉善盟", "大连", "上海", "南京", "苏州", "杭州", "嘉兴", "绍兴", "黄山", "厦门", "上饶", "青岛", "烟台", "郑州", "武汉", "湘西土家族苗族自治州", "乌鲁木齐", "克拉玛依", "马来西亚", "新加坡", "摩纳哥", "梵蒂冈", "马耳他", "塞舌尔"].each do |place|
      if (url = infos[place])
        tds = Trip::DestinationShow.new
        tds.fetch(url)
        tds.save
      end
    end
  end
end