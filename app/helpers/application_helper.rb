module ApplicationHelper
  def default_meta_tags
    {
      site: 'VROS',
      title: 'VROS',
      reverse: true,
      charset: 'utf-8',
      description: 'description',
      keywords: 'VROS,Vtuber,バーチャルYouTuber',
      canonical: request.original_url,
      separator: '|',
      icon: [
        { href: image_url('/img/favicon.ico') },
        { href: image_url('/img/favicon.ico'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/jpg' },
      ],
      og: {
        site_name: 'VROS',
        title: 'VROS',
        description: 'description',
        type: 'website',
        url: request.original_url,
        image: image_url('/img/favicon.ico'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary',
        site: 'vros',
      }
    }
  end
end
