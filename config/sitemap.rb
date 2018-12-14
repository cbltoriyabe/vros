# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://vros.jp"

SitemapGenerator::Sitemap.create do
  add root_path            #root_path‚ğsitemap‚É’Ç‰Á‚·‚é
  add '/login'
  add '/login/userview'
  add '/login/yokiview'
  add '/search/search'
  add '/about'
  add '/policy/termsofuse'
  add '/policy/policy'
  add '/contact/form'
  add program_detail_path, priority: 0.7, changefreq: 'daily'

  #”Ô‘gÚ×‚ğ‘S•”E‚¤
  Program.find_each do |program|
   add program_detail_path(program.id), lastmod: program.updated_at
  end
  
end