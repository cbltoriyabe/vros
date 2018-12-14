class ImageUploader < CarrierWave::Uploader::Base

 # リサイズしたり画像形式を変更するのに必要
   include CarrierWave::RMagick

 # 画像の上限を200pxにする
   process :resize_to_limit => [1280, 720]

  # 保存形式をJPGにする
   process :convert => 'jpg'

  # サムネイルを生成する設定
   version :thumb do
     process :resize_to_fill => [40, 40, gravity = ::Magick::CenterGravity]
   end

  # jpg,jpeg,gif,pngしか受け付けない
   def extension_white_list
      %w(jpg jpeg gif png)
   end

   # Override the directory where uploaded files will be stored.
   # This is a sensible default for uploaders that are meant to be mounted:
   def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
     "tmp/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
   end

 # 拡張子が同じでないとGIFをJPGとかにコンバートできないので、ファイル名を変更
  def filename
    super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
  end



end
